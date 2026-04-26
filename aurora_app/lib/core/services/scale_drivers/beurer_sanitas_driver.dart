import 'dart:math';

import 'package:logging/logging.dart';

import '../../models/enums.dart';
import '../ble/ble_interface.dart';
import 'byte_utils.dart';
import 'device_support.dart';
import 'scale_driver.dart';
import 'scale_measurement.dart';
import 'scale_user.dart';

/// Driver for Beurer BF700/800 / Runtastic Libra / Beurer BF710 /
/// Sanitas SBF70 / SilverCrest SBF75 / Crane scales.
///
/// Port of `BeurerSanitasHandler.kt`.
///
/// Protocol overview:
/// - Single custom service/characteristic 0xFFE0/0xFFE1.
/// - Device-specific start byte (high nibble 0xE or 0xF) + command + payload.
/// - 8-step state machine: INIT → SET_TIME → SCALE_STATUS → USER_LIST →
///   SAVED_MEASUREMENTS → ENSURE_USER → USER_DETAILS → FINALIZATION.
/// - Rich user management and ACK protocol.
class BeurerSanitasDriver extends ScaleDriver {
  @override
  String get name => 'BeurerSanitas';

  @override
  List<String> get serviceUuids => [_service];

  @override
  LinkMode get linkMode => LinkMode.connectGatt;

  // ── UUIDs ─────────────────────────────────────────────────────────────

  static final String _service = ScaleDriver.uuid16(0xFFE0);
  static final String _chr = ScaleDriver.uuid16(0xFFE1);

  // ── Device types ──────────────────────────────────────────────────────

  static const String _typeBf700800 = 'BEURER_BF700_800_RT_LIBRA';
  static const String _typeBf710 = 'BEURER_BF710';
  static const String _typeSbf70 = 'SANITAS_SBF70_70';

  // ── Alternative-start nibble identifiers ──────────────────────────────

  static const int _idStartNibbleInit = 6;
  static const int _idStartNibbleCmd = 7;
  static const int _idStartNibbleSetTime = 9;
  static const int _idStartNibbleDisconnect = 10;

  // ── Commands ──────────────────────────────────────────────────────────

  // Command bytes (as unsigned int)
  static const int _cmdSetUnit = 0x4D;
  static const int _cmdScaleStatus = 0x4F;
  static const int _cmdUserAdd = 0x31;
  static const int _cmdUserDelete = 0x32;
  static const int _cmdUserList = 0x33;
  static const int _cmdUserInfo = 0x34;
  static const int _cmdUserUpdate = 0x35;
  static const int _cmdUserDetails = 0x36;
  static const int _cmdDoMeasurement = 0x40;
  static const int _cmdGetSavedMeasurements = 0x41;
  static const int _cmdSavedMeasurement = 0x42;
  static const int _cmdDeleteSavedMeasurements = 0x43;
  static const int _cmdGetUnknownMeasurements = 0x46;
  static const int _cmdWeightMeasurement = 0x58;
  static const int _cmdMeasurement = 0x59;
  static const int _cmdScaleAck = 0xF0;
  static const int _cmdAppAck = 0xF1;

  // ── State ─────────────────────────────────────────────────────────────

  int _waitForDataInStep = -1;
  int _step = 0;
  String? _deviceType;
  int _startByte = 0x00; // unsigned byte value
  final List<_RemoteUser> _remoteUsers = [];
  _RemoteUser? _currentRemoteUser;
  List<int>? _measurementData;
  final _StoredData _storedMeasurement = _StoredData();
  bool _readyForData = false;
  bool _dataReceived = false;

  // ── Device matching ───────────────────────────────────────────────────

  @override
  DeviceSupport? supportFor(String deviceName, int? rssi) {
    final n = deviceName.toLowerCase();

    String? type;
    String display;

    if (n.contains('bf-700') ||
        n.contains('beurer bf700') ||
        n.contains('bf-800') ||
        n.contains('beurer bf800') ||
        n.contains('rt-libra-b') ||
        n.contains('rt-libra-w') ||
        n.contains('libra-b') ||
        n.contains('libra-w')) {
      type = _typeBf700800;
      display = 'Beurer BF700/800 / Runtastic Libra';
    } else if (n.contains('bf700') || n.contains('beurer bf710')) {
      type = _typeBf710;
      display = 'Beurer BF710';
    } else if (n.contains('sanitas sbf70') ||
        n.contains('sbf75') ||
        n.contains('aicdscale1')) {
      type = _typeSbf70;
      display = 'Sanitas SBF70 / SilverCrest SBF75 / Crane';
    } else {
      return null;
    }

    _deviceType = type;
    return DeviceSupport(name: display, linkMode: LinkMode.connectGatt);
  }

