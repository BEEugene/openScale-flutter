import 'package:openscale/core/bloc/measurement/measurement_bloc.dart';
import 'package:openscale/core/database/dao/measurement_dao.dart';
import 'package:openscale/core/models/measurement.dart';
import 'package:openscale/core/models/measurement_value.dart';

class MeasurementRepositoryImpl implements MeasurementRepository {
  final MeasurementDao _dao;

  MeasurementRepositoryImpl(this._dao);

  @override
  Future<List<MeasurementWithValues>> getMeasurementsForUser(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) => _dao.getMeasurementsForUser(
    userId,
    startDate: startDate,
    endDate: endDate,
    limit: limit,
  );

  @override
  Future<MeasurementWithValues?> getLatestMeasurement(String userId) =>
      _dao.getLatestMeasurement(userId);

  @override
  Future<String> insertMeasurementWithValues(
    Measurement measurement,
    List<MeasurementValue> values,
  ) => _dao.insertMeasurementWithValues(measurement, values);

  @override
  Future<void> deleteMeasurement(String id) => _dao.deleteMeasurement(id);
}
