import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openscale/core/bloc/bluetooth/bluetooth_event.dart';
import 'package:openscale/core/bloc/bluetooth/bluetooth_state.dart';
import 'package:openscale/core/services/ble/ble_interface.dart';

export 'bluetooth_event.dart';
export 'bluetooth_state.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  final BleService _bleService;
  StreamSubscription<BleDevice>? _scanSubscription;

  BluetoothBloc(this._bleService) : super(const BluetoothState()) {
    on<StartScan>(_onStartScan);
    on<StopScan>(_onStopScan);
    on<Connect>(_onConnect);
    on<Disconnect>(_onDisconnect);
    on<DeviceFound>(_onDeviceFound);
    on<ScanComplete>(_onScanComplete);
    on<MeasurementReceived>(_onMeasurementReceived);
    on<BluetoothError>(_onBluetoothError);
  }

  Future<void> _onStartScan(
    StartScan event,
    Emitter<BluetoothState> emit,
  ) async {
    if (state.isScanning) return;

    emit(state.copyWith(isScanning: true, discoveredDevices: const []));

    _scanSubscription?.cancel();
    _scanSubscription = _bleService.scannedDevices.listen(
      (device) => add(DeviceFound(device)),
    );

    try {
      await _bleService.startScan(event.timeout);
      add(const ScanComplete());
    } catch (e) {
      emit(state.copyWith(isScanning: false, error: e.toString()));
    }
  }

  Future<void> _onStopScan(StopScan event, Emitter<BluetoothState> emit) async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    await _bleService.stopScan();
    emit(state.copyWith(isScanning: false));
  }

  Future<void> _onConnect(Connect event, Emitter<BluetoothState> emit) async {
    try {
      await _bleService.connect(event.deviceId);
      final device = state.discoveredDevices.firstWhere(
        (d) => d.id == event.deviceId,
      );
      emit(state.copyWith(isConnected: true, connectedDevice: device));
    } catch (e) {
      emit(state.copyWith(isConnected: false, error: e.toString()));
    }
  }

  Future<void> _onDisconnect(
    Disconnect event,
    Emitter<BluetoothState> emit,
  ) async {
    await _bleService.disconnect();
    emit(state.copyWith(isConnected: false, connectedDevice: null));
  }

  void _onDeviceFound(DeviceFound event, Emitter<BluetoothState> emit) {
    final devices = List<BleDevice>.from(state.discoveredDevices);
    final existingIndex = devices.indexWhere((d) => d.id == event.device.id);

    if (existingIndex >= 0) {
      devices[existingIndex] = event.device;
    } else {
      devices.add(event.device);
    }
    emit(state.copyWith(discoveredDevices: devices));
  }

  void _onScanComplete(ScanComplete event, Emitter<BluetoothState> emit) {
    emit(state.copyWith(isScanning: false));
  }

  Future<void> _onMeasurementReceived(
    MeasurementReceived event,
    Emitter<BluetoothState> emit,
  ) async {
    // Measurement is forwarded to MeasurementBloc via listener in the UI layer.
  }

  Future<void> _onBluetoothError(
    BluetoothError event,
    Emitter<BluetoothState> emit,
  ) async {
    emit(state.copyWith(error: event.message));
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    return super.close();
  }
}