  // ── Connection ────────────────────────────────────────────────────────

  @override
  Future<void> onConnected(
    BleService ble,
    String deviceId,
    ScaleUser user,
  ) async {
    // Compute device-specific start byte
    if (_deviceType == _typeBf700800) {
      _startByte = (0xF << 4) | _idStartNibbleCmd;
    } else {
      _startByte = (0xE << 4) | _idStartNibbleCmd;
    }

    // Reset state
    _remoteUsers.clear();
    _currentRemoteUser = null;
    _measurementData = null;
    _storedMeasurement.measurementData = null;
    _storedMeasurement.storedUid = -1;
    _storedMeasurement.candidateUid = -1;
    _readyForData = false;
    _dataReceived = false;
    _waitForDataInStep = -1;
    _step = 0;

    // Subscribe & kick off step flow
    await setNotifyOn(_service, _chr);
    _proceedTo(1);
  }

  // ── Notification handling ─────────────────────────────────────────────

  @override
  Future<void> onNotification(
    String characteristicUuid,
    List<int> data,
    ScaleUser user,
  ) async {
    if (characteristicUuid != _chr || data.isEmpty) return;

    // INIT-ACK uses alternative start byte with nibble 6
    if (data[0] == _getAlternativeStartByte(_idStartNibbleInit)) {
      logger.fine('Received INIT-ACK from scale');
      _waitForDataInStep = -1;
      _proceedTo(2);
      return;
    }

    if (data[0] != _startByte) {
      logger.fine(
        'Unexpected start byte 0x${data[0].toRadixString(16).padLeft(2, '0')}',
      );
      return;
    }

    try {
      final cmd = data.length > 1 ? data[1] & 0xFF : -1;
      switch (cmd) {
        case _cmdUserInfo:
          _processUserInfo(data, user);
        case _cmdSavedMeasurement:
          _processSavedMeasurement(data, user);
        case _cmdWeightMeasurement:
          _processWeightMeasurement(data);
        case _cmdMeasurement:
          _processMeasurement(data, user);
        case _cmdScaleAck:
          _processScaleAck(data, user);
        default:
          logger.fine(
            'Unknown command 0x${cmd.toRadixString(16).padLeft(2, '0')}',
          );
      }
    } catch (e) {
      logger.severe('Parse error: $e');
    }
  }

  @override
  void onAdvertisement(Map<String, dynamic> scanData, ScaleUser user) {}

  // ── Step controller ───────────────────────────────────────────────────

  void _proceedTo(int next) {
    _step = next;
    switch (_step) {
      case 1:
        // Say hello → wait for INIT-ACK
        _waitForDataInStep = 1;
        _sendAlternativeStartCode(_idStartNibbleInit, [0x01]);

      case 2:
        // Set time (no ACK required)
        final unix = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        _sendAlternativeStartCode(_idStartNibbleSetTime, int32Be(unix));
        _proceedTo(3);

      case 3:
        // Ask scale status → expect ACK
        _waitForDataInStep = 3;
        _sendCommand(_cmdScaleStatus, _encodeUserId(null));

      case 4:
        // Request user list → expect list then ACKs
        _waitForDataInStep = 4;
        _sendCommand(_cmdUserList);

      case 5:
        // Iterate remote users, request saved measurements
        final nextIdx = _currentRemoteUser != null
            ? _remoteUsers.indexOf(_currentRemoteUser!) + 1
            : 0;
        _currentRemoteUser = null;
        for (int i = nextIdx; i < _remoteUsers.length; i++) {
          if (_remoteUsers[i].localUserId != -1) {
            _currentRemoteUser = _remoteUsers[i];
            break;
          }
        }
        if (_currentRemoteUser != null) {
          _waitForDataInStep = 5;
          _sendCommand(
            _cmdGetSavedMeasurements,
            _encodeUserId(_currentRemoteUser),
          );
        } else {
          _proceedTo(6);
        }

      case 6:
        // Ensure remote user entry for the selected local user
        final user = currentUser;
        if (user == null) return;
        final mapped = _remoteUsers
            .where((ru) => ru.localUserId == user.id)
            .firstOrNull;
        if (mapped == null) {
          _waitForDataInStep = 6;
          _createRemoteUser(user);
        } else {
          _currentRemoteUser = mapped;
          _proceedTo(7);
        }

      case 7:
        // Request user details → expect ACK
        if (_currentRemoteUser != null) {
          _waitForDataInStep = 7;
          _sendCommand(_cmdUserDetails, _encodeUserId(_currentRemoteUser));
        } else {
          _proceedTo(8);
        }

      case 8:
        // Finalization
        final user = currentUser;
        if (user == null) return;

        if (_storedMeasurement.measurementData != null) {
          final uidOwner = _currentRemoteUser?.localUserId ?? user.id;
          _addMeasurement(_storedMeasurement.measurementData!, uidOwner);
          _storedMeasurement.measurementData = null;
        } else if (!_dataReceived &&
            _currentRemoteUser != null &&
            !_currentRemoteUser!.isNew) {
          _waitForDataInStep = 8;
          userInfo('Please step on the scale');
          _sendCommand(_cmdDoMeasurement, _encodeUserId(_currentRemoteUser));
        }
    }
  }

