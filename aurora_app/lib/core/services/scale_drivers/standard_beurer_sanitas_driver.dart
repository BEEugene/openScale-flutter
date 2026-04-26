import '../../models/enums.dart';
import '../ble/ble_interface.dart';
import 'byte_utils.dart';
import 'device_support.dart';
import 'scale_driver.dart';
import 'scale_measurement.dart';
import 'scale_user.dart';

/// Driver for Beurer BF105/720, BF950, BF500, BF600 scales using the
/// standard Bluetooth Weight Profile plus vendor-specific extensions.
///
/// Port of `StandardBeurerSanitasHandler.kt`.
///
/// Protocol overview:
/// - Uses standard BLE Weight Scale Service (0x181D), Body Composition
///   Service (0x181B), and User Data Service (0x181C) for measurement.
/// - Vendor-specific service (0xFFFF or 0xFFF0) for user list management,
///   activity level, initials, and target weight.
/// - Model-specific characteristic profiles for each supported scale.
class StandardBeurerSanitasDriver extends ScaleDriver {
  @override
  String get name => 'StandardBeurerSanitas';

  @override
  List<String> get serviceUuids => [
    ScaleDriver.uuid16(0x181D),
    ScaleDriver.uuid16(0x181B),
    ScaleDriver.uuid16(0x181C),
    ScaleDriver.uuid16(0x1805),
    ScaleDriver.uuid16(0x180F),
  ];

  @override
  LinkMode get linkMode => LinkMode.connectGatt;

  // ── Standard service UUIDs ────────────────────────────────────────────

  static final String _svcCurrentTime = ScaleDriver.uuid16(0x1805);
  static final String _chrCurrentTime = ScaleDriver.uuid16(0x2A2B);

  static final String _svcWeightScale = ScaleDriver.uuid16(0x181D);
  static final String _chrWeightMeasurement = ScaleDriver.uuid16(0x2A9D);

  static final String _svcBodyComposition = ScaleDriver.uuid16(0x181B);
  static final String _chrBodyCompositionMeas = ScaleDriver.uuid16(0x2A9C);

  static final String _svcUserData = ScaleDriver.uuid16(0x181C);
  static final String _chrUserControlPoint = ScaleDriver.uuid16(0x2A9F);
  static final String _chrDatabaseChangeIncrement = ScaleDriver.uuid16(0x2A99);
  static final String _chrUserDateOfBirth = ScaleDriver.uuid16(0x2A85);
  static final String _chrUserGender = ScaleDriver.uuid16(0x2A8C);
  static final String _chrUserHeight = ScaleDriver.uuid16(0x2A8E);

  static final String _svcBattery = ScaleDriver.uuid16(0x180F);
  static final String _chrBatteryLevel = ScaleDriver.uuid16(0x2A19);

  // ── Model detection ───────────────────────────────────────────────────

  static const String _modelBf105 = 'BEURER_BF105';
  static const String _modelBf950 = 'BEURER_BF950';
  static const String _modelBf500 = 'BEURER_BF500';
  static const String _modelBf600 = 'BEURER_BF600';

  /// Vendor-specific profile per model.
  _VendorProfile? _profile;
  String? _friendlyName;
  String? _activeModel;

  // ── Measurement merge state ───────────────────────────────────────────

  ScaleMeasurement? _pendingMeasurement;
  final List<ScaleUser> _scaleUserList = [];

  // ── Device matching ───────────────────────────────────────────────────

