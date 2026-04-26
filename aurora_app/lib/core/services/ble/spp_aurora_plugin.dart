import 'dart:async';

import 'package:flutter/services.dart';

/// Dart-side SPP (Serial Port Profile) wrapper for Aurora OS.
///
/// Communicates with a Qt/C++ plugin via [MethodChannel] to perform
/// RFCOMM operations using bluez-qt on Aurora OS.
///
/// The C++ side is built separately as a Flutter Aurora plugin and handles:
/// - SDP service discovery (UUID: 00000000-0000-0000-0000-00000000C1A5)
/// - RFCOMM socket lifecycle
/// - Background read loop feeding the [onData] stream
class SppAuroraPlugin {
  static const MethodChannel _channel = MethodChannel('spp_aurora_plugin');

  /// Stream controller fed by the native side via EventChannel.
  /// The C++ plugin pushes incoming SPP bytes here.
  final StreamController<List<int>> _dataController =
      StreamController<List<int>>.broadcast();

  bool _disposed = false;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Open an RFCOMM connection to the device at [address].
  ///
  /// Returns `true` on success, `false` on failure.
  /// Throws [PlatformException] if the native plugin is unavailable.
  Future<bool> connect(String address) async {
    _assertNotDisposed();
    try {
      final bool result =
          await _channel.invokeMethod<bool>('connect', <String, String>{
                'address': address,
              })
              as bool;
      return result;
    } on PlatformException {
      return false;
    }
  }

  /// Read currently available bytes from the RFCOMM stream.
  ///
  /// Returns an empty list when no data is available.
  /// Prefer using [onData] for continuous streaming.
  Future<List<int>> read() async {
    _assertNotDisposed();
    try {
      final List<Object?>? result = await _channel.invokeMethod<List<Object?>>(
        'read',
      );
      if (result == null) return <int>[];
      return result.cast<int>();
    } on PlatformException {
      return <int>[];
    }
  }

  /// Write [data] bytes to the RFCOMM stream.
  ///
  /// The native side handles chunked writes and inter-chunk pacing.
  Future<void> write(List<int> data) async {
    _assertNotDisposed();
    try {
      await _channel.invokeMethod<void>('write', <String, Object>{
        'data': data,
      });
    } on PlatformException {
      // Swallow — the caller should check isConnected for transport errors.
    }
  }

  /// Close the RFCOMM connection and release native resources.
  Future<void> disconnect() async {
    _assertNotDisposed();
    try {
      await _channel.invokeMethod<void>('disconnect');
    } on PlatformException {
      // Best-effort disconnect.
    }
  }

  /// Continuous stream of incoming SPP data from the native reader loop.
  ///
  /// Each event is a chunk of raw bytes read from the RFCOMM socket.
  Stream<List<int>> get onData => _dataController.stream;

  /// Dispose the plugin: disconnects and closes the data stream.
  ///
  /// After calling [dispose], all other methods will throw [StateError].
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await disconnect();
    await _dataController.close();
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  void _assertNotDisposed() {
    if (_disposed) {
      throw StateError('SppAuroraPlugin has been disposed');
    }
  }
}