  // ── Incoming processing ───────────────────────────────────────────────

  void _processUserInfo(List<int> data, ScaleUser user) {
    final count = data.length > 2 ? data[2] & 0xFF : 0;
    final current = data.length > 3 ? data[3] & 0xFF : 0;

    if (_remoteUsers.length == current - 1) {
      final name = _decodeString(data, 12, 3);
      final year = 1900 + (data.length > 15 ? data[15] & 0xFF : 0);
      _remoteUsers.add(_RemoteUser(_decodeUserId(data, 4), name, year));
    }

    _sendAck(data);

    if (current != count) return;

    // Map remote users to local users
    for (final local in [user]) {
      final localName = _convertUserNameToScale(local);
      final year = local.birthday.year;
      for (final ru in _remoteUsers) {
        if (localName.startsWith(ru.name) && year == ru.year) {
          ru.localUserId = local.id;
          break;
        }
      }
    }

    _waitForDataInStep = -1;
    _proceedTo(5);
  }

  void _processSavedMeasurement(List<int> data, ScaleUser user) {
    final count = data.length > 2 ? data[2] & 0xFF : 0;
    final current = data.length > 3 ? data[3] & 0xFF : 0;

    _processMeasurementData(
      data,
      4,
      firstPart: current % 2 == 1,
      processingSaved: true,
    );

    _sendAck(data);

    if (current != count) return;

    if (_waitForDataInStep != 5) {
      if (_waitForDataInStep >= 0) {
        _proceedTo(max(_step - 1, 1));
      }
      return;
    }

    _readyForData = true;
    if (_currentRemoteUser != null) {
      _sendCommand(
        _cmdDeleteSavedMeasurements,
        _encodeUserId(_currentRemoteUser),
      );
    }
  }

  void _processWeightMeasurement(List<int> data) {
    final stable = data.length > 2 && data[2] == 0;
    final weight = _getKiloGram(data, 3);
    if (!stable) {
      userInfo('Measuring weight: ${weight.toStringAsFixed(2)} kg');
    } else {
      logger.info(
        'Stable weight (only weight frame): ${weight.toStringAsFixed(2)}',
      );
    }
  }

  void _processMeasurement(List<int> data, ScaleUser user) {
    final count = data.length > 2 ? data[2] & 0xFF : 0;
    final current = data.length > 3 ? data[3] & 0xFF : 0;

    if (current == 1) {
      final uid = _decodeUserId(data, 5);
      _storedMeasurement.candidateUid = uid;
      _currentRemoteUser = _remoteUsers
          .where((ru) => ru.remoteUserId == uid)
          .firstOrNull;
    } else {
      _processMeasurementData(
        data,
        4,
        firstPart: current == 2,
        processingSaved: false,
      );
    }

    _sendAck(data);

    if (current != count) return;

    if (_currentRemoteUser != null && _readyForData) {
      _sendCommand(
        _cmdDeleteSavedMeasurements,
        _encodeUserId(_currentRemoteUser),
      );
      return;
    }

    if (_waitForDataInStep == 6 || _waitForDataInStep == 8) {
      _proceedTo(_step + 1);
    } else if (_waitForDataInStep >= 0) {
      _proceedTo(max(_step - 1, 1));
    }
  }