  @override
  DeviceSupport? supportFor(String deviceName, int? rssi) {
    final name = deviceName.toLowerCase();

    String model;
    String display;
    _VendorProfile profile;

    if (name.contains('bf105') || name.contains('bf720')) {
      model = _modelBf105;
      display = 'Beurer BF105/720';
      profile = _VendorProfile(
        service: ScaleDriver.uuid16(0xFFFF),
        chrUserList: ScaleDriver.uuid16(0x0001),
        chrActivity: ScaleDriver.uuid16(0x0004),
        chrTakeMeasurement: ScaleDriver.uuid16(0x0006),
        chrInitials: ScaleDriver.uuid16(0x0002),
        chrTargetWeight: ScaleDriver.uuid16(0x0003),
      );
    } else if (name.contains('bf950') ||
        name.contains('sbf77') ||
        name.contains('sbf76')) {
      model = _modelBf950;
      display = 'Beurer BF950';
      profile = _VendorProfile(
        service: ScaleDriver.uuid16(0xFFFF),
        chrUserList: ScaleDriver.uuid16(0x0001),
        chrActivity: ScaleDriver.uuid16(0x0004),
        chrTakeMeasurement: ScaleDriver.uuid16(0x0006),
        chrInitials: ScaleDriver.uuid16(0x0002),
        chrTargetWeight: null,
      );
    } else if (name.contains('bf500')) {
      model = _modelBf500;
      display = 'Beurer BF500';
      profile = _VendorProfile(
        service: ScaleDriver.uuid16(0xFFFF),
        chrUserList: ScaleDriver.uuid16(0xFFF1),
        chrActivity: ScaleDriver.uuid16(0xFFF2),
        chrTakeMeasurement: ScaleDriver.uuid16(0xFFF4),
        chrInitials: null,
        chrTargetWeight: null,
      );
    } else if (name.contains('bf600') || name.contains('bf850')) {
      model = _modelBf600;
      display = 'Beurer BF600';
      profile = _VendorProfile(
        service: ScaleDriver.uuid16(0xFFF0),
        chrUserList: ScaleDriver.uuid16(0xFFF2),
        chrActivity: ScaleDriver.uuid16(0xFFF3),
        chrTakeMeasurement: ScaleDriver.uuid16(0xFFF4),
        chrInitials: ScaleDriver.uuid16(0xFFF6),
        chrTargetWeight: null,
      );
    } else {
      return null;
    }

    _activeModel = model;
    _profile = profile;
    _friendlyName = display;

    return DeviceSupport(name: display, linkMode: LinkMode.connectGatt);
  }

  // ── Connection ────────────────────────────────────────────────────────

  @override
  Future<void> onConnected(
    BleService ble,
    String deviceId,
    ScaleUser user,
  ) async {
    // Subscribe to standard weight & body composition notifications
    await setNotifyOn(_svcWeightScale, _chrWeightMeasurement);
    await setNotifyOn(_svcBodyComposition, _chrBodyCompositionMeas);
    await setNotifyOn(_svcUserData, _chrDatabaseChangeIncrement);
    await setNotifyOn(_svcUserData, _chrUserControlPoint);
    await setNotifyOn(_svcBattery, _chrBatteryLevel);

    // Align device clock (best-effort)
    await writeTo(_svcCurrentTime, _chrCurrentTime, _buildCurrentTimePayload());

    // Read battery level
    await readFrom(_svcBattery, _chrBatteryLevel);

    // Vendor-specific: user list notifications
    final p = _profile;
    if (p != null) {
      await setNotifyOn(p.service, p.chrUserList);
      await writeTo(p.service, p.chrUserList, [0x00]);

      // Write activity level
      final lvl = (user.activityLevel.value + 1).clamp(1, 5);
      await writeTo(p.service, p.chrActivity, [lvl]);

      // Write initials
      if (p.chrInitials != null) {
        final raw = user.name.toUpperCase().replaceAll(
          RegExp(r'[^A-Z0-9]'),
          '',
        );
        final initials = raw.length > 3 ? raw.substring(0, 3) : raw;
        if (initials.isNotEmpty) {
          await writeTo(p.service, p.chrInitials!, initials.codeUnits.toList());
        }
      }

      // Write target weight
      if (p.chrTargetWeight != null) {
        final goal = user.goalWeight.toInt();
        await writeTo(p.service, p.chrTargetWeight!, [
          (goal >> 8) & 0xFF,
          goal & 0xFF,
        ]);
      }
    }

    userInfo('Please step on the scale');
  }

  // ── Notification handling ─────────────────────────────────────────────

  @override
  Future<void> onNotification(
    String characteristicUuid,
    List<int> data,
    ScaleUser user,
  ) async {
    final p = _profile;

    // Vendor-specific user list
    if (p != null && characteristicUuid == p.chrUserList) {
      _handleUserList(data, user);
      return;
    }

    // Standard weight measurement
    if (characteristicUuid == _chrWeightMeasurement) {
      _handleWeightMeasurement(data, user);
      return;
    }

    // Standard body composition measurement
    if (characteristicUuid == _chrBodyCompositionMeas) {
      _handleBodyCompositionMeasurement(data, user);
      return;
    }

    // UDS User Control Point
    if (characteristicUuid == _chrUserControlPoint) {
      logger.fine('UCP indication: ${hexPreview(data, 16)}');
      return;
    }

    // Battery level
    if (characteristicUuid == _chrBatteryLevel && data.isNotEmpty) {
      final level = data[0] & 0xFF;
      logger.fine('Battery level: $level%');
      if (level <= 10) {
        userInfo('Low battery warning: $level%');
      }
      return;
    }
  }

  @override
  void onAdvertisement(Map<String, dynamic> scanData, ScaleUser user) {}

  @override
  void dispose() {
    _pendingMeasurement = null;
    _scaleUserList.clear();
    super.dispose();
  }

  // ── Vendor user list handling ─────────────────────────────────────────

