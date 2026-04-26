import '../../models/enums.dart';
import '../ble/ble_interface.dart';
import 'byte_utils.dart';
import 'composition/soehnle_lib.dart';
import 'device_support.dart';
import 'scale_driver.dart';
import 'scale_measurement.dart';
import 'scale_user.dart';

/// Driver for Soehnle smart scales (Shape200, Shape100, Shape50, Style100).
///
/// Port of `SoehnleHandler.kt`.
///
/// Protocol overview:
/// - Custom service 352e3000-28e9-40b8-a361-6db4cca4147c combined with
///   standard Battery (0x180F), Current Time (0x1805), and User Data (0x181C).
/// - Per-scale user indices (1..7) mapped to app user IDs.
/// - Body composition calculated from impedance via [SoehnleLib].
class SoehnleDriver extends ScaleDriver {
  @override
  String get name => 'Soehnle';

  @override
  List<String> get serviceUuids => [
    _svcSoehnle,
    _svcBattery,
    _svcCurrentTime,
    _svcUserData,
  ];

  @override
  LinkMode get linkMode => LinkMode.connectGatt;

  // ── UUIDs ─────────────────────────────────────────────────────────────

  // Standard services/characteristics
  static final String _svcBattery = ScaleDriver.uuid16(0x180F);
  static final String _chrBatteryLevel = ScaleDriver.uuid16(0x2A19);

  static final String _svcCurrentTime = ScaleDriver.uuid16(0x1805);
  static final String _chrCurrentTime = ScaleDriver.uuid16(0x2A2B);

  static final String _svcUserData = ScaleDriver.uuid16(0x181C);
  static final String _chrUserControlPoint = ScaleDriver.uuid16(0x2A9F);
  static final String _chrUserAge = ScaleDriver.uuid16(0x2A80);
  static final String _chrUserGender = ScaleDriver.uuid16(0x2A8C);
  static final String _chrUserHeight = ScaleDriver.uuid16(0x2A8E);

  // Soehnle custom service
  static const String _svcSoehnle = '352e3000-28e9-40b8-a361-6db4cca4147c';
  static const String _chrSoehnleA =
      '352e3001-28e9-40b8-a361-6db4cca4147c'; // notify
  static const String _chrSoehnleB =
      '352e3004-28e9-40b8-a361-6db4cca4147c'; // notify
  static const String _chrSoehnleCmd =
      '352e3002-28e9-40b8-a361-6db4cca4147c'; // write

  // ── Device matching ───────────────────────────────────────────────────

  @override
  DeviceSupport? supportFor(String deviceName, int? rssi) {
    final supported =
        deviceName.startsWith('Shape200') ||
        deviceName.startsWith('Shape100') ||
        deviceName.startsWith('Shape50') ||
        deviceName.startsWith('Style100');
    if (!supported) return null;

    return DeviceSupport(name: 'Soehnle Scale', linkMode: LinkMode.connectGatt);
  }

  // ── Connection ────────────────────────────────────────────────────────

  @override
  Future<void> onConnected(
    BleService ble,
    String deviceId,
    ScaleUser user,
  ) async {
    // (0) Optional: factory reset if we have no known mappings at all
    bool anyMapped = false;
    for (int i = 1; i <= 7; i++) {
      if (_loadUserIdForScaleIndex(i) != -1) {
        anyMapped = true;
        break;
      }
    }
    if (!anyMapped) {
      _factoryReset();
    }

    // (1) Battery: subscribe + read once
    await setNotifyOn(_svcBattery, _chrBatteryLevel);
    await readFrom(_svcBattery, _chrBatteryLevel);

    // (2) Write current time (CTS format)
    final now = DateTime.now();
    final year = now.year;
    final timePayload = [
      year & 0xFF, (year >> 8) & 0xFF,
      now.month, now.day, now.hour, now.minute, now.second,
      now.weekday, // 1=Mon..7=Sun
      0x00, // Fractions256
    ];
    await writeTo(_svcCurrentTime, _chrCurrentTime, timePayload);

    // (3) Subscribe to UDS User Control Point
    await setNotifyOn(_svcUserData, _chrUserControlPoint);

    // (4) Ensure user exists on scale
    final scaleIndex = _loadScaleIndexForAppUser(user.id);
    if (scaleIndex == -1) {
      // Create new scale user: [0x01, 0x00, 0x00]
      await writeTo(_svcUserData, _chrUserControlPoint, [0x01, 0x00, 0x00]);
    } else {
      // Select existing scale user
      await writeTo(_svcUserData, _chrUserControlPoint, [
        0x02,
        scaleIndex & 0xFF,
        0x00,
        0x00,
      ]);
    }

    // (5-7) Push profile fields
    await writeTo(_svcUserData, _chrUserAge, [user.age() & 0xFF]);
    await writeTo(_svcUserData, _chrUserGender, [user.isMale ? 0x00 : 0x01]);
    await writeTo(
      _svcUserData,
      _chrUserHeight,
      int16Le(user.bodyHeight.toInt()),
    );

    // (8) Subscribe to custom A/B notifications
    await setNotifyOn(_svcSoehnle, _chrSoehnleA);
    await setNotifyOn(_svcSoehnle, _chrSoehnleB);

    // (9) Request history for indices 1..7
    for (int i = 1; i <= 7; i++) {
      await writeTo(_svcSoehnle, _chrSoehnleCmd, [0x09, i]);
    }
  }

