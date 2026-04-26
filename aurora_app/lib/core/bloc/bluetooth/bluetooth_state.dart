import 'package:equatable/equatable.dart';
import 'package:openscale/core/services/ble/ble_interface.dart';

class BluetoothState extends Equatable {
  final bool isScanning;
  final bool isConnected;
  final List<BleDevice> discoveredDevices;
  final BleDevice? connectedDevice;
  final String? error;

  const BluetoothState({
    this.isScanning = false,
    this.isConnected = false,
    this.discoveredDevices = const [],
    this.connectedDevice,
    this.error,
  });

  BluetoothState copyWith({
    bool? isScanning,
    bool? isConnected,
    List<BleDevice>? discoveredDevices,
    BleDevice? connectedDevice,
    String? error,
  }) {
    return BluetoothState(
      isScanning: isScanning ?? this.isScanning,
      isConnected: isConnected ?? this.isConnected,
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      connectedDevice: connectedDevice ?? this.connectedDevice,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    isScanning,
    isConnected,
    discoveredDevices,
    connectedDevice,
    error,
  ];
}
