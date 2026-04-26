import 'dart:async';
import 'package:openscale/core/services/ble/ble_interface.dart';

class BleMock implements BleService {
  final StreamController<BleDevice> _scanController =
      StreamController<BleDevice>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  final List<BleDevice> _mockDevices = [
    const BleDevice(
      id: 'mock-scale-001',
      name: 'openScale Mock Scale',
      rssi: -42,
    ),
    const BleDevice(id: 'mock-scale-002', name: 'Xiaomi Mi Scale', rssi: -55),
    const BleDevice(id: 'mock-scale-003', name: 'Beurer BF700', rssi: -68),
  ];

  bool _isConnected = false;

  @override
  Future<void> startScan(Duration timeout) async {
    for (final device in _mockDevices) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (!_scanController.isClosed) {
        _scanController.add(device);
      }
    }
  }

  @override
  Future<void> stopScan() async {}

  @override
  Future<void> connect(String deviceId) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _isConnected = true;
    _connectionController.add(true);
  }

  @override
  Future<void> disconnect() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _isConnected = false;
    _connectionController.add(false);
  }

  @override
  Future<List<int>> readCharacteristic(
    String serviceUuid,
    String characteristicUuid,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return List<int>.generate(16, (i) => i);
  }

  @override
  Future<void> writeCharacteristic(
    String serviceUuid,
    String characteristicUuid,
    List<int> data,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  @override
  Stream<List<int>> setNotification(
    String serviceUuid,
    String characteristicUuid,
  ) async* {
    while (_isConnected) {
      await Future<void>.delayed(const Duration(seconds: 2));
      yield List<int>.generate(8, (i) => i * 10);
    }
  }

  @override
  BleAdvertisementData getAdvertisementData(String deviceId) {
    final device = _mockDevices.firstWhere(
      (d) => d.id == deviceId,
      orElse: () => const BleDevice(id: '', name: 'Unknown', rssi: 0),
    );
    return BleAdvertisementData(
      name: device.name,
      rssi: device.rssi,
      serviceUuids: const ['180a'],
    );
  }

  @override
  Stream<BleDevice> get scannedDevices => _scanController.stream;

  @override
  Stream<bool> get isConnected => _connectionController.stream;

  void dispose() {
    _scanController.close();
    _connectionController.close();
  }
}
