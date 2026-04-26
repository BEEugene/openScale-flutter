import 'package:equatable/equatable.dart';
import 'package:openscale/core/models/measurement.dart';
import 'package:openscale/core/models/measurement_value.dart';
import 'package:openscale/core/services/ble/ble_interface.dart';

abstract class BluetoothEvent extends Equatable {
  const BluetoothEvent();

  @override
  List<Object?> get props => [];
}

class StartScan extends BluetoothEvent {
  final Duration timeout;

  const StartScan({this.timeout = const Duration(seconds: 10)});

  @override
  List<Object?> get props => [timeout];
}

class StopScan extends BluetoothEvent {
  const StopScan();
}

class Connect extends BluetoothEvent {
  final String deviceId;

  const Connect(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class Disconnect extends BluetoothEvent {
  const Disconnect();
}

class DeviceFound extends BluetoothEvent {
  final BleDevice device;

  const DeviceFound(this.device);

  @override
  List<Object?> get props => [device];
}

class ScanComplete extends BluetoothEvent {
  const ScanComplete();
}

class MeasurementReceived extends BluetoothEvent {
  final Measurement measurement;
  final List<MeasurementValue> values;

  const MeasurementReceived(this.measurement, this.values);

  @override
  List<Object?> get props => [measurement, values];
}

class BluetoothError extends BluetoothEvent {
  final String message;

  const BluetoothError(this.message);

  @override
  List<Object?> get props => [message];
}
