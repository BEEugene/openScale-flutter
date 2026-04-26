import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:openscale/core/services/ble/ble_interface.dart';
import 'package:openscale/core/services/ble/ble_mock.dart';

void main() {
  group('BleMock', () {
    late BleMock bleMock;

    setUp(() {
      bleMock = BleMock();
    });

    tearDown(() {
      bleMock.dispose();
    });

    group('startScan', () {
      test('emits mock devices through scannedDevices stream', () async {
        final devices = <BleDevice>[];
        final subscription = bleMock.scannedDevices.listen(devices.add);

        await bleMock.startScan(const Duration(seconds: 5));

        // Allow stream to emit
        await Future<void>.delayed(const Duration(milliseconds: 1500));

        expect(devices.length, 3);
        expect(devices[0].id, 'mock-scale-001');
        expect(devices[0].name, 'openScale Mock Scale');
        expect(devices[1].id, 'mock-scale-002');
        expect(devices[1].name, 'Xiaomi Mi Scale');
        expect(devices[2].id, 'mock-scale-003');
        expect(devices[2].name, 'Beurer BF700');

        await subscription.cancel();
      });

      test('each device has a valid rssi value', () async {
        final devices = <BleDevice>[];
        final subscription = bleMock.scannedDevices.listen(devices.add);

        await bleMock.startScan(const Duration(seconds: 5));
        await Future<void>.delayed(const Duration(milliseconds: 1500));

        for (final device in devices) {
          expect(device.rssi, isNonPositive);
          expect(device.rssi, isNonZero);
        }

        await subscription.cancel();
      });
    });

    group('connect/disconnect', () {
      test('connect emits true on isConnected stream', () async {
        final connectionStates = <bool>[];
        final subscription = bleMock.isConnected.listen(connectionStates.add);

        await bleMock.connect('mock-scale-001');
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(connectionStates, contains(true));

        await subscription.cancel();
      });

      test('disconnect emits false on isConnected stream', () async {
        final connectionStates = <bool>[];
        final subscription = bleMock.isConnected.listen(connectionStates.add);

        await bleMock.connect('mock-scale-001');
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await bleMock.disconnect();
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(connectionStates, contains(true));
        expect(connectionStates, contains(false));

        await subscription.cancel();
      });
    });

    group('readCharacteristic', () {
      test('returns a list of integers', () async {
        final data = await bleMock.readCharacteristic(
          'service-uuid',
          'char-uuid',
        );

        expect(data, isA<List<int>>());
        expect(data.length, 16);
      });

      test('returns sequential integers from 0 to 15', () async {
        final data = await bleMock.readCharacteristic(
          'service-uuid',
          'char-uuid',
        );

        for (var i = 0; i < 16; i++) {
          expect(data[i], i);
        }
      });
    });

    group('writeCharacteristic', () {
      test('completes without error', () async {
        // Should not throw
        await bleMock.writeCharacteristic('service-uuid', 'char-uuid', [
          1,
          2,
          3,
          4,
        ]);
      });
    });

    group('setNotification', () {
      test('yields data while connected', () async {
        await bleMock.connect('mock-scale-001');
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final notificationData = <List<int>>[];
        final subscription = bleMock
            .setNotification('service-uuid', 'char-uuid')
            .listen(notificationData.add);

        // Wait for at least one notification
        await Future<void>.delayed(const Duration(seconds: 3));

        expect(notificationData.isNotEmpty, true);
        expect(notificationData.first.length, 8);
        // Values should be 0, 10, 20, 30, 40, 50, 60, 70
        expect(notificationData.first[0], 0);
        expect(notificationData.first[1], 10);
        expect(notificationData.first[7], 70);

        await subscription.cancel();
      });

      test('stops yielding after disconnect', () async {
        await bleMock.connect('mock-scale-001');
        await Future<void>.delayed(const Duration(milliseconds: 100));

        final notificationData = <List<int>>[];
        final subscription = bleMock
            .setNotification('service-uuid', 'char-uuid')
            .listen(notificationData.add);

        await Future<void>.delayed(const Duration(seconds: 3));
        final countBeforeDisconnect = notificationData.length;

        await bleMock.disconnect();
        await Future<void>.delayed(const Duration(seconds: 3));

        final countAfterDisconnect = notificationData.length;
        // Should not get more data after disconnect (or at most one more)
        expect(
          countAfterDisconnect,
          lessThanOrEqualTo(countBeforeDisconnect + 1),
        );

        await subscription.cancel();
      });
    });

    group('getAdvertisementData', () {
      test('returns correct data for known device', () {
        final data = bleMock.getAdvertisementData('mock-scale-001');

        expect(data.name, 'openScale Mock Scale');
        expect(data.rssi, -42);
        expect(data.serviceUuids, contains('180a'));
      });

      test('returns Unknown for unknown device', () {
        final data = bleMock.getAdvertisementData('nonexistent');

        expect(data.name, 'Unknown');
        expect(data.rssi, 0);
      });
    });

    group('BleDevice', () {
      test('equality works', () {
        const device1 = BleDevice(id: 'test-1', name: 'Test Scale', rssi: -50);
        const device2 = BleDevice(id: 'test-1', name: 'Test Scale', rssi: -50);

        expect(device1, equals(device2));
        expect(device1.hashCode, device2.hashCode);
      });

      test('inequality for different id', () {
        const device1 = BleDevice(id: 'test-1', name: 'Test Scale', rssi: -50);
        const device2 = BleDevice(id: 'test-2', name: 'Test Scale', rssi: -50);

        expect(device1, isNot(equals(device2)));
      });

      test('copyWith works', () {
        const device = BleDevice(id: 'test-1', name: 'Test Scale', rssi: -50);
        final modified = device.copyWith(name: 'Modified Scale');

        expect(modified.name, 'Modified Scale');
        expect(modified.id, 'test-1');
        expect(modified.rssi, -50);
      });
    });

    group('BleAdvertisementData', () {
      test('equality works', () {
        const data1 = BleAdvertisementData(
          name: 'Scale',
          rssi: -50,
          serviceUuids: ['180a'],
        );
        const data2 = BleAdvertisementData(
          name: 'Scale',
          rssi: -50,
          serviceUuids: ['180a'],
        );

        expect(data1, equals(data2));
      });
    });
  });
}
