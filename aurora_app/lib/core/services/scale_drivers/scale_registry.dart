import 'beurer_sanitas_driver.dart';
import 'device_support.dart';
import 'medisana_bs44x_driver.dart';
import 'miscale_driver.dart';
import 'scale_driver.dart';
import 'soehnle_driver.dart';
import 'standard_beurer_sanitas_driver.dart';

/// Match result combining device metadata and the driver that handles it.
class ScaleMatch {
  final DeviceSupport support;
  final ScaleDriver driver;

  const ScaleMatch({required this.support, required this.driver});
}

/// Registry of all known scale drivers.
///
/// Ordered by priority: first match wins. The adapter iterates through
/// [drivers] calling [ScaleDriver.supportFor] until one returns a
/// non-null [DeviceSupport].
class ScaleRegistry {
  /// All registered drivers in match-priority order.
  static final List<ScaleDriver> drivers = [
    MedisanaBs44xDriver(),
    MiScaleDriver(),
    SoehnleDriver(),
    BeurerSanitasDriver(),
    StandardBeurerSanitasDriver(),
  ];

  /// Find the driver that supports the given [deviceName].
  ///
  /// Returns a [ScaleMatch] containing both the [DeviceSupport] metadata
  /// and the matching [ScaleDriver], or `null` if no driver recognizes
  /// the device.
  static ScaleMatch? matchDevice(String deviceName, {int? rssi}) {
    for (final driver in drivers) {
      final support = driver.supportFor(deviceName, rssi);
      if (support != null) {
        return ScaleMatch(support: support, driver: driver);
      }
    }
    return null;
  }
}
