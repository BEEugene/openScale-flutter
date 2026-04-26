import 'dart:async';

import '../../models/enums.dart';
import '../ble/ble_interface.dart';
import 'byte_utils.dart';
import 'composition/miscale_lib.dart';
import 'device_support.dart';
import 'scale_driver.dart';
import 'scale_measurement.dart';
import 'scale_user.dart';

/// Driver for Xiaomi Mi Scale v1 and v2.
///
/// Port of `MiScaleHandler.kt`.
///
/// Protocol overview:
/// - v1 (Mi Scale): uses Weight Service (0x181D), history/time under it.
/// - v2 (Mi Body Composition Scale): uses Body Composition Service (0x181B),
///   vendor config (0x1530), history/time under 0x181B.
/// - History records are 10 bytes; live frames are 13 bytes.
/// - Optional impedance in live frames triggers body composition calculation.
class MiScaleDriver extends ScaleDriver {
  @override
  String get name => 'MiScale';

  @override
  List<String> get serviceUuids => [
    _serviceBodyComp,
    _serviceWeight,
    _serviceMiCfg,
  ];

  @override
  LinkMode get linkMode => LinkMode.connectGatt;

  // ── Variant detection ─────────────────────────────────────────────────

  _Variant _variant = _Variant.v1;

  // ── GATT UUIDs ────────────────────────────────────────────────────────

  static final String _serviceBodyComp = ScaleDriver.uuid16(0x181B);
  static final String _serviceWeight = ScaleDriver.uuid16(0x181D);
  static final String _charCurrentTime = ScaleDriver.uuid16(0x2A2B);
  static final String _charWeightMeas = ScaleDriver.uuid16(0x2A9D);

  // Mi vendor service (v2 only): full 128-bit UUID
  static const String _serviceMiCfg = '00001530-0000-3512-2118-0009af100700';
  static const String _charMiConfig = '00001542-0000-3512-2118-0009af100700';

  // Mi history stream (notify + control): uses 0x2A2F base with vendor prefix
  static const String _charMiHistory = '00002a2f-0000-3512-2118-0009af100700';

  // Protocol constants
  static const List<int> _enableHistoryMagic = [0x01, 0x96, 0x8A, 0xBD, 0x62];

  // ── Session state ─────────────────────────────────────────────────────

  final List<int> _histBuf = [];
  bool _historyMode = false;
  int _importedHistory = 0;
  int _pendingHistoryCount = -1;
  bool _warnedHistoryStatusBits = false;
  Timer? _historyFallbackTimer;

  // ── Device matching ───────────────────────────────────────────────────

  @override
  DeviceSupport? supportFor(String deviceName, int? rssi) {
    final name = deviceName.toUpperCase();

    final isKnownName =
        name.startsWith('MIBCS') ||
        name.startsWith('MIBFS') ||
        name == 'MI SCALE2' ||
        name.startsWith('MI_SCALE');
    if (!isKnownName) return null;

    // v2 detection heuristic (without service UUIDs from scan data)
    final looksV2 = name == 'MIBCS' || name == 'MIBFS' || name == 'MI SCALE2';
    _variant = looksV2 ? _Variant.v2 : _Variant.v1;

    final display = _variant == _Variant.v2
        ? 'Xiaomi Mi Scale v2'
        : 'Xiaomi Mi Scale v1';

    return DeviceSupport(name: display, linkMode: LinkMode.connectGatt);
  }

  // ── Connection ────────────────────────────────────────────────────────

  @override
  Future<void> onConnected(
    BleService ble,
    String deviceId,
    ScaleUser user,
  ) async {
    logger.info('Connected (${_variant.name}); init sequence');

    final svcPrimary = _variant == _Variant.v2
        ? _serviceBodyComp
        : _serviceWeight;
    final svcAlternate = _variant == _Variant.v2
        ? _serviceWeight
        : _serviceBodyComp;

    // v2: set unit via vendor cfg (best-effort)
    if (_variant == _Variant.v2) {
      _sendUnitV2(user);
    }

    // Write current time: prefer primary service
    await _writeCurrentTime(svcPrimary, svcAlternate);

    if (_variant == _Variant.v1) {
      // v1: match legacy order exactly
      // 1) Magic first
      await writeTo(svcPrimary, _charMiHistory, _enableHistoryMagic);
      // 2) Then subscribe history
      await setNotifyOn(svcPrimary, _charMiHistory);
      // 3) Request only-last
      final uniq = user.id;
      final onlyLast = [0x01, 0xFF, 0xFF, (uniq >> 8) & 0xFF, uniq & 0xFF];
      await writeTo(svcPrimary, _charMiHistory, onlyLast);
      // 4) Trigger transfer
      await writeTo(svcPrimary, _charMiHistory, [0x02]);
    } else {
      // v2: modern order
      await setNotifyOn(svcPrimary, _charMiHistory);
      await writeTo(svcPrimary, _charMiHistory, _enableHistoryMagic);

      final uniq = user.id;
      final onlyLast = [0x01, 0xFF, 0xFF, (uniq >> 8) & 0xFF, uniq & 0xFF];
      await writeTo(svcPrimary, _charMiHistory, onlyLast);
      await writeTo(svcPrimary, _charMiHistory, [0x02]);
    }

    _historyMode = true;
    _pendingHistoryCount = -1;
    _importedHistory = 0;
    _warnedHistoryStatusBits = false;
    userInfo('Waiting for measurement data from scale');

    // Arm fallback timer in case firmware ignores "only last" marker
    _armHistoryFallbackTimer(svcPrimary, svcAlternate);
  }