  void _processScaleAck(List<int> data, ScaleUser selectedUser) {
    if (data.length < 3) return;
    final ackCmd = data[2] & 0xFF;

    switch (ackCmd) {
      case _cmdScaleStatus:
        if (data.length < 12) return;
        final batteryLevel = data[4] & 0xFF;
        final currentUnit = data[7] & 0xFF;

        if (batteryLevel <= 10) {
          userInfo('Low battery warning: $batteryLevel%');
        }

        final desiredUnit = selectedUser.scaleUnit == UnitType.kg
            ? 1
            : selectedUser.scaleUnit == UnitType.lb
            ? 2
            : 4; // st

        if (desiredUnit != currentUnit) {
          _sendCommand(_cmdSetUnit, [desiredUnit]);
        } else {
          _waitForDataInStep = -1;
          _proceedTo(4);
        }

      case _cmdSetUnit:
        _waitForDataInStep = -1;
        _proceedTo(4);

      case _cmdUserList:
        if (data.length < 6) return;
        final userCount = data[4] & 0xFF;
        if (userCount == 0) {
          _waitForDataInStep = -1;
          _proceedTo(5);
        }

      case _cmdGetSavedMeasurements:
        if (data.length < 4) return;
        final measurementCount = data[3] & 0xFF;
        if (measurementCount == 0) {
          _readyForData = true;
          _waitForDataInStep = -1;
          _proceedTo(6);
        }

      case _cmdDeleteSavedMeasurements:
        _waitForDataInStep = -1;
        if (_step < 6) {
          _proceedTo(6);
        } else {
          _proceedTo(8);
        }

      case _cmdUserAdd:
        if (data.length > 3 && data[3] == 0x00) {
          if (_currentRemoteUser != null) {
            _currentRemoteUser!.isNew = true;
            if (_storedMeasurement.measurementData != null) {
              _addMeasurement(
                _storedMeasurement.measurementData!,
                _currentRemoteUser!.localUserId,
              );
              _storedMeasurement.measurementData = null;
            }
            _readyForData = true;
            userInfo('Please step on the scale for a reference measurement');
            _sendCommand(_cmdDoMeasurement, _encodeUserId(_currentRemoteUser));
            _waitForDataInStep = 6;
          } else {
            _proceedTo(7);
          }
        }

      case _cmdDoMeasurement:
        if (data.length > 3 && data[3] != 0x00) {
          _waitForDataInStep = -1;
          _proceedTo(7);
        } else {
          userInfo('Please step on the scale');
        }

      case _cmdUserDetails:
        _waitForDataInStep = -1;
        _proceedTo(8);

      default:
        logger.fine(
          'Unhandled ACK for 0x${ackCmd.toRadixString(16).padLeft(2, '0')}',
        );
    }
  }

  // ── Measurement data assembly ─────────────────────────────────────────

  void _processMeasurementData(
    List<int> data,
    int offset, {
    required bool firstPart,
    required bool processingSaved,
  }) {
    if (firstPart) {
      _measurementData = data.sublist(offset);
      return;
    }

    final existing = _measurementData;
    if (existing == null) return;

    final merged = [...existing, ...data.sublist(offset)];

    final ru = _currentRemoteUser;
    if (ru != null && (_readyForData || processingSaved)) {
      _addMeasurement(merged, ru.localUserId);
      _dataReceived = true;

      // Check for duplicate with deferred data
      if (_storedMeasurement.measurementData != null &&
          ru.remoteUserId == _storedMeasurement.storedUid) {
        final tsA = u32Be(merged, 0);
        final tsB = u32Be(_storedMeasurement.measurementData!, 0);
        if (tsA == tsB) {
          _storedMeasurement.measurementData = null;
        }
      }
      _measurementData = null;
      _storedMeasurement.measurementData = null;
    } else if (!processingSaved) {
      _storedMeasurement.measurementData = merged;
      _storedMeasurement.storedUid = _storedMeasurement.candidateUid;
    } else {
      _measurementData = null;
    }
  }

  void _addMeasurement(List<int> buf, int userId) {
    final timestampMs = u32Be(buf, 0) * 1000;
    final weight = _getKiloGram(buf, 4);
    // impedance at offset 6 (FYI, not stored)
    final fat = _getPercent(buf, 8);
    final water = _getPercent(buf, 10);
    final muscle = _getPercent(buf, 12);
    final bone = _getKiloGram(buf, 14);

    final m = ScaleMeasurement(
      userId: userId,
      dateTime: DateTime.fromMillisecondsSinceEpoch(timestampMs),
      weight: weight,
      fat: fat,
      water: water,
      muscle: muscle,
      bone: bone,
    );
    publish(m);
  }

  // ── Value parsing helpers ─────────────────────────────────────────────