  void _handleUserList(List<int> data, ScaleUser user) {
    if (data.isEmpty) return;
    final status = data[0] & 0xFF;

    if (status == 2) {
      // No user on scale
      logger.fine('No user on scale');
      return;
    }

    if (status == 1) {
      // User list complete
      logger.fine('User list received');
      return;
    }

    // Normal user data: parse scale user entry
    if (data.length < 10) return;

    final index = data.length > 1 ? data[1] & 0xFF : 0;

    // Parse initials (3 bytes starting at offset 2)
    final rawInitials = data.sublist(2, 5);
    String initials = '';
    for (final b in rawInitials) {
      if (b != 0 && b != 0xFF) initials += String.fromCharCode(b);
    }
    if (initials.length == 3 &&
        rawInitials[0] == 0xFF &&
        rawInitials[1] == 0xFF &&
        rawInitials[2] == 0xFF) {
      initials = 'unknown';
    }

    // Parse user data at fixed offset 5
    if (data.length < 11) return;
    final year = u16Be(data, 5);
    final month = data[7] & 0xFF;
    final day = data[8] & 0xFF;
    final height = data[9] & 0xFF;
    final gender = data.length > 10 ? data[10] & 0xFF : 0;
    final activityLevel = data.length > 11 ? data[11] & 0xFF : 1;

    final birthday = DateTime(year, month, day);
    final scaleUser = ScaleUser(
      id: index,
      name: initials,
      birthday: birthday,
      bodyHeight: height.toDouble(),
      gender: gender == 0 ? Gender.male : Gender.female,
      activityLevel: ActivityLevel.fromInt((activityLevel - 1).clamp(0, 4)),
    );
    _scaleUserList.add(scaleUser);
    logger.fine('Scale user added: $scaleUser');
  }

  // ── Standard weight measurement parsing ───────────────────────────────

  void _handleWeightMeasurement(List<int> data, ScaleUser user) {
    final m = _parseWeightToMeasurement(data);
    if (m == null) return;
    _handleNewMeasurement(m);
  }

  void _handleBodyCompositionMeasurement(List<int> data, ScaleUser user) {
    final m = _parseBodyCompToMeasurement(data);
    if (m == null) return;
    _handleNewMeasurement(m);
  }

  void _handleNewMeasurement(ScaleMeasurement newM) {
    final prev = _pendingMeasurement;

    if (prev == null) {
      _pendingMeasurement = newM;
      return;
    }

    // Merge and publish when weight is present
    final merged = prev.mergeWith(newM);
    if (merged.hasWeight()) {
      publish(_transformBeforePublish(merged));
      _pendingMeasurement = null;
    } else {
      _pendingMeasurement = merged;
    }
  }

  /// Transform water from absolute mass to percentage before publishing.
  ScaleMeasurement _transformBeforePublish(ScaleMeasurement m) {
    final w = m.weight > 0 ? m.weight : 1.0;
    final waterPct = (m.water / w) * 100.0;
    return m.copyWith(water: waterPct);
  }

  /// Parse standard Weight Measurement characteristic (0x2A9D).
  ScaleMeasurement? _parseWeightToMeasurement(List<int> value) {
    if (value.isEmpty) return null;
    int offset = 0;

    final flags = value[offset] & 0xFF;
    offset += 1;
    final isKg = (flags & 0x01) == 0;
    final tsPresent = (flags & 0x02) != 0;
    final userPresent = (flags & 0x04) != 0;

    // 0x08 = BMI/Height present
    final multiplier = isKg ? 0.005 : 0.01;
    final weightRaw = u16Le(value, offset);
    offset += 2;

    DateTime? dt;
    int userId = 0xFF;

    if (tsPresent && offset + 6 <= value.length) {
      final year = u16Le(value, offset);
      offset += 2;
      final month = value[offset] & 0xFF;
      offset += 1;
      final day = value[offset] & 0xFF;
      offset += 1;
      final hour = value[offset] & 0xFF;
      offset += 1;
      final minute = value[offset] & 0xFF;
      offset += 1;
      final second = value[offset] & 0xFF;
      offset += 1;
      dt = DateTime(year, month, day, hour, minute, second);
    }

    if (userPresent && offset < value.length) {
      final scaleUserIndex = value[offset] & 0xFF;
      offset += 1;
      final appId = _loadUserIdForScaleIndex(scaleUserIndex);
      if (appId != -1) userId = appId;
    }

    return ScaleMeasurement(
      weight: weightRaw * multiplier,
      dateTime: dt,
      userId: userId,
    );
  }

