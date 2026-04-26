import 'package:flutter_test/flutter_test.dart';
import 'package:openscale/core/models/measurement.dart';

void main() {
  final testMeasurement = Measurement(
    id: 'm-1',
    userId: 'user-1',
    dateTime: DateTime(2025, 3, 15, 10, 30),
    comment: 'Morning weigh-in',
  );

  group('Measurement', () {
    test('fromMap/toMap roundtrip preserves all fields', () {
      final map = testMeasurement.toMap();
      final restored = Measurement.fromMap(map);

      expect(restored.id, testMeasurement.id);
      expect(restored.userId, testMeasurement.userId);
      expect(restored.dateTime, testMeasurement.dateTime);
      expect(restored.comment, testMeasurement.comment);
    });

    test('fromMap/toMap roundtrip with null comment', () {
      final noComment = Measurement(
        id: 'm-2',
        userId: 'user-1',
        dateTime: DateTime(2025, 4, 1),
        comment: null,
      );

      final map = noComment.toMap();
      final restored = Measurement.fromMap(map);

      expect(restored.comment, isNull);
      expect(restored.id, 'm-2');
      expect(restored.userId, 'user-1');
    });

    test('toMap produces correct key names', () {
      final map = testMeasurement.toMap();

      expect(map.containsKey('id'), true);
      expect(map.containsKey('user_id'), true);
      expect(map.containsKey('date_time'), true);
      expect(map.containsKey('comment'), true);
    });

    test('toMap encodes dateTime as millisecondsSinceEpoch', () {
      final map = testMeasurement.toMap();

      expect(map['date_time'], testMeasurement.dateTime.millisecondsSinceEpoch);
    });

    test('toMap includes null comment as null', () {
      final noComment = testMeasurement.copyWith(comment: null);
      final map = noComment.toMap();

      expect(map['comment'], isNull);
    });

    test('equality works — same props means equal', () {
      final copy = Measurement(
        id: 'm-1',
        userId: 'user-1',
        dateTime: DateTime(2025, 3, 15, 10, 30),
        comment: 'Morning weigh-in',
      );

      expect(copy, equals(testMeasurement));
      expect(copy.hashCode, testMeasurement.hashCode);
    });

    test('inequality — different id', () {
      final other = testMeasurement.copyWith(id: 'm-other');
      expect(other, isNot(equals(testMeasurement)));
    });

    test('inequality — different comment', () {
      final other = testMeasurement.copyWith(comment: 'Evening weigh-in');
      expect(other, isNot(equals(testMeasurement)));
    });

    test('copyWith creates new instance with changed fields', () {
      final modified = testMeasurement.copyWith(
        id: 'm-new',
        comment: 'Updated comment',
      );

      expect(modified.id, 'm-new');
      expect(modified.comment, 'Updated comment');
      // Unchanged fields preserved
      expect(modified.userId, testMeasurement.userId);
      expect(modified.dateTime, testMeasurement.dateTime);
    });

    test('copyWith with no arguments returns equal instance', () {
      final copy = testMeasurement.copyWith();
      expect(copy, equals(testMeasurement));
    });

    test('fromMap with empty comment string preserves it', () {
      final map = <String, Object?>{
        'id': 'm-x',
        'user_id': 'u-x',
        'date_time': DateTime(2025, 1, 1).millisecondsSinceEpoch,
        'comment': '',
      };

      final restored = Measurement.fromMap(map);
      expect(restored.comment, '');
    });
  });
}