  /// Unit is 50g → kg
  double _getKiloGram(List<int> data, int offset) {
    return u16Be(data, offset) * 50.0 / 1000.0;
  }

  /// Unit is 0.1%
  double _getPercent(List<int> data, int offset) {
    return u16Be(data, offset) / 10.0;
  }

  int _decodeUserId(List<int> data, int offset) {
    final high = u32Be(data, offset);
    final low = u32Be(data, offset + 4);
    return (high << 32) | (low & 0xFFFFFFFF);
  }

  List<int> _encodeUserId(_RemoteUser? remoteUser) {
    final uid = remoteUser?.remoteUserId ?? 0;
    final out = List.filled(8, 0);
    writeU32Be(out, 0, (uid >> 32) & 0xFFFFFFFF);
    writeU32Be(out, 4, uid & 0xFFFFFFFF);
    return out;
  }

  String _decodeString(List<int> data, int offset, int maxLen) {
    int len = 0;
    while (len < maxLen &&
        offset + len < data.length &&
        data[offset + len] != 0) {
      len++;
    }
    return String.fromCharCodes(data.sublist(offset, offset + len));
  }

  String _convertUserNameToScale(ScaleUser user) {
    final n = user.name.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    if (n.isEmpty) return '${user.id}';
    return n.toUpperCase();
  }

  // ── Outgoing writes ───────────────────────────────────────────────────

  void _writeBytes(List<int> raw) {
    writeTo(_service, _chr, raw);
  }

  void _sendCommand(int command, [List<int>? params]) {
    final p = params ?? [];
    _writeBytes([_startByte, command, ...p]);
  }

  void _sendAck(List<int> incoming) {
    // Echo bytes [1..3] (cmd + seq)
    final echo = incoming.length >= 4
        ? incoming.sublist(1, 4)
        : incoming.sublist(1);
    _writeBytes([_startByte, _cmdAppAck, ...echo]);
  }

  void _sendAlternativeStartCode(int idNibble, List<int> payload) {
    final alt = _getAlternativeStartByte(idNibble);
    _writeBytes([alt, ...payload]);
  }

  int _getAlternativeStartByte(int startNibble) {
    return (_startByte & 0xF0) | (startNibble & 0x0F);
  }

  // ── Remote user creation ──────────────────────────────────────────────

  void _createRemoteUser(ScaleUser scaleUser) {
    final nick = _convertUserNameToScale(scaleUser);
    final nickBytes = nick.codeUnits;
    // Pad/trim to 3 bytes
    final paddedNick = List.filled(3, 0);
    for (int i = 0; i < 3 && i < nickBytes.length; i++) {
      paddedNick[i] = nickBytes[i];
    }

    final cal = scaleUser.birthday;
    final year = (cal.year - 1900) & 0xFF;
    final month = (cal.month - 1) & 0xFF; // 0..11
    final day = cal.day & 0xFF;
    final height = scaleUser.bodyHeight.toInt() & 0xFF;
    final sex = scaleUser.isMale ? 0x80 : 0x00;
    final activity = (scaleUser.activityLevel.value + 1) & 0xFF; // 1..5

    // Choose new remote UID (max + 1 with floor 100)
    var maxUid = _remoteUsers.isEmpty ? 100 : 0;
    for (final ru in _remoteUsers) {
      maxUid = max(maxUid, ru.remoteUserId);
    }
    final newRemote = _RemoteUser(
      maxUid + 1,
      String.fromCharCodes(paddedNick),
      1900 + year,
      localUserId: scaleUser.id,
      isNew: true,
    );
    _currentRemoteUser = newRemote;

    final uid = _encodeUserId(newRemote);

    _sendCommand(_cmdUserAdd, [
      ...uid,
      paddedNick[0],
      paddedNick[1],
      paddedNick[2],
      year,
      month,
      day,
      height,
      sex | activity,
    ]);
  }
}

/// Remote user descriptor projected from the scale.
class _RemoteUser {
  final int remoteUserId;
  final String name;
  final int year;
  int localUserId;
  bool isNew;

  _RemoteUser(
    this.remoteUserId,
    this.name,
    this.year, {
    this.localUserId = -1,
    this.isNew = false,
  });
}

/// Temporary buffer for multi-part measurement payloads.
class _StoredData {
  List<int>? measurementData;
  int storedUid;
  int candidateUid;

  _StoredData({
    this.measurementData,
    this.storedUid = -1,
    this.candidateUid = -1,
  });
}