  /// Parse standard Body Composition Measurement characteristic (0x2A9C).
  ScaleMeasurement? _parseBodyCompToMeasurement(List<int> value) {
    if (value.length < 4) return null;
    int offset = 0;

    final flags = u16Le(value, offset);
    offset += 2;
    final tsPresent = (flags & 0x0002) != 0;
    final userPresent = (flags & 0x0004) != 0;
    final musclePctPresent = (flags & 0x0010) != 0;
    final waterMassPresent = (flags & 0x0100) != 0;
    final weightPresent = (flags & 0x0400) != 0;
    final massMultiplier = ((flags & 0x0001) == 0) ? 0.005 : 0.01;

    // Body fat percentage (always present in body composition)
    final bodyFatPct = u16Le(value, offset) * 0.1;
    offset += 2;

    DateTime? dt;
    int userId = 0xFF;

    if (tsPresent && offset + 6 <= value.length) {
      final year = u16Le(value, offset);
      offset += 2;
      final month = value[offset] & 0xFF;
      offset += 1;
      final day = value[offset] & 0xFF;
      offset += 1;
      final hour = value[offset] & 0xFF;
      offset += 1;
      final minute = value[offset] & 0xFF;
      offset += 1;
      final second = value[offset] & 0xFF;
      offset += 1;
      dt = DateTime(year, month, day, hour, minute, second);
    }

    if (userPresent && offset < value.length) {
      final scaleUserIndex = value[offset] & 0xFF;
      offset += 1;
      final appId = _loadUserIdForScaleIndex(scaleUserIndex);
      if (appId != -1) userId = appId;
    }

    // Skip BMR if present (0x0008)
    if ((flags & 0x0008) != 0 && offset + 2 <= value.length) {
      offset += 2;
    }

    // Muscle percentage
    double muscle = 0.0;
    if (musclePctPresent && offset + 2 <= value.length) {
      muscle = u16Le(value, offset) * 0.1;
      offset += 2;
    }

    // Skip muscle mass (0x0020), fat-free mass (0x0040), soft lean (0x0080)
    if ((flags & 0x0020) != 0 && offset + 2 <= value.length) offset += 2;
    if ((flags & 0x0040) != 0 && offset + 2 <= value.length) offset += 2;

    // Soft lean mass for LBM/bone derivation
    double softLean = 0.0;
    final softLeanPresent = (flags & 0x0080) != 0;
    if (softLeanPresent && offset + 2 <= value.length) {
      softLean = u16Le(value, offset) * massMultiplier;
      offset += 2;
    }

    // Water mass
    double water = 0.0;
    if (waterMassPresent && offset + 2 <= value.length) {
      water = u16Le(value, offset) * massMultiplier;
      offset += 2;
    }

    // Impedance (0x0200)
    if ((flags & 0x0200) != 0 && offset + 2 <= value.length) {
      offset += 2;
    }

    // Weight
    double weight = 0.0;
    if (weightPresent && offset + 2 <= value.length) {
      weight = u16Le(value, offset) * massMultiplier;
      offset += 2;
    }

    // Derive LBM and bone from soft lean mass
    double lbm = 0.0;
    double bone = 0.0;
    if (weight > 0 && softLeanPresent) {
      final fatMass = weight * (bodyFatPct / 100.0);
      lbm = weight - fatMass;
      bone = lbm - softLean;
    }

    return ScaleMeasurement(
      weight: weight,
      fat: bodyFatPct,
      water: water,
      muscle: muscle,
      lbm: lbm,
      bone: bone,
      dateTime: dt,
      userId: userId,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  List<int> _buildCurrentTimePayload() {
    final now = DateTime.now();
    final year = now.year;
    // Day of week: DateTime.monday=1..DateTime.sunday=7 → BLE: 1=Mon..7=Sun
    final dayOfWeek = now.weekday;
    return [
      year & 0xFF, (year >> 8) & 0xFF,
      now.month, now.day, now.hour, now.minute, now.second,
      dayOfWeek,
      0x00, // Fractions256
      0x00, // AdjustReason
    ];
  }

  int _loadUserIdForScaleIndex(int scaleIndex) {
    return settingsGetInt('userMap/userIdByIndex/$scaleIndex', -1);
  }

  void _saveUserIdForScaleIndex(int scaleIndex, int appUserId) {
    settingsPutInt('userMap/userIdByIndex/$scaleIndex', appUserId);
  }
}

/// Vendor-specific characteristic profile per Beurer model.
class _VendorProfile {
  final String service;
  final String chrUserList;
  final String chrActivity;
  final String chrTakeMeasurement;
  final String? chrInitials;
  final String? chrTargetWeight;

  const _VendorProfile({
    required this.service,
    required this.chrUserList,
    required this.chrActivity,
    required this.chrTakeMeasurement,
    this.chrInitials,
    this.chrTargetWeight,
  });
}
