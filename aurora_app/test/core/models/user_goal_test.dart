import 'package:flutter_test/flutter_test.dart';
import 'package:openscale/core/models/enums.dart';
import 'package:openscale/core/models/user_goal.dart';

void main() {
  final testGoal = UserGoal(
    id: 'g-1',
    userId: 'user-1',
    measurementTypeKey: MeasurementTypeKey.weight,
    goalValue: 70.0,
    goalDate: DateTime(2025, 12, 31),
  );

  group('UserGoal', () {
    test('fromMap/toMap roundtrip preserves all fields including goalDate', () {
      final map = testGoal.toMap();
      final restored = UserGoal.fromMap(map);

      expect(restored.id, testGoal.id);
      expect(restored.userId, testGoal.userId);
      expect(restored.measurementTypeKey, testGoal.measurementTypeKey);
      expect(restored.goalValue, testGoal.goalValue);
      expect(restored.goalDate, testGoal.goalDate);
    });

    test('fromMap/toMap roundtrip with null goalDate', () {
      final noDate = UserGoal(
        id: 'g-2',
        userId: 'user-1',
        measurementTypeKey: MeasurementTypeKey.bodyFat,
        goalValue: 15.0,
        goalDate: null,
      );

      final map = noDate.toMap();
      final restored = UserGoal.fromMap(map);

      expect(restored.goalDate, isNull);
      expect(restored.id, 'g-2');
      expect(restored.goalValue, 15.0);
    });

    test('toMap encodes goalDate as millisecondsSinceEpoch', () {
      final map = testGoal.toMap();

      expect(map['goal_date'], testGoal.goalDate!.millisecondsSinceEpoch);
    });

    test('toMap encodes null goalDate as null', () {
      final noDate = testGoal.copyWith(goalDate: null);
      final map = noDate.toMap();

      expect(map['goal_date'], isNull);
    });

    test('toMap produces correct key names', () {
      final map = testGoal.toMap();

      expect(map.containsKey('id'), true);
      expect(map.containsKey('user_id'), true);
      expect(map.containsKey('measurement_type_key'), true);
      expect(map.containsKey('goal_value'), true);
      expect(map.containsKey('goal_date'), true);
    });

    test('toMap encodes measurementTypeKey as name string', () {
      final map = testGoal.toMap();

      expect(map['measurement_type_key'], 'weight');
    });

    test('fromMap correctly parses measurementTypeKey', () {
      final map = <String, Object?>{
        'id': 'g-3',
        'user_id': 'u-2',
        'measurement_type_key': 'bmi',
        'goal_value': 22.0,
        'goal_date': DateTime(2026, 6, 1).millisecondsSinceEpoch,
      };

      final restored = UserGoal.fromMap(map);

      expect(restored.measurementTypeKey, MeasurementTypeKey.bmi);
    });

    test('equality works — same props means equal', () {
      final copy = UserGoal(
        id: 'g-1',
        userId: 'user-1',
        measurementTypeKey: MeasurementTypeKey.weight,
        goalValue: 70.0,
        goalDate: DateTime(2025, 12, 31),
      );

      expect(copy, equals(testGoal));
      expect(copy.hashCode, testGoal.hashCode);
    });

    test('inequality — different goalValue', () {
      final other = testGoal.copyWith(goalValue: 75.0);
      expect(other, isNot(equals(testGoal)));
    });

    test('inequality — different goalDate', () {
      final other = testGoal.copyWith(goalDate: DateTime(2026, 1, 1));
      expect(other, isNot(equals(testGoal)));
    });

    test('inequality — null vs non-null goalDate', () {
      final noDate = testGoal.copyWith(goalDate: null);
      expect(noDate, isNot(equals(testGoal)));
    });

    test('copyWith creates new instance with changed fields', () {
      final modified = testGoal.copyWith(
        goalValue: 68.0,
        goalDate: DateTime(2025, 6, 30),
      );

      expect(modified.goalValue, 68.0);
      expect(modified.goalDate, DateTime(2025, 6, 30));
      // Unchanged fields preserved
      expect(modified.id, testGoal.id);
      expect(modified.userId, testGoal.userId);
      expect(modified.measurementTypeKey, testGoal.measurementTypeKey);
    });

    test('copyWith with no arguments returns equal instance', () {
      final copy = testGoal.copyWith();
      expect(copy, equals(testGoal));
    });
  });
}