  @override
  void dispose() {
    _historyFallbackTimer?.cancel();
    _historyFallbackTimer = null;
    _histBuf.clear();
    _historyMode = false;
    _importedHistory = 0;
    _pendingHistoryCount = -1;
    _warnedHistoryStatusBits = false;
    super.dispose();
  }

  // ── Notification handling ─────────────────────────────────────────────

  @override
  Future<void> onNotification(
    String characteristicUuid,
    List<int> data,
    ScaleUser user,
  ) async {
    if (data.isEmpty) return;
    if (characteristicUuid == _charCurrentTime) return; // ignore echoes

    if (characteristicUuid == _charMiHistory) {
      _handleHistoryNotify(data, user);
      return;
    }

    if (characteristicUuid == _charWeightMeas) {
      _handleWeightMeasNotify(data, user);
      return;
    }

    logger.fine(
      'Notify $characteristicUuid len=${data.length} '
      '${hexPreview(data, 24)}',
    );
  }

  @override
  void onAdvertisement(Map<String, dynamic> scanData, ScaleUser user) {}

  // ── Writes ────────────────────────────────────────────────────────────

  /// v2-only: set unit via vendor config (ignore failures on clones).
  void _sendUnitV2(ScaleUser user) {
    // [0x06, 0x04, 0x00, unit] — unit: 0=kg, 1=lb, 2=st (coerced to 0..2)
    int unitIndex = 0;
    if (user.scaleUnit == UnitType.lb) {
      unitIndex = 1;
    } else if (user.scaleUnit == UnitType.st) {
      unitIndex = 2;
    }
    final cmd = [0x06, 0x04, 0x00, unitIndex];
    writeTo(_serviceMiCfg, _charMiConfig, cmd);
    logger.fine('Unit set (v2): ${hexPreview(cmd, 16)}');
  }

  /// Write Current Time to the primary service, with fallback to alternate.
  Future<void> _writeCurrentTime(String primarySvc, String alternateSvc) async {
    final now = DateTime.now().toUtc();
    final year = now.year;
    final payload = [
      year & 0xFF, (year >> 8) & 0xFF,
      now.month, now.day, now.hour, now.minute, now.second,
      0x00, 0x00, 0x01, // dayOfWeek placeholder, fractions, adjustReason
    ];

    try {
      await writeTo(primarySvc, _charCurrentTime, payload);
      logger.fine('Current time written (primary).');
    } catch (_) {
      try {
        await writeTo(alternateSvc, _charCurrentTime, payload);
        logger.fine('Current time written (alternate).');
      } catch (e) {
        logger.info('Current time write failed on both services: $e');
      }
    }
  }

  // ── History / live parsing ────────────────────────────────────────────

