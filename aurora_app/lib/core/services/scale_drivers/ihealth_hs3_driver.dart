import 'dart:async';

import '../ble/spp_aurora_plugin.dart';

/// Port of IHealthHS3Handler — iHealth HS3 (HS33FA4A) classic SPP scale driver.
///
/// Stream protocol (from observed legacy driver):
///   - Weight packet header: A0 09 A6 28, then 5 don't-care bytes, then 2 weight bytes.
///   - Time packet header:   A0 09 A6 33 (ignored).
///   - Weight bytes are encoded as HEX DIGIT CHARACTERS, concatenated into a string,
///     with the decimal point inserted before the last nibble.
///     Example: bytes 0x12 0x34 → hex string "1234" → "123.4" kg.
///     Example: bytes 0x07 0x54 → hex string "0754" → "075.4" → 75.4 kg.
///
/// A 7-state FSM finds headers in the raw SPP byte stream.
/// 60-second de-duplication suppresses identical consecutive readings.
class IHealthHS3Driver {
  /// SDP UUID for iHealth HS3 service discovery.
  static const String sdpUuid = '00000000-0000-0000-0000-00000000C1A5';

  /// Device name prefix for identification (case-insensitive).
  static const String deviceNamePrefix = 'IHEALTH HS3';

  // ---------------------------------------------------------------------------
  // FSM states — bit-identical to the Kotlin IHealthHS3Handler.feedStream()
  // ---------------------------------------------------------------------------
  // 0: WAIT_HEADER_1 — seek 0xA0
  // 1: WAIT_HEADER_2 — expect 0x09
  // 2: WAIT_HEADER_3 — expect 0xA6
  // 3: WAIT_TYPE     — 0x28=weight, 0x33=time(ignored), else reset
  // 4: SKIP_5_BYTES  — skip 5 don't-care bytes
  // 5: READ_WEIGHT_HI
  // 6: READ_WEIGHT_LO → parse/publish → reset
  static const int _stateWaitHeader1 = 0;
  static const int _stateWaitHeader2 = 1;
  static const int _stateWaitHeader3 = 2;
  static const int _stateWaitType = 3;
  static const int _stateSkip5Bytes = 4;
  static const int _stateReadWeightHi = 5;
  static const int _stateReadWeightLo = 6;

  // Header bytes
  static const int _header1 = 0xA0;
  static const int _header2 = 0x09;
  static const int _header3 = 0xA6;

  // Type bytes
  static const int _typeWeight = 0x28;
  static const int _typeTime = 0x33;

  // Number of skip bytes after type
  static const int _skipCount = 5;

  // De-duplication window in milliseconds (matches Android: 60 000 ms)
  static const int _maxTimeDiffMs = 60000;

  // ---------------------------------------------------------------------------
  // Mutable state
  // ---------------------------------------------------------------------------
  int _state = _stateWaitHeader1;
  int _skipRemain = 0;
  int _wHi = 0; // stored as unsigned byte value (0..255)

  // De-duplication state
  int _lastW0 = 0;
  int _lastW1 = 0;
  DateTime? _lastWeighedAt;

  StreamSubscription<List<int>>? _dataSubscription;

  /// Emitted weight measurements in kg.
  final StreamController<double> _weightController =
      StreamController<double>.broadcast();

  bool _disposed = false;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Stream of parsed weight values (kg).
  Stream<double> get onWeight => _weightController.stream;

  /// Returns `true` if the given device [name] matches the iHealth HS3 prefix.
  static bool matchesDeviceName(String name) {
    return name.toUpperCase().startsWith(deviceNamePrefix);
  }

  /// Start listening to the SPP plugin's data stream and begin parsing.
  ///
  /// Call [stop] when done to release the subscription.
  void start(SppAuroraPlugin sppPlugin) {
    _assertNotDisposed();
    _dataSubscription?.cancel();
    _dataSubscription = sppPlugin.onData.listen(_feedStream);
  }

  /// Stop listening and release resources (does not dispose the driver).
  void stop() {
    _dataSubscription?.cancel();
    _dataSubscription = null;
  }

  /// Reset the FSM to its initial state (without stopping the stream).
  void resetParser() {
    _state = _stateWaitHeader1;
    _skipRemain = 0;
    _wHi = 0;
  }

