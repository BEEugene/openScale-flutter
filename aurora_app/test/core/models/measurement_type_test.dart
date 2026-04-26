import 'package:flutter_test/flutter_test.dart';
import 'package:openscale/core/models/enums.dart';
import 'package:openscale/core/models/measurement_type.dart';

void main() {
  final testType = MeasurementType(
    id: 'mt-1',
    key: MeasurementTypeKey.weight,
    name: 'Weight',
    unit: UnitType.kg,
    color: 0xFF7E57C2,
    icon: 'weight_icon',
    isEnabled: true,
    isPinned: false,
    isDerived: false,
    sortOrder: 1,
    inputType: InputFieldType.float,
    isOnRightYAxis: false,
  );

  group('MeasurementType', () {
    test('fromMap/toMap roundtrip preserves all fields', () {
      final map = testType.toMap();
      final restored = MeasurementType.fromMap(map);

      expect(restored.id, testType.id);
      expect(restored.key, testType.key);
      expect(restored.name, testType.name);
      expect(restored.unit, testType.unit);
      expect(restored.color, testType.color);
      expect(restored.icon, testType.icon);
      expect(restored.isEnabled, testType.isEnabled);
      expect(restored.isPinned, testType.isPinned);
      expect(restored.isDerived, testType.isDerived);
      expect(restored.sortOrder, testType.sortOrder);
      expect(restored.inputType, testType.inputType);
      expect(restored.isOnRightYAxis, testType.isOnRightYAxis);
    });

    group('boolean fields map to/from int', () {
      test('isEnabled true maps to 1 and back', () {
        final map = testType.toMap();
        expect(map['is_enabled'], 1);

        final restored = MeasurementType.fromMap(map);
        expect(restored.isEnabled, true);
      });

      test('isEnabled false maps to 0 and back', () {
        final disabled = testType.copyWith(isEnabled: false);
        final map = disabled.toMap();
        expect(map['is_enabled'], 0);

        final restored = MeasurementType.fromMap(map);
        expect(restored.isEnabled, false);
      });

      test('isPinned true maps to 1 and back', () {
        final pinned = testType.copyWith(isPinned: true);
        final map = pinned.toMap();
        expect(map['is_pinned'], 1);

        final restored = MeasurementType.fromMap(map);
        expect(restored.isPinned, true);
      });

      test('isPinned false maps to 0 and back', () {
        final map = testType.toMap();
        expect(map['is_pinned'], 0);

        final restored = MeasurementType.fromMap(map);
        expect(restored.isPinned, false);
      });

      test('isDerived true maps to 1 and back', () {
        final derived = testType.copyWith(isDerived: true);
        final map = derived.toMap();
        expect(map['is_derived'], 1);

        final restored = MeasurementType.fromMap(map);
        expect(restored.isDerived, true);
      });

      test('isOnRightYAxis true maps to 1 and back', () {
        final rightAxis = testType.copyWith(isOnRightYAxis: true);
        final map = rightAxis.toMap();
        expect(map['is_on_right_y_axis'], 1);

        final restored = MeasurementType.fromMap(map);
        expect(restored.isOnRightYAxis, true);
      });
    });

    test('fromMap handles nullable fields with defaults', () {
      final map = <String, Object?>{
        'id': 'mt-min',
        'key': 'bmi',
        'name': null,
        'unit': 'none',
        'color': 0,
        'icon': null,
        'is_enabled': 1,
        'is_pinned': 0,
        'is_derived': 0,
        'sort_order': null,
        'input_type': null,
        'is_on_right_y_axis': null,
      };

      final restored = MeasurementType.fromMap(map);

      expect(restored.name, ''); // defaults to empty string
      expect(restored.icon, ''); // defaults to empty string
      expect(restored.sortOrder, 0); // defaults to 0
      expect(restored.inputType, InputFieldType.float); // defaults to float
      expect(restored.isOnRightYAxis, false); // defaults to false
    });

    test('equality works — same props means equal', () {
      final copy = MeasurementType(
        id: 'mt-1',
        key: MeasurementTypeKey.weight,
        name: 'Weight',
        unit: UnitType.kg,
        color: 0xFF7E57C2,
        icon: 'weight_icon',
        isEnabled: true,
        isPinned: false,
        isDerived: false,
        sortOrder: 1,
        inputType: InputFieldType.float,
        isOnRightYAxis: false,
      );

      expect(copy, equals(testType));
      expect(copy.hashCode, testType.hashCode);
    });

    test('inequality — different isEnabled', () {
      final other = testType.copyWith(isEnabled: false);
      expect(other, isNot(equals(testType)));
    });

    test('copyWith creates new instance with changed fields', () {
      final modified = testType.copyWith(
        name: 'Body Weight',
        isEnabled: false,
        sortOrder: 5,
      );

      expect(modified.name, 'Body Weight');
      expect(modified.isEnabled, false);
      expect(modified.sortOrder, 5);
      // Unchanged fields preserved
      expect(modified.id, testType.id);
      expect(modified.key, testType.key);
      expect(modified.unit, testType.unit);
    });

    test('copyWith with no arguments returns equal instance', () {
      final copy = testType.copyWith();
      expect(copy, equals(testType));
    });
  });
}
