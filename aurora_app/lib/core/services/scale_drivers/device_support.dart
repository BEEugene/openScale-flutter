/// How the device communicates with the app.
enum LinkMode {
  /// Standard BLE GATT connection (connect, discover services, read/write/notify).
  connectGatt,

  /// BLE broadcast advertisements only (no GATT connection).
  broadcastOnly,

  /// Bluetooth Classic SPP (serial port profile).
  classicSpp,
}

/// Result of matching a scanned device to a scale driver.
///
/// Contains the display metadata; the actual driver reference is obtained
/// from [ScaleRegistry.matchDevice] which returns the driver alongside this.
class DeviceSupport {
  /// Human-readable name shown in the UI (e.g., "Yunmai Mini").
  final String name;

  /// Whether the device uses GATT, broadcast, or classic SPP.
  final LinkMode linkMode;

  const DeviceSupport({required this.name, required this.linkMode});

  @override
  String toString() => 'DeviceSupport(name=$name, linkMode=$linkMode)';
}
