import 'dart:math';

import 'package:logging/logging.dart';

import '../ble/ble_interface.dart';
import 'byte_utils.dart';
import 'device_support.dart';
import 'scale_driver.dart';
import 'scale_measurement.dart';
import 'scale_user.dart';

/// Driver for Medisana BS444 / BS440 / BS430 scales.
///
/// Port of `MedisanaBs44xHandler.kt`.
///
/// Protocol overview:
/// - Custom service 0x78B2 with characteristics for weight (0x8A21),
///   features (0x8A22), command (0x8A81), and optional custom (0x8A82).
/// - Two-frame aggregation: weight frame arrives first, then feature frame.
/// - Dual-epoch timestamp detection: some models use Unix epoch, others
///   use seconds since 2010-01-01. Auto-detection via proximity heuristic.
class MedisanaBs44xDriver extends ScaleDriver {
  @override
  String get name => 'Medisana BS44x';

  @override
  List<String> get serviceUuids => [_service];

  @override
  LinkMode get linkMode => LinkMode.connectGatt;

  // ── GATT UUIDs ────────────────────────────────────────────────────────

  static final String _service = ScaleDriver.uuid16(0x78B2);
  static final String _chrWeight = ScaleDriver.uuid16(0x8A21); // Indicate
  static final String _chrFeature = ScaleDriver.uuid16(0x8A22); // Indicate
  static final String _chrCmd = ScaleDriver.uuid16(0x8A81); // Write
  // Optional characteristic for custom data (0x8A82, Indicate)
  static final String _chrCustom5 = ScaleDriver.uuid16(0x8A82);

  // ── Epoch detection ───────────────────────────────────────────────────

  /// Seconds between 1970-01-01 and 2010-01-01.
  static const int _scaleEpochOffset = 1262304000;

  static const String _keyEpochMode = 'epochMode';

  _EpochMode? _epochMode;
  _EpochMode? _predictedFromName;

  // ── Aggregation state ─────────────────────────────────────────────────

  ScaleMeasurement? _current;

  // ── Device matching ───────────────────────────────────────────────────

  @override
  DeviceSupport? supportFor(String deviceName, int? rssi) {
    final name = deviceName.toLowerCase();

    // Legacy mapping heuristics:
    //  013197 / 013198 / 0202B6  => BS444/BS440   (2010-epoch)
    //  0203B*                     => BS430        (unix-epoch)
    final looksMedisana =
        name.startsWith('013197') ||
        name.startsWith('013198') ||
        name.startsWith('0202b6') ||
        name.startsWith('0203b');

    // Also match if the device advertises the Medisana service UUID
    // (checked externally by the adapter; here we rely on name pattern)

    if (!looksMedisana) return null;

    _predictedFromName = name.startsWith('0203b')
        ? _EpochMode.unix
        : (name.startsWith('013197') ||
              name.startsWith('013198') ||
              name.startsWith('0202b6'))
        ? _EpochMode.from2010
        : null; // unknown → auto-detect at runtime

    final variant = name.startsWith('0203b')
        ? 'Medisana BS430'
        : (name.startsWith('013197') ||
              name.startsWith('013198') ||
              name.startsWith('0202b6'))
        ? 'Medisana BS444/BS440'
        : 'Medisana BS44x';

    return DeviceSupport(name: variant, linkMode: LinkMode.connectGatt);
  }

  // ── Connection ────────────────────────────────────────────────────────

  @override
  Future<void> onConnected(
    BleService ble,
    String deviceId,
    ScaleUser user,
  ) async {
    // Resolve epoch mode: persisted → name heuristic → default UNIX
    _epochMode = _loadEpochMode() ?? _predictedFromName ?? _EpochMode.unix;

    // Enable indications
    await setNotifyOn(_service, _chrFeature);
    await setNotifyOn(_service, _chrWeight);
    await setNotifyOn(_service, _chrCustom5); // harmless if absent

    // Send "time" command: 0x02 + <timestamp LE>
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final tsForScale = _epochMode == _EpochMode.from2010
        ? nowSec - _scaleEpochOffset
        : nowSec;
    final ts = int32Le(tsForScale);
    await writeTo(_service, _chrCmd, [0x02, ...ts]);

    userInfo('Please step on the scale');
  }

  // ── Notification handling ─────────────────────────────────────────────