  /// Dispose the driver permanently: stops parsing and closes the weight stream.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    stop();
    _weightController.close();
  }

  // ---------------------------------------------------------------------------
  // Stream parser (state machine) — bit-identical to Kotlin feedStream()
  // ---------------------------------------------------------------------------

  /// Feed a chunk of raw bytes into the FSM.
  void _feedStream(List<int> chunk) {
    for (final int b in chunk) {
      switch (_state) {
        case _stateWaitHeader1:
          // State 0: seek A0
          if (b == _header1) {
            _state = _stateWaitHeader2;
          }
          break;

        case _stateWaitHeader2:
          // State 1: expect 09 (but A0 is a valid restart)
          if (b == _header2) {
            _state = _stateWaitHeader3;
          } else if (b == _header1) {
            _state = _stateWaitHeader2;
          } else {
            _state = _stateWaitHeader1;
          }
          break;

        case _stateWaitHeader3:
          // State 2: expect A6
          if (b == _header3) {
            _state = _stateWaitType;
          } else {
            _state = _stateWaitHeader1;
          }
          break;

        case _stateWaitType:
          // State 3: type byte
          if (b == _typeWeight) {
            // Weight packet — skip next 5 bytes
            _skipRemain = _skipCount;
            _state = _stateSkip5Bytes;
          } else if (b == _typeTime) {
            // Time packet — ignore and reset
            _state = _stateWaitHeader1;
          } else {
            _state = _stateWaitHeader1;
          }
          break;

        case _stateSkip5Bytes:
          // State 4: skip 5 don't-care bytes
          _skipRemain--;
          if (_skipRemain <= 0) {
            _state = _stateReadWeightHi;
          }
          break;

        case _stateReadWeightHi:
          // State 5: read weight high byte
          _wHi = b;
          _state = _stateReadWeightLo;
          break;

        case _stateReadWeightLo:
          // State 6: read weight low byte → parse and publish → reset
          final int wLo = b;
          if (!_isDuplicate(_wHi, wLo)) {
            final double? weight = _parseWeight(_wHi, wLo);
            if (weight != null && !_weightController.isClosed) {
              _weightController.add(weight);
            }
            _lastW0 = _wHi;
            _lastW1 = wLo;
            _lastWeighedAt = DateTime.now();
          }
          _state = _stateWaitHeader1;
          break;

        default:
          // Safety: reset on unexpected state
          _state = _stateWaitHeader1;
          break;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // De-duplication — identical to Kotlin isDuplicate()
  // ---------------------------------------------------------------------------

  bool _isDuplicate(int hi, int lo) {
    if (_lastWeighedAt == null) return false;
    return hi == _lastW0 &&
        lo == _lastW1 &&
        DateTime.now().difference(_lastWeighedAt!).inMilliseconds <
            _maxTimeDiffMs;
  }

  // ---------------------------------------------------------------------------
  // Weight parsing — identical to Kotlin parseAndPublishWeight()
  // ---------------------------------------------------------------------------

  /// Parse weight from two bytes using the hex-digit encoding.
  ///
  /// The two bytes are treated as hex digit characters and concatenated:
  ///   String.format("%02X%02X", hi & 0xFF, lo & 0xFF)
  /// Then the decimal point is inserted before the last nibble:
  ///   "1234" → "123.4"
  ///   "0754" → "075.4" → 75.4
  ///
  /// Returns null if parsing fails.
  double? _parseWeight(int hi, int lo) {
    // Mask to unsigned byte, then format as two uppercase hex digits each.
    // Kotlin: String.format("%02X%02X", hi.toInt() and 0xFF, lo.toInt() and 0xFF)
    final String hex =
        '${(hi & 0xFF).toRadixString(16).toUpperCase().padLeft(2, '0')}'
        '${(lo & 0xFF).toRadixString(16).toUpperCase().padLeft(2, '0')}';

    // Insert decimal point before the last nibble.
    // Kotlin: hex.dropLast(1) + "." + hex.takeLast(1)
    final String weightStr =
        hex.substring(0, hex.length - 1) + '.' + hex.substring(hex.length - 1);

    return double.tryParse(weightStr);
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  void _assertNotDisposed() {
    if (_disposed) {
      throw StateError('IHealthHS3Driver has been disposed');
    }
  }
}
