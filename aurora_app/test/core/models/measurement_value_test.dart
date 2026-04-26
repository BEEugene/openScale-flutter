import 'package:flutter_test/flutter_test.dart';
import 'package:openscale/core/models/enums.dart';
import 'package:openscale/core/models/measurement_value.dart';

void main() {
  final testValue = MeasurementValue(
    id: 'mv-1',
    measurementId: 'm-1',
    measurementTypeKey: MeasurementTypeKey.weight,
    value: 72.5,
  );

  group('MeasurementValue', () {
    test('fromMap/toMap roundtrip preserves all fields', () {
      final map = testValue.toMap();
      final restored = MeasurementValue.fromMap(map);

      expect(restored.id, testValue.id);
      expect(restored.measurementId, testValue.measurementId);
      expect(restored.measurementTypeKey, testValue.measurementTypeKey);
      expect(restored.value, testValue.value);
    });

    test('toMap produces correct key names', () {
      final map = testValue.toMap();

      expect(map.containsKey('id'), true);
      expect(map.containsKey('measurement_id'), true);
      expect(map.containsKey('measurement_type_key'), true);
      expect(map.containsKey('value'), true);
    });

    test('toMap encodes measurementTypeKey as name string', () {
      final map = testValue.toMap();

      expect(map['measurement_type_key'], 'weight');
    });

    test('fromMap correctly parses measurementTypeKey', () {
      final map = <String, Object?>{
        'id': 'mv-2',
        'measurement_id': 'm-2',
        'measurement_type_key': 'bmi',
        'value': 22.86,
      };

      final restored = MeasurementValue.fromMap(map);

      expect(restored.measurementTypeKey, MeasurementTypeKey.bmi);
      expect(restored.value, 22.86);
    });

    test('equality works — same props means equal', () {
      final copy = MeasurementValue(
        id: 'mv-1',
        measurementId: 'm-1',
        measurementTypeKey: MeasurementTypeKey.weight,
        value: 72.5,
      );

      expect(copy, equals(testValue));
      expect(copy.hashCode, testValue.hashCode);
    });

    test('inequality — different value', () {
      final other = testValue.copyWith(value: 73.0);
      expect(other, isNot(equals(testValue)));
    });

    test('inequality — different measurementTypeKey', () {
      final other = testValue.copyWith(
        measurementTypeKey: MeasurementTypeKey.bmi,
      );
      expect(other, isNot(equals(testValue)));
    });

    test('copyWith creates new instance with changed fields', () {
      final modified = testValue.copyWith(
        value: 71.0,
        measurementTypeKey: MeasurementTypeKey.bodyFat,
      );

      expect(modified.value, 71.0);
      expect(modified.measurementTypeKey, MeasurementTypeKey.bodyFat);
      // Unchanged fields preserved
      expect(modified.id, testValue.id);
      expect(modified.measurementId, testValue.measurementId);
    });

    test('copyWith with no arguments returns equal instance', () {
      final copy = testValue.copyWith();
      expect(copy, equals(testValue));
    });
  });
}
