import '../../models/enums.dart';

/// Low-level byte parsing utilities for BLE scale drivers.
///
/// These mirror the Kotlin ConverterUtils / BluetoothBytesParser helpers
/// used throughout the Android scale handlers. All byte data in Dart drivers
/// is represented as `List<int>` with unsigned values (0–255).

// ── Read helpers (little-endian) ──────────────────────────────────────────

/// Read unsigned 8-bit value from [data] at [offset].
int u8(List<int> data, int offset) {
  if (offset < 0 || offset >= data.length) return 0;
  return data[offset] & 0xFF;
}

/// Read unsigned 16-bit little-endian from [data] at [offset].
int u16Le(List<int> data, int offset) {
  if (offset < 0 || offset + 1 >= data.length) return 0;
  return (data[offset] & 0xFF) | ((data[offset + 1] & 0xFF) << 8);
}

/// Read unsigned 32-bit little-endian from [data] at [offset].
int u32Le(List<int> data, int offset) {
  if (offset < 0 || offset + 3 >= data.length) return 0;
  return (data[offset] & 0xFF) |
      ((data[offset + 1] & 0xFF) << 8) |
      ((data[offset + 2] & 0xFF) << 16) |
      ((data[offset + 3] & 0xFF) << 24);
}

// ── Read helpers (big-endian) ─────────────────────────────────────────────

/// Read unsigned 16-bit big-endian from [data] at [offset].
int u16Be(List<int> data, int offset) {
  if (offset < 0 || offset + 1 >= data.length) return 0;
  return ((data[offset] & 0xFF) << 8) | (data[offset + 1] & 0xFF);
}

/// Read unsigned 32-bit big-endian from [data] at [offset].
int u32Be(List<int> data, int offset) {
  if (offset < 0 || offset + 3 >= data.length) return 0;
  return ((data[offset] & 0xFF) << 24) |
      ((data[offset + 1] & 0xFF) << 16) |
      ((data[offset + 2] & 0xFF) << 8) |
      (data[offset + 3] & 0xFF);
}

// ── Write helpers (little-endian) ─────────────────────────────────────────

/// Encode a 16-bit value as 2 bytes little-endian.
List<int> int16Le(int value) {
  return [value & 0xFF, (value >>> 8) & 0xFF];
}

/// Encode a 32-bit value as 4 bytes little-endian.
List<int> int32Le(int value) {
  return [
    value & 0xFF,
    (value >>> 8) & 0xFF,
    (value >>> 16) & 0xFF,
    (value >>> 24) & 0xFF,
  ];
}

// ── Write helpers (big-endian) ────────────────────────────────────────────

/// Encode a 16-bit value as 2 bytes big-endian.
List<int> int16Be(int value) {
  return [(value >>> 8) & 0xFF, value & 0xFF];
}

/// Encode a 32-bit value as 4 bytes big-endian.
List<int> int32Be(int value) {
  return [
    (value >>> 24) & 0xFF,
    (value >>> 16) & 0xFF,
    (value >>> 8) & 0xFF,
    value & 0xFF,
  ];
}

/// Write a 32-bit big-endian value into [buf] at [offset].
void writeU32Be(List<int> buf, int offset, int value) {
  buf[offset] = (value >>> 24) & 0xFF;
  buf[offset + 1] = (value >>> 16) & 0xFF;
  buf[offset + 2] = (value >>> 8) & 0xFF;
  buf[offset + 3] = value & 0xFF;
}

// ── Weight conversion ─────────────────────────────────────────────────────

/// Convert a weight value from the given [unit] to kilograms.
double toKilogram(double value, UnitType unit) {
  switch (unit) {
    case UnitType.kg:
      return value;
    case UnitType.lb:
      return value * 0.453592;
    case UnitType.st:
      return value * 6.35029;
    default:
      return value;
  }
}

// ── Hex preview (for logging) ─────────────────────────────────────────────

/// Return a hex string preview of the first [limit] bytes.
String hexPreview(List<int> data, int limit) {
  if (limit <= 0 || data.isEmpty) return '(payload ${data.length}b)';
  final show = data.length < limit ? data.length : limit;
  final sb = StringBuffer('payload=[');
  for (int i = 0; i < show; i++) {
    if (i > 0) sb.write(' ');
    sb.write(data[i].toRadixString(16).padLeft(2, '0').toUpperCase());
  }
  if (data.length > limit) {
    sb.write(' …(+${data.length - limit}b)');
  }
  sb.write(']');
  return sb.toString();
}
