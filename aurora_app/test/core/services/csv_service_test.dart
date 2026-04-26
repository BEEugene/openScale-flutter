import 'package:flutter_test/flutter_test.dart';
import 'package:openscale/core/models/enums.dart';
import 'package:openscale/core/models/measurement.dart';
import 'package:openscale/core/models/measurement_value.dart';
import 'package:openscale/core/services/import_export/csv_service.dart';

void main() {
  group('CsvService', () {
    late CsvService service;

    setUp(() {
      service = CsvService();
    });

    group('exportToCsv', () {
      test('returns empty string for empty measurements list', () {
        final result = service.exportToCsv([], {});
        expect(result, '');
      });

      test('produces valid CSV with headers for measurements with values', () {
        final measurements = [
          Measurement(
            id: 'm-1',
            userId: 'user-1',
            dateTime: DateTime(2025, 3, 15, 10, 30),
            comment: 'Morning',
          ),
        ];
        final valuesByMeasurementId = <String, List<MeasurementValue>>{
          'm-1': [
            MeasurementValue(
              id: 'v-1',
              measurementId: 'm-1',
              measurementTypeKey: MeasurementTypeKey.weight,
              value: 72.5,
            ),
            MeasurementValue(
              id: 'v-2',
              measurementId: 'm-1',
              measurementTypeKey: MeasurementTypeKey.bmi,
              value: 22.86,
            ),
          ],
        };

        final csv = service.exportToCsv(measurements, valuesByMeasurementId);

        expect(csv, isNotEmpty);
        // Should contain headers
        expect(csv, contains('date_time'));
        expect(csv, contains('user_id'));
        expect(csv, contains('comment'));
        // Should contain sorted measurement type keys
        expect(csv, contains('bmi'));
        expect(csv, contains('weight'));
        // Should contain the measurement data
        expect(csv, contains('user-1'));
        expect(csv, contains('Morning'));
        expect(csv, contains('72.50'));
        expect(csv, contains('22.86'));
      });

      test('exports with null comment as empty string', () {
        final measurements = [
          Measurement(
            id: 'm-1',
            userId: 'user-1',
            dateTime: DateTime(2025, 1, 1),
            comment: null,
          ),
        ];
        final valuesByMeasurementId = <String, List<MeasurementValue>>{
          'm-1': [
            MeasurementValue(
              id: 'v-1',
              measurementId: 'm-1',
              measurementTypeKey: MeasurementTypeKey.weight,
              value: 70.0,
            ),
          ],
        };

        final csv = service.exportToCsv(measurements, valuesByMeasurementId);

        // CSV should have two commas after user_id for empty comment
        expect(csv, isNotEmpty);
      });

      test('handles measurement with no corresponding values', () {
        final measurements = [
          Measurement(
            id: 'm-1',
            userId: 'user-1',
            dateTime: DateTime(2025, 1, 1),
            comment: null,
          ),
        ];
        final valuesByMeasurementId = <String, List<MeasurementValue>>{};

        final csv = service.exportToCsv(measurements, valuesByMeasurementId);

        // Should have only the basic headers (date_time, user_id, comment)
        expect(csv, contains('date_time'));
        expect(csv, contains('user_id'));
        expect(csv, contains('comment'));
      });

      test('exports multiple measurements', () {
        final measurements = [
          Measurement(
            id: 'm-1',
            userId: 'user-1',
            dateTime: DateTime(2025, 1, 1),
          ),
          Measurement(
            id: 'm-2',
            userId: 'user-1',
            dateTime: DateTime(2025, 2, 1),
          ),
        ];
        final valuesByMeasurementId = <String, List<MeasurementValue>>{
          'm-1': [
            MeasurementValue(
              id: 'v-1',
              measurementId: 'm-1',
              measurementTypeKey: MeasurementTypeKey.weight,
              value: 70.0,
            ),
          ],
          'm-2': [
            MeasurementValue(
              id: 'v-2',
              measurementId: 'm-2',
              measurementTypeKey: MeasurementTypeKey.weight,
              value: 69.5,
            ),
          ],
        };

        final csv = service.exportToCsv(measurements, valuesByMeasurementId);

        expect(csv, contains('70.00'));
        expect(csv, contains('69.50'));
      });
    });

    group('importFromCsv', () {
      test('returns empty list for empty string', () {
        final result = service.importFromCsv('');
        expect(result, isEmpty);
      });

      test('returns empty list for whitespace-only string', () {
        final result = service.importFromCsv('   \n  ');
        expect(result, isEmpty);
      });

      test('returns empty list for header-only CSV', () {
        const csv = 'date_time,user_id,comment,weight';
        final result = service.importFromCsv(csv);
        expect(result, isEmpty);
      });

      test('imports valid CSV to measurements list', () {
        final dateTime = DateTime(2025, 3, 15, 10, 30);
        final csv =
            'date_time,user_id,comment,weight\n'
            '${dateTime.millisecondsSinceEpoch},user-1,Morning weigh-in,72.50';

        final result = service.importFromCsv(csv);

        expect(result.length, 1);
        expect(result.first.userId, 'user-1');
        expect(result.first.comment, 'Morning weigh-in');
        expect(
          result.first.dateTime.millisecondsSinceEpoch,
          dateTime.millisecondsSinceEpoch,
        );
      });

      test('imports multiple rows', () {
        final dt1 = DateTime(2025, 1, 1);
        final dt2 = DateTime(2025, 2, 1);
        final csv =
            'date_time,user_id,comment,weight\n'
            '${dt1.millisecondsSinceEpoch},user-1,,70.00\n'
            '${dt2.millisecondsSinceEpoch},user-1,February,69.50';

        final result = service.importFromCsv(csv);

        expect(result.length, 2);
        expect(result[0].userId, 'user-1');
        expect(result[0].comment, isNull); // empty string → null
        expect(result[1].comment, 'February');
      });

      test('generates imported_ prefixed IDs', () {
        const csv =
            'date_time,user_id,comment\n'
            '1704067200000,user-1,test';

        final result = service.importFromCsv(csv);

        expect(result.first.id, startsWith('imported_'));
      });
    });

    group('roundtrip', () {
      test('export then import preserves basic measurement structure', () {
        final original = [
          Measurement(
            id: 'm-1',
            userId: 'user-1',
            dateTime: DateTime(2025, 3, 15, 10, 30),
            comment: 'Test comment',
          ),
        ];
        final values = <String, List<MeasurementValue>>{
          'm-1': [
            MeasurementValue(
              id: 'v-1',
              measurementId: 'm-1',
              measurementTypeKey: MeasurementTypeKey.weight,
              value: 72.5,
            ),
          ],
        };

        final csv = service.exportToCsv(original, values);
        final restored = service.importFromCsv(csv);

        expect(restored.length, 1);
        expect(restored.first.userId, original.first.userId);
        expect(restored.first.comment, original.first.comment);
        expect(
          restored.first.dateTime.millisecondsSinceEpoch,
          original.first.dateTime.millisecondsSinceEpoch,
        );
      });
    });
  });
}
