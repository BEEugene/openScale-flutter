import 'package:csv/csv.dart';
import 'package:openscale/core/models/measurement.dart';
import 'package:openscale/core/models/measurement_value.dart';

class CsvService {
  static const String _dateFormatColumn = 'date_time';
  static const String _userIdColumn = 'user_id';
  static const String _commentColumn = 'comment';

  String exportToCsv(
    List<Measurement> measurements,
    Map<String, List<MeasurementValue>> valuesByMeasurementId,
  ) {
    if (measurements.isEmpty) return '';

    final allKeys = <String>{};
    for (final values in valuesByMeasurementId.values) {
      for (final v in values) {
        allKeys.add(v.measurementTypeKey.name);
      }
    }
    final sortedKeys = allKeys.toList()..sort();

    final headers = [
      _dateFormatColumn,
      _userIdColumn,
      _commentColumn,
      ...sortedKeys,
    ];

    final rows = <List<String>>[];
    for (final m in measurements) {
      final row = <String>[
        m.dateTime.millisecondsSinceEpoch.toString(),
        m.userId,
        m.comment ?? '',
      ];
      final values = valuesByMeasurementId[m.id] ?? [];
      final valueMap = <String, double>{};
      for (final v in values) {
        valueMap[v.measurementTypeKey.name] = v.value;
      }
      for (final key in sortedKeys) {
        row.add(valueMap[key]?.toStringAsFixed(2) ?? '');
      }
      rows.add(row);
    }

    return const ListToCsvConverter().convert([headers, ...rows]);
  }

  List<Measurement> importFromCsv(String csvContent) {
    if (csvContent.trim().isEmpty) return [];

    final rows = const CsvToListConverter().convert(csvContent);
    if (rows.length < 2) return [];

    final measurements = <Measurement>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;

      final dateTime = DateTime.fromMillisecondsSinceEpoch(
        (row[0] as num).toInt(),
      );
      final userId = row[1].toString();
      final comment = row[2].toString();

      measurements.add(
        Measurement(
          id: 'imported_$i',
          userId: userId,
          dateTime: dateTime,
          comment: comment.isEmpty ? null : comment,
        ),
      );
    }

    return measurements;
  }
}