  // ── Notification handling ─────────────────────────────────────────────

  @override
  Future<void> onNotification(
    String characteristicUuid,
    List<int> data,
    ScaleUser user,
  ) async {
    if (data.isEmpty) return;

    if (characteristicUuid == _chrSoehnleA) {
      _handleSoehnleA(data, user);
    } else if (characteristicUuid == _chrUserControlPoint) {
      _handleUserControlPoint(data, user);
    } else if (characteristicUuid == _chrBatteryLevel) {
      _handleBattery(data);
    }
  }

  @override
  void onAdvertisement(Map<String, dynamic> scanData, ScaleUser user) {}

  // ── User index mapping ────────────────────────────────────────────────

  void _saveUserIdForScaleIndex(int scaleIndex, int appUserId) {
    settingsPutInt('userMap/userIdByIndex/$scaleIndex', appUserId);
  }

  int _loadUserIdForScaleIndex(int scaleIndex) {
    return settingsGetInt('userMap/userIdByIndex/$scaleIndex', -1);
  }

  int _loadScaleIndexForAppUser(int appUserId) {
    return settingsGetInt('userMap/scaleIndexByAppUser/$appUserId', -1);
  }

  void _saveScaleIndexForAppUser(int appUserId, int scaleIndex) {
    settingsPutInt('userMap/scaleIndexByAppUser/$appUserId', scaleIndex);
    settingsPutInt('userMap/userIdByIndex/$scaleIndex', appUserId);
  }

  // ── Handlers ──────────────────────────────────────────────────────────

  void _handleBattery(List<int> value) {
    final level = value[0] & 0xFF;
    if (level <= 10) {
      userInfo('Low battery warning: $level%');
    }
  }

  void _handleUserControlPoint(List<int> value, ScaleUser user) {
    if (value.isEmpty || value[0] != 0x20) return;
    final cmd = value.length > 1 ? value[1] & 0xFF : -1;

    if (cmd == 0x01) {
      // User create response
      if (value.length < 4) return;
      final success = value[2];
      final idx = value[3] & 0xFF;
      if (success == 0x01) {
        _saveScaleIndexForAppUser(user.id, idx);
        userInfo('Please step on the scale for a reference measurement');
      } else {
        logger.severe('Soehnle: error creating user');
      }
    } else if (cmd == 0x02) {
      // User select response
      if (value.length < 3) return;
      final success = value[2];
      if (success != 0x01) {
        logger.severe('Soehnle: error selecting user; attempting create');
        writeTo(_svcUserData, _chrUserControlPoint, [0x01, 0x00, 0x00]);
      }
    }
  }

  void _handleSoehnleA(List<int> value, ScaleUser user) {
    // Only handle 0x09 frames of length 15
    if (value.length != 15 || value[0] != 0x09) return;

    final weightKg = u16Be(value, 9) / 10.0;
    final soehnleUserIndex = value[1] & 0xFF;
    final year = u16Be(value, 2);
    final month = value[4] & 0xFF;
    final day = value[5] & 0xFF;
    final hour = value[6] & 0xFF;
    final minute = value[7] & 0xFF;
    final second = value[8] & 0xFF;

    // Dual-frequency impedance values
    final imp5 = u16Be(value, 11);
    final imp50 = u16Be(value, 13);

    final dt = DateTime(year, month, day, hour, minute, second);

    final openScaleUserId = _loadUserIdForScaleIndex(soehnleUserIndex);
    if (openScaleUserId == -1) {
      logger.severe('Unknown Soehnle user index $soehnleUserIndex');
      return;
    }

    // Body composition using the current user's profile
    final activity = _mapActivityLevel(user);
    final lib = SoehnleLib(user.isMale, user.age(), user.bodyHeight, activity);

    final m = ScaleMeasurement(
      userId: openScaleUserId,
      weight: weightKg,
      dateTime: dt,
      water: lib.getWater(weightKg, imp50.toDouble()),
      fat: lib.getFat(weightKg, imp50.toDouble()),
      muscle: lib.getMuscle(weightKg, imp50.toDouble(), imp5.toDouble()),
    );
    publish(m);
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  void _factoryReset() {
    logger.fine('Soehnle: factory reset + clear mappings');
    writeTo(_svcSoehnle, _chrSoehnleCmd, [0x0B, 0xFF]);
    for (int i = 1; i <= 7; i++) {
      _saveUserIdForScaleIndex(i, -1);
    }
  }

  int _mapActivityLevel(ScaleUser user) {
    switch (user.activityLevel) {
      case ActivityLevel.sedentary:
        return 0;
      case ActivityLevel.mild:
        return 1;
      case ActivityLevel.moderate:
        return 2;
      case ActivityLevel.heavy:
        return 4;
      case ActivityLevel.extreme:
        return 5;
    }
  }
}
