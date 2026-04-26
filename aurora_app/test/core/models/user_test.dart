import 'package:flutter_test/flutter_test.dart';
import 'package:openscale/core/models/enums.dart';
import 'package:openscale/core/models/user.dart';

void main() {
  final testUser = User(
    id: 'user-1',
    name: 'Alice',
    birthday: DateTime(1990, 6, 15),
    bodyHeight: 170.0,
    gender: Gender.female,
    initialWeight: 65.0,
    goalWeight: 60.0,
    scaleUnit: UnitType.kg,
    activityLevel: ActivityLevel.moderate,
  );

  group('User', () {
    test('fromMap/toMap roundtrip preserves all fields', () {
      final map = testUser.toMap();
      final restored = User.fromMap(map);

      expect(restored.id, testUser.id);
      expect(restored.name, testUser.name);
      expect(restored.birthday, testUser.birthday);
      expect(restored.bodyHeight, testUser.bodyHeight);
      expect(restored.gender, testUser.gender);
      expect(restored.initialWeight, testUser.initialWeight);
      expect(restored.goalWeight, testUser.goalWeight);
      expect(restored.scaleUnit, testUser.scaleUnit);
      expect(restored.activityLevel, testUser.activityLevel);
    });

    test('toMap produces correct key names', () {
      final map = testUser.toMap();

      expect(map.containsKey('id'), true);
      expect(map.containsKey('name'), true);
      expect(map.containsKey('birthday'), true);
      expect(map.containsKey('body_height'), true);
      expect(map.containsKey('gender'), true);
      expect(map.containsKey('initial_weight'), true);
      expect(map.containsKey('goal_weight'), true);
      expect(map.containsKey('scale_unit'), true);
      expect(map.containsKey('activity_level'), true);
    });

    test('toMap encodes enums as name strings', () {
      final map = testUser.toMap();

      expect(map['gender'], 'female');
      expect(map['scale_unit'], 'kg');
      expect(map['activity_level'], 2);
    });

    test('toMap encodes birthday as millisecondsSinceEpoch', () {
      final map = testUser.toMap();

      expect(map['birthday'], testUser.birthday.millisecondsSinceEpoch);
    });

    test('fromMap correctly parses nested enums', () {
      final map = <String, Object?>{
        'id': 'u2',
        'name': 'Bob',
        'birthday': DateTime(1985, 1, 20).millisecondsSinceEpoch,
        'body_height': 180.5,
        'gender': 'male',
        'initial_weight': 80.0,
        'goal_weight': 75.0,
        'scale_unit': 'lb',
        'activity_level': 3,
      };

      final user = User.fromMap(map);

      expect(user.gender, Gender.male);
      expect(user.scaleUnit, UnitType.lb);
      expect(user.activityLevel, ActivityLevel.heavy);
    });

    test('fromMap defaults enums for unknown values', () {
      final map = <String, Object?>{
        'id': 'u3',
        'name': 'Charlie',
        'birthday': DateTime(2000, 1, 1).millisecondsSinceEpoch,
        'body_height': 175.0,
        'gender': 'unknown_gender',
        'initial_weight': 70.0,
        'goal_weight': 65.0,
        'scale_unit': 'unknown_unit',
        'activity_level': 99,
      };

      final user = User.fromMap(map);

      expect(user.gender, Gender.male); // default
      expect(user.scaleUnit, UnitType.none); // default
      expect(user.activityLevel, ActivityLevel.sedentary); // default
    });

    test('equality works — same props means equal', () {
      final copy = User(
        id: 'user-1',
        name: 'Alice',
        birthday: DateTime(1990, 6, 15),
        bodyHeight: 170.0,
        gender: Gender.female,
        initialWeight: 65.0,
        goalWeight: 60.0,
        scaleUnit: UnitType.kg,
        activityLevel: ActivityLevel.moderate,
      );

      expect(copy, equals(testUser));
      expect(copy.hashCode, testUser.hashCode);
    });

    test('inequality — different id', () {
      final other = testUser.copyWith(id: 'user-2');
      expect(other, isNot(equals(testUser)));
    });

    test('inequality — different name', () {
      final other = testUser.copyWith(name: 'Bob');
      expect(other, isNot(equals(testUser)));
    });

    test('copyWith creates new instance with changed fields', () {
      final modified = testUser.copyWith(
        name: 'Alicia',
        goalWeight: 58.0,
        activityLevel: ActivityLevel.heavy,
      );

      expect(modified.name, 'Alicia');
      expect(modified.goalWeight, 58.0);
      expect(modified.activityLevel, ActivityLevel.heavy);
      // Unchanged fields preserved
      expect(modified.id, testUser.id);
      expect(modified.birthday, testUser.birthday);
      expect(modified.bodyHeight, testUser.bodyHeight);
      expect(modified.gender, testUser.gender);
      expect(modified.initialWeight, testUser.initialWeight);
      expect(modified.scaleUnit, testUser.scaleUnit);
    });

    test('copyWith with no arguments returns equal instance', () {
      final copy = testUser.copyWith();
      expect(copy, equals(testUser));
      expect(copy.hashCode, testUser.hashCode);
    });
  });
}