  @override
  Future<void> onNotification(
    String characteristicUuid,
    List<int> data,
    ScaleUser user,
  ) async {
    if (characteristicUuid == _chrWeight) {
      _parseWeight(data);
    } else if (characteristicUuid == _chrFeature) {
      _parseFeature(data);
      if (_current != null) {
        publish(_current!);
        _current = null;
      }
    }
    // _chrCustom5: optional/ignored
  }

  @override
  void onAdvertisement(Map<String, dynamic> scanData, ScaleUser user) {
    // Not used for GATT device
  }

  // ── Parsing ───────────────────────────────────────────────────────────

  /// Weight frame: [1..2] u16 LE → kg/100, [5..8] u32 LE → timestamp.
  void _parseWeight(List<int> d) {
    if (d.length < 9) return;

    final weightRaw = u16Le(d, 1);
    final weightKg = weightRaw / 100.0;

    final tsRaw = u32Le(d, 5);
    final tsSec = _mapTimestampFromScale(tsRaw);

    _current = ScaleMeasurement(
      dateTime: DateTime.fromMillisecondsSinceEpoch(tsSec * 1000),
      weight: weightKg,
    );
  }

  /// Feature frame: fat@8..9 water@10..11 muscle@12..13 bone@14..15.
  /// Value = (u16 & 0x0FFF) / 10.
  void _parseFeature(List<int> d) {
    if (d.length < 16) return;

    final existing = _current;
    _current = (existing ?? ScaleMeasurement()).copyWith(
      fat: _decode12bitTenth(d, 8),
      water: _decode12bitTenth(d, 10),
      muscle: _decode12bitTenth(d, 12),
      bone: _decode12bitTenth(d, 14),
    );
  }

  /// Decode a 12-bit value (mask 0x0FFF) divided by 10.
  double _decode12bitTenth(List<int> d, int offset) {
    final v = u16Le(d, offset) & 0x0FFF;
    return v / 10.0;
  }

  // ── Epoch auto-correction ─────────────────────────────────────────────

  /// Convert raw timestamp from scale to Unix seconds, auto-correcting
  /// epoch mode if needed. Heuristic: choose the epoch that puts the
  /// timestamp within ±90 days of "now". Persist the detected mode.
  int _mapTimestampFromScale(int tsRaw) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    const nearThreshold = 90 * 24 * 3600; // 90 days in seconds

    bool nearNow(int x) => (x - now).abs() <= nearThreshold;

    final unixCandidate = tsRaw;
    final epoch2010Candidate = tsRaw + _scaleEpochOffset;

    final mode = _epochMode;

    // If unknown, decide by proximity to now
    if (mode == null) {
      if (nearNow(unixCandidate)) {
        _saveEpochMode(_EpochMode.unix);
        _epochMode = _loadEpochMode();
        return unixCandidate;
      } else if (nearNow(epoch2010Candidate)) {
        _saveEpochMode(_EpochMode.from2010);
        _epochMode = _loadEpochMode();
        return epoch2010Candidate;
      }
      return unixCandidate; // fallback
    }

    // If set to UNIX but looks like 2010 → flip and persist
    if (mode == _EpochMode.unix &&
        !nearNow(unixCandidate) &&
        nearNow(epoch2010Candidate)) {
      _saveEpochMode(_EpochMode.from2010);
      _epochMode = _EpochMode.from2010;
      return epoch2010Candidate;
    }

    // If set to 2010 but looks like UNIX → flip and persist
    if (mode == _EpochMode.from2010 &&
        nearNow(unixCandidate) &&
        !nearNow(epoch2010Candidate)) {
      _saveEpochMode(_EpochMode.unix);
      _epochMode = _EpochMode.unix;
      return unixCandidate;
    }

    // Normal path
    return mode == _EpochMode.from2010 ? epoch2010Candidate : unixCandidate;
  }

  _EpochMode? _loadEpochMode() {
    final stored = settingsGetString(_keyEpochMode);
    switch (stored) {
      case 'unix':
        return _EpochMode.unix;
      case '2010':
        return _EpochMode.from2010;
      default:
        return null;
    }
  }

  void _saveEpochMode(_EpochMode mode) {
    settingsPutString(_keyEpochMode, mode == _EpochMode.unix ? 'unix' : '2010');
    logger.info('Detected epoch mode: $mode (persisted)');
  }
}

/// Timestamp epoch mode for Medisana scales.
enum _EpochMode { unix, from2010 }