  void _handleHistoryNotify(List<int> d, ScaleUser user) {
    // STOP (0x03)
    if (d.length == 1 && d[0] == 0x03) {
      _flushHistory();
      // ACK stop + uniq; try both services
      _writeToServiceOf(d, [0x03]);
      final uniq = user.id;
      final ack = [0x04, 0xFF, 0xFF, (uniq >> 8) & 0xFF, uniq & 0xFF];
      _writeToServiceOf(d, ack);
      logger.info(
        'History import done: $_importedHistory record(s). '
        'Announced=$_pendingHistoryCount',
      );
      _historyMode = false;
      return;
    }

    // Response to "only last" or "all": 0x01 <count> 0x00 <marker>
    if (d.length >= 6 && d[0] == 0x01) {
      final count = d[1] & 0xFF;
      final marker = ((d[2] & 0xFF) << 8) | (d[3] & 0xFF);
      if (marker == 0xFFFF || marker == 0x0000) {
        _pendingHistoryCount = count;
        _histBuf.clear();
        logger.info(
          'History count announced (marker=0x${marker.toRadixString(16)}): $_pendingHistoryCount',
        );
      } else {
        logger.fine(
          'Ignoring control response '
          '(marker=0x${marker.toRadixString(16)}, len=${d.length}): '
          '${hexPreview(d, 16)}',
        );
      }
      return;
    }

    // Live frames (13B) or combined (26B)
    if (d.length == 13 || d.length == 26) {
      if (d.length == 13) {
        if (_parseLive13(d, user) && _historyMode) _importedHistory++;
      } else {
        final a = d.sublist(0, 13);
        final b = d.sublist(13, 26);
        final okA = _parseLive13(a, user);
        final okB = _parseLive13(b, user);
        if (_historyMode) {
          _importedHistory += (okA ? 1 : 0) + (okB ? 1 : 0);
        }
      }
      return;
    }

    // Otherwise treat as history chunk(s) → 10-byte aligned records
    _appendHistoryChunk(d, user);
  }

  void _handleWeightMeasNotify(List<int> d, ScaleUser user) {
    // 10-byte frame (same layout as history10) — v1 only
    if (_variant == _Variant.v1 && d.length == 10) {
      _parseHistory10(d, user);
    }
  }

  /// v2 live frame (13 bytes). With/without impedance.
  /// Publishes stabilized frames only. Returns true if published.
  bool _parseLive13(List<int> d, ScaleUser user) {
    if (d.length != 13) return false;

    final c0 = d[0] & 0xFF;
    final c1 = d[1] & 0xFF;
    final isLbs = (c0 & 0x01) != 0;
    final isCatty = (c1 & 0x40) != 0;
    final stable = (c1 & 0x20) != 0;
    final removed = (c1 & 0x80) != 0;
    final hasImp = (c1 & 0x02) != 0;

    if (!stable || removed) return false;

    final year = ((d[3] & 0xFF) << 8) | (d[2] & 0xFF);
    final month = d[4] & 0xFF;
    final day = d[5] & 0xFF;
    final hour = d[6] & 0xFF;
    final minute = d[7] & 0xFF;

    final weightRaw = ((d[12] & 0xFF) << 8) | (d[11] & 0xFF);
    final native = (isLbs || isCatty) ? weightRaw / 100.0 : weightRaw / 200.0;

    final dt = _parseMinuteDate(year, month, day, hour, minute);
    if (dt == null) return false;
    final ts = dt.millisecondsSinceEpoch ~/ 1000;
    final lastTs = _getLastImportedTimestamp(user.id);
    if (ts <= lastTs) return false;

    var m = ScaleMeasurement(
      dateTime: dt,
      weight: toKilogram(native, user.scaleUnit),
      userId: user.id,
    );

    if (hasImp) {
      final imp = ((d[10] & 0xFF) << 8) | (d[9] & 0xFF);
      if (imp > 0) {
        final sex = user.isMale ? 1 : 0;
        final lib = MiScaleLib(sex, user.age(), user.bodyHeight);
        m = m.copyWith(
          water: lib.getWater(m.weight, imp.toDouble()),
          visceralFat: lib.getVisceralFat(m.weight),
          fat: lib.getBodyFat(m.weight, imp.toDouble()),
          muscle: lib.getMuscle(m.weight, imp.toDouble()),
          lbm: lib.getLBM(m.weight, imp.toDouble()),
          bone: lib.getBoneMass(m.weight, imp.toDouble()),
        );
      }
    }

    publish(m);
    _updateLastImportedTimestamp(user.id, ts);
    return true;
  }

