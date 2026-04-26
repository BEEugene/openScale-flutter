import 'dart:async';

import 'package:logging/logging.dart';

import '../../models/enums.dart';
import '../../utils/logging.dart';
import '../ble/ble_interface.dart';
import 'byte_utils.dart';
import 'device_support.dart';
import 'scale_measurement.dart';
import 'scale_user.dart';

/// Callback type for when a driver has a complete measurement.
typedef MeasurementCallback = void Function(ScaleMeasurement measurement);

/// Callback type for user-facing info messages.
typedef InfoCallback = void Function(String message);

/// Abstract base class for BLE scale protocol handlers.
///
/// Subclasses implement vendor-specific BLE protocols for a particular
/// scale brand/model. The driver receives a [BleService] instance for
/// BLE I/O and emits parsed measurements via [onMeasurement].
///
/// Lifecycle:
/// 1. [supportFor] is called during scan to detect supported devices.
/// 2. [onConnected] is called after GATT connection is established.
/// 3. [onNotification] is called for each incoming BLE notification.
/// 4. [onAdvertisement] is called for broadcast-only devices.
/// 5. [dispose] is called on disconnect.
abstract class ScaleDriver {
  final Logger logger = createLogger('ScaleDriver');

  /// Human-readable driver name for logging.
  String get name;

  /// Service UUIDs this driver is interested in (used for scan filtering).
  List<String> get serviceUuids;

  /// How this device communicates.
  LinkMode get linkMode;

  // ── Callbacks (set by the adapter layer) ──────────────────────────────

  /// Called when a fully parsed measurement is ready.
  MeasurementCallback? onMeasurement;

  /// Called to display a user-facing info message.
  InfoCallback? onInfo;

  // ── Internal state ────────────────────────────────────────────────────

  BleService? _ble;
  String? _deviceId;
  ScaleUser? _currentUser;
  final List<StreamSubscription<List<int>>> _subscriptions = [];

  // Per-device settings (in-memory; can be persisted later).
  final Map<String, dynamic> _settings = {};

  // ── Device matching ───────────────────────────────────────────────────

  /// Return a [DeviceSupport] if this driver handles the given [deviceName],
  /// or `null` if it does not.
  /// Return a [DeviceSupport] if this driver handles the given [deviceName],
  /// or `null` if it does not.
  ///
  /// The caller can obtain the matching driver from [ScaleRegistry.matchDevice].
  DeviceSupport? supportFor(String deviceName, int? rssi);

  // ── Lifecycle ─────────────────────────────────────────────────────────

  /// Called after BLE connection is established and services are discovered.
  /// The driver should subscribe to notifications and send initialization
  /// commands here.
  Future<void> onConnected(BleService ble, String deviceId, ScaleUser user);

  /// Called for each incoming BLE notification on a subscribed characteristic.
  Future<void> onNotification(
    String characteristicUuid,
    List<int> data,
    ScaleUser user,
  );

  /// Called for each advertisement frame (broadcast-only devices).
  void onAdvertisement(Map<String, dynamic> scanData, ScaleUser user);

  /// Called when the device disconnects. Clean up resources here.
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _ble = null;
    _deviceId = null;
    _currentUser = null;
    logger.fine('$name: disposed');
  }

  // ── Protected helpers (use these from concrete drivers) ───────────────

  /// Enable notifications for [characteristicUuid] under [serviceUuid].
  /// Incoming data is forwarded to [onNotification].
  Future<void> setNotifyOn(
    String serviceUuid,
    String characteristicUuid,
  ) async {
    final ble = _ble;
    if (ble == null) {
      logger.warning('$name: setNotifyOn called without BleService');
      return;
    }
    final stream = ble.setNotification(serviceUuid, characteristicUuid);
    final user = _currentUser;
    if (user == null) {
      logger.warning('$name: setNotifyOn called without currentUser');
      return;
    }
    _subscriptions.add(
      stream.listen((data) {
        onNotification(characteristicUuid, data, user);
      }),
    );
    logger.fine('$name: subscribed to $characteristicUuid');
  }

  /// Write [data] to [characteristicUuid] under [serviceUuid].
  Future<void> writeTo(
    String serviceUuid,
    String characteristicUuid,
    List<int> data,
  ) async {
    final ble = _ble;
    if (ble == null) {
      logger.warning('$name: writeTo called without BleService');
      return;
    }
    await ble.writeCharacteristic(serviceUuid, characteristicUuid, data);
  }

  /// Read [characteristicUuid] under [serviceUuid].
  Future<List<int>> readFrom(
    String serviceUuid,
    String characteristicUuid,
  ) async {
    final ble = _ble;
    if (ble == null) {
      logger.warning('$name: readFrom called without BleService');
      return [];
    }
    return ble.readCharacteristic(serviceUuid, characteristicUuid);
  }

  /// Publish a fully parsed measurement to the app.
  void publish(ScaleMeasurement measurement) {
    logger.info('$name: ← publish measurement');
    onMeasurement?.call(measurement);
  }

  /// Request BLE disconnect.
  void requestDisconnect() async {
    logger.fine('$name: → request BLE disconnect');
    final ble = _ble;
    if (ble != null) {
      await ble.disconnect();
    }
  }

  /// Display a user-facing info message.
  void userInfo(String message) {
    onInfo?.call(message);
  }

  // ── Settings helpers ──────────────────────────────────────────────────

  int settingsGetInt(String key, int defaultValue) {
    final v = _settings[key];
    return v is int ? v : defaultValue;
  }

  void settingsPutInt(String key, int value) {
    _settings[key] = value;
  }

  String? settingsGetString(String key, [String? defaultValue]) {
    final v = _settings[key];
    return v is String ? v : defaultValue;
  }

  void settingsPutString(String key, String value) {
    _settings[key] = value;
  }

  void settingsRemove(String key) {
    _settings.remove(key);
  }

  // ── UUID helpers ──────────────────────────────────────────────────────

  /// Build a Bluetooth Base UUID from a 16-bit short UUID.
  /// E.g., `uuid16(0x78B2)` → `"000078b2-0000-1000-8000-00805f9b34fb"`.
  static String uuid16(int short) =>
      '0000${short.toRadixString(16).padLeft(4, '0')}-0000-1000-8000-00805f9b34fb';

  // ── Logging shortcuts ─────────────────────────────────────────────────

  /// Display a user-facing info message.
  void attach(BleService ble, String deviceId, ScaleUser user) {
    _ble = ble;
    _deviceId = deviceId;
    _currentUser = user;
    logger.fine('$name: attached to device $deviceId');
  }

  /// Get current user (available after attach).
  ScaleUser? get currentUser => _currentUser;

  /// Get current device ID (available after attach).
  String? get deviceId => _deviceId;

  /// Get BleService reference (available after attach).
  BleService? get ble => _ble;
}
