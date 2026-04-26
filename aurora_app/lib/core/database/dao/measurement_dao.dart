import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:openscale/core/models/measurement.dart';
import 'package:openscale/core/models/measurement_value.dart';

class MeasurementWithValues {
  final Measurement measurement;
  final List<MeasurementValue> values;

  const MeasurementWithValues({
    required this.measurement,
    required this.values,
  });
}

class MeasurementDao {
  final Database _db;
  static final _uuid = Uuid();

  static const String _selectByUser =
      'SELECT * FROM measurements WHERE user_id = ? ORDER BY date_time DESC';
  static const String _selectByUserDateRange =
      'SELECT * FROM measurements WHERE user_id = ? AND date_time >= ? AND date_time <= ? ORDER BY date_time DESC';
  static const String _selectByUserLimit =
      'SELECT * FROM measurements WHERE user_id = ? ORDER BY date_time DESC LIMIT ?';
  static const String _selectLatest =
      'SELECT * FROM measurements WHERE user_id = ? ORDER BY date_time DESC LIMIT 1';
  static const String _selectValuesByMeasurement =
      'SELECT * FROM measurement_values WHERE measurement_id = ?';
  static const String _insertMeasurement =
      'INSERT INTO measurements (id, user_id, date_time, comment) VALUES (?, ?, ?, ?)';
  static const String _insertValue =
      'INSERT INTO measurement_values (id, measurement_id, measurement_type_key, value) VALUES (?, ?, ?, ?)';
  static const String _deleteMeasurement =
      'DELETE FROM measurements WHERE id = ?';

  MeasurementDao(this._db);

  Future<List<MeasurementWithValues>> getMeasurementsForUser(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    List<Map<String, Object?>> rows;

    if (startDate != null && endDate != null) {
      rows = await _db.rawQuery(_selectByUserDateRange, [
        userId,
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ]);
    } else if (limit != null) {
      rows = await _db.rawQuery(_selectByUserLimit, [userId, limit]);
    } else {
      rows = await _db.rawQuery(_selectByUser, [userId]);
    }

    final results = <MeasurementWithValues>[];
    for (final row in rows) {
      final measurement = Measurement.fromMap(row);
      final values = await _getValuesForMeasurement(measurement.id);
      results.add(
        MeasurementWithValues(measurement: measurement, values: values),
      );
    }
    return results;
  }

  Future<MeasurementWithValues?> getLatestMeasurement(String userId) async {
    final rows = await _db.rawQuery(_selectLatest, [userId]);
    if (rows.isEmpty) return null;

    final measurement = Measurement.fromMap(rows.first);
    final values = await _getValuesForMeasurement(measurement.id);
    return MeasurementWithValues(measurement: measurement, values: values);
  }

  Future<String> insertMeasurementWithValues(
    Measurement measurement,
    List<MeasurementValue> values,
  ) async {
    final measurementId = measurement.id.isEmpty ? _uuid.v4() : measurement.id;

    await _db.transaction((txn) async {
      await txn.rawInsert(_insertMeasurement, [
        measurementId,
        measurement.userId,
        measurement.dateTime.millisecondsSinceEpoch,
        measurement.comment,
      ]);

      for (final value in values) {
        final valueId = value.id.isEmpty ? _uuid.v4() : value.id;
        await txn.rawInsert(_insertValue, [
          valueId,
          measurementId,
          value.measurementTypeKey.name,
          value.value,
        ]);
      }
    });

    return measurementId;
  }

  Future<void> deleteMeasurement(String id) async {
    await _db.rawDelete(_deleteMeasurement, [id]);
  }

  Future<List<MeasurementValue>> _getValuesForMeasurement(
    String measurementId,
  ) async {
    final rows = await _db.rawQuery(_selectValuesByMeasurement, [
      measurementId,
    ]);
    return rows.map(MeasurementValue.fromMap).toList();
  }
}