  /// History record (10 bytes):
  /// [status][weightLE(2)][yearLE(2)][mon][day][h][m][s]
  bool _parseHistory10(List<int> d, ScaleUser user) {
    if (d.length != 10) return false;
    final status = d[0] & 0xFF;
    final isLbs = (status & 0x01) != 0;
    final isCatty = (status & 0x10) != 0;
    final stable = (status & 0x20) != 0;
    final removed = (status & 0x80) != 0;
    if (!stable || removed) return false;

    // Warn once if unknown status bits are present (no impedance in 10B format)
    if (!_warnedHistoryStatusBits &&
        ((status & 0x02) != 0 || (status & 0x04) != 0)) {
      logger.warning(
        'History status had unexpected bits (1/2) — ignoring '
        '(no impedance in 10B format).',
      );
      _warnedHistoryStatusBits = true;
    }

    final weightRaw = ((d[2] & 0xFF) << 8) | (d[1] & 0xFF);
    final native = (isLbs || isCatty) ? weightRaw / 100.0 : weightRaw / 200.0;

    final year = ((d[4] & 0xFF) << 8) | (d[3] & 0xFF);
    final month = d[5] & 0xFF;
    final day = d[6] & 0xFF;
    final hour = d[7] & 0xFF;
    final minute = d[8] & 0xFF;

    final dt = _parseMinuteDate(year, month, day, hour, minute);
    if (dt == null) return false;
    if (!_plausible(dt)) return false;

    final ts = dt.millisecondsSinceEpoch ~/ 1000;
    final lastTs = _getLastImportedTimestamp(user.id);
    if (ts <= lastTs) return false;

    final m = ScaleMeasurement(
      dateTime: dt,
      weight: toKilogram(native, user.scaleUnit),
      userId: user.id,
    );
    publish(m);
    _updateLastImportedTimestamp(user.id, ts);
    return true;
  }

  void _appendHistoryChunk(List<int> chunk, ScaleUser user) {
    if (chunk.length < 2) return;
    _histBuf.addAll(chunk);

    final full = (_histBuf.length ~/ 10) * 10;
    if (full >= 10) {
      var ok = 0;
      var off = 0;
      while (off < full) {
        if (_parseHistory10(_histBuf.sublist(off, off + 10), user)) ok++;
        off += 10;
      }
      if (ok > 0) _importedHistory += ok;
      final remainder = _histBuf.length - full;
      final leftover = remainder > 0 ? _histBuf.sublist(full) : <int>[];
      _histBuf.clear();
      _histBuf.addAll(leftover);
    }
  }

  void _flushHistory() {
    if (_histBuf.isNotEmpty && _histBuf.length % 10 == 0) {
      var ok = 0;
      var off = 0;
      final user = currentUser;
      if (user != null) {
        while (off < _histBuf.length) {
          if (_parseHistory10(_histBuf.sublist(off, off + 10), user)) ok++;
          off += 10;
        }
      }
      if (ok > 0) _importedHistory += ok;
    }
    _histBuf.clear();
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  DateTime? _parseMinuteDate(int y, int m, int d, int h, int min) {
    try {
      return DateTime.utc(y, m, d, h, min);
    } catch (_) {
      return null;
    }
  }

  bool _plausible(DateTime date, {int years = 20}) {
    final now = DateTime.now();
    final max = DateTime(now.year + years);
    final min = DateTime(now.year - years);
    return date.isAfter(min) && date.isBefore(max);
  }

  /// Write payload to the history characteristic on either service.
  void _writeToServiceOf(List<int> rx, List<int> payload) {
    try {
      writeTo(_serviceBodyComp, _charMiHistory, payload);
    } catch (_) {
      try {
        writeTo(_serviceWeight, _charMiHistory, payload);
      } catch (_) {}
    }
  }

  /// Arm one-shot fallback if 0x01<count> response did not arrive.
  void _armHistoryFallbackTimer(String svcPrimary, String svcAlternate) {
    _historyFallbackTimer?.cancel();
    _historyFallbackTimer = Timer(const Duration(seconds: 1), () async {
      if (!_historyMode || _pendingHistoryCount >= 0) return;

      logger.warning(
        'No history count response on primary; '
        'attempting fallback (ALL records).',
      );

      final uniq2 = currentUser?.id ?? 0;
      final all = [0x01, 0x00, 0x00, (uniq2 >> 8) & 0xFF, uniq2 & 0xFF];

      try {
        await writeTo(svcPrimary, _charMiHistory, _enableHistoryMagic);
        await writeTo(svcPrimary, _charMiHistory, all);
        await writeTo(svcPrimary, _charMiHistory, [0x02]);
      } catch (e) {
        logger.info('Primary fallback write failed: $e');
      }

      try {
        await setNotifyOn(svcAlternate, _charMiHistory);
        await writeTo(svcAlternate, _charMiHistory, _enableHistoryMagic);
        await writeTo(svcAlternate, _charMiHistory, all);
        await writeTo(svcAlternate, _charMiHistory, [0x02]);
      } catch (e) {
        logger.info('Alternate fallback write failed: $e');
      }
    });
  }

  int _getLastImportedTimestamp(int userId) {
    return settingsGetInt('last_imported_ts_$userId', 0);
  }

  void _updateLastImportedTimestamp(int userId, int timestamp) {
    settingsPutInt('last_imported_ts_$userId', timestamp);
  }
}

/// Mi Scale variant (v1 = weight only, v2 = body composition).
enum _Variant { v1, v2 }
