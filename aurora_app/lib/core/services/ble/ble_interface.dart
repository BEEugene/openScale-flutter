import 'package:equatable/equatable.dart';

class BleDevice extends Equatable {
  final String id;
  final String name;
  final int rssi;

  const BleDevice({required this.id, required this.name, required this.rssi});

  BleDevice copyWith({String? id, String? name, int? rssi}) {
    return BleDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
    );
  }

  @override
  List<Object> get props => [id, name, rssi];
}

class BleAdvertisementData extends Equatable {
  final String name;
  final int rssi;
  final List<String> serviceUuids;

  const BleAdvertisementData({
    required this.name,
    required this.rssi,
    required this.serviceUuids,
  });

  @override
  List<Object> get props => [name, rssi, serviceUuids];
}

abstract class BleService {
  Future<void> startScan(Duration timeout);
  Future<void> stopScan();
  Future<void> connect(String deviceId);
  Future<void> disconnect();
  Future<List<int>> readCharacteristic(
    String serviceUuid,
    String characteristicUuid,
  );
  Future<void> writeCharacteristic(
    String serviceUuid,
    String characteristicUuid,
    List<int> data,
  );
  Stream<List<int>> setNotification(
    String serviceUuid,
    String characteristicUuid,
  );
  BleAdvertisementData getAdvertisementData(String deviceId);
  Stream<BleDevice> get scannedDevices;
  Stream<bool> get isConnected;
}
