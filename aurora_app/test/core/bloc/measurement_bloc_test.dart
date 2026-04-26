import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:openscale/core/models/enums.dart';
import 'package:openscale/core/models/measurement.dart';
import 'package:openscale/core/models/measurement_value.dart';
import 'package:openscale/core/database/dao/measurement_dao.dart';
import 'package:openscale/core/bloc/measurement/measurement_bloc.dart';
import 'package:openscale/core/bloc/measurement/measurement_event.dart';
import 'package:openscale/core/bloc/measurement/measurement_state.dart';

class FakeMeasurementRepository extends MeasurementRepository {
  List<MeasurementWithValues> _data = [];
  Object? _getAllError;
  Object? _insertError;
  Object? _deleteError;

  void setData(List<MeasurementWithValues> data) => _data = List.from(data);

  void setGetAllError(Object error) => _getAllError = error;
  void setInsertError(Object error) => _insertError = error;
  void setDeleteError(Object error) => _deleteError = error;

  @override
  Future<List<MeasurementWithValues>> getMeasurementsForUser(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    if (_getAllError != null) throw _getAllError!;
    return List.from(_data);
  }

  @override
  Future<MeasurementWithValues?> getLatestMeasurement(String userId) async {
    if (_data.isEmpty) return null;
    return _data.first;
  }

  @override
  Future<String> insertMeasurementWithValues(
    Measurement measurement,
    List<MeasurementValue> values,
  ) async {
    if (_insertError != null) throw _insertError!;
    final id = 'm-${_data.length}';
    _data.add(
      MeasurementWithValues(
        measurement: measurement.copyWith(id: id),
        values: values.map((v) => v.copyWith(measurementId: id)).toList(),
      ),
    );
    return id;
  }

  @override
  Future<void> deleteMeasurement(String id) async {
    if (_deleteError != null) throw _deleteError!;
    _data.removeWhere((d) => d.measurement.id == id);
  }
}

MeasurementWithValues _makeMeasurementWithValues({
  String id = 'm-1',
  String userId = 'u-1',
  double weight = 72.5,
  DateTime? dateTime,
  String? comment,
}) {
  dateTime ??= DateTime(2025, 3, 15, 10, 30);
  return MeasurementWithValues(
    measurement: Measurement(
      id: id,
      userId: userId,
      dateTime: dateTime,
      comment: comment,
    ),
    values: [
      MeasurementValue(
        id: 'v-$id',
        measurementId: id,
        measurementTypeKey: MeasurementTypeKey.weight,
        value: weight,
      ),
    ],
  );
}

void main() {
  group('MeasurementBloc', () {
    late FakeMeasurementRepository repository;
    late MeasurementBloc bloc;

    setUp(() {
      repository = FakeMeasurementRepository();
      bloc = MeasurementBloc(repository);
    });

    tearDown(() {
      bloc.close();
    });

    blocTest<MeasurementBloc, MeasurementState>(
      'initial state has empty measurements, not loading',
      build: () => bloc,
      verify: (bloc) {
        expect(bloc.state.measurements, isEmpty);
        expect(bloc.state.isLoading, false);
        expect(bloc.state.error, isNull);
      },
    );

    blocTest<MeasurementBloc, MeasurementState>(
      'LoadMeasurements emits loading then loaded with measurements',
      build: () => bloc,
      setUp: () {
        repository.setData([
          _makeMeasurementWithValues(id: 'm-1', weight: 72.5),
          _makeMeasurementWithValues(id: 'm-2', weight: 71.0),
        ]);
      },
      act: (bloc) => bloc.add(const LoadMeasurements('u-1')),
      expect: () => [
        isA<MeasurementState>().having((s) => s.isLoading, 'loading', true),
        isA<MeasurementState>()
            .having((s) => s.isLoading, 'loading', false)
            .having((s) => s.measurements.length, 'count', 2)
            .having((s) => s.measurements.first.weight, 'first weight', 72.5)
            .having((s) => s.measurements.last.weight, 'last weight', 71.0),
      ],
    );

    blocTest<MeasurementBloc, MeasurementState>(
      'LoadMeasurements sets error when repository throws',
      build: () => bloc,
      setUp: () {
        repository.setGetAllError(Exception('db error'));
      },
      act: (bloc) => bloc.add(const LoadMeasurements('u-1')),
      expect: () => [
        isA<MeasurementState>().having((s) => s.isLoading, 'loading', true),
        isA<MeasurementState>()
            .having((s) => s.isLoading, 'loading', false)
            .having((s) => s.error, 'error', 'Exception: db error'),
      ],
    );

    blocTest<MeasurementBloc, MeasurementState>(
      'AddMeasurement creates measurement and reloads',
      build: () => bloc,
      act: (bloc) => bloc
        ..add(const LoadMeasurements('u-1'))
        ..add(
          AddMeasurement(
            dateTime: DateTime(2025, 4, 1),
            weight: 70.0,
            comment: 'Test',
          ),
        ),
      skip: 2, // skip LoadMeasurements loading + loaded
      verify: (bloc) {
        expect(bloc.state.measurements.isNotEmpty, true);
      },
    );

    blocTest<MeasurementBloc, MeasurementState>(
      'AddMeasurement does nothing when no current user',
      build: () => bloc,
      act: (bloc) => bloc.add(
        AddMeasurement(dateTime: DateTime(2025, 4, 1), weight: 70.0),
      ),
      expect: () => [], // no state changes
    );

    blocTest<MeasurementBloc, MeasurementState>(
      'AddMeasurement sets error when repository throws',
      build: () => bloc,
      setUp: () {
        repository.setInsertError(Exception('insert failed'));
      },
      act: (bloc) => bloc
        ..add(const LoadMeasurements('u-1'))
        ..add(AddMeasurement(dateTime: DateTime(2025, 4, 1), weight: 70.0)),
      skip: 2,
      expect: () => [
        isA<MeasurementState>().having(
          (s) => s.error,
          'error',
          'Exception: insert failed',
        ),
      ],
    );

    blocTest<MeasurementBloc, MeasurementState>(
      'DeleteMeasurement removes and reloads',
      build: () => bloc,
      setUp: () {
        repository.setData([_makeMeasurementWithValues(id: 'm-1')]);
      },
      act: (bloc) => bloc
        ..add(const LoadMeasurements('u-1'))
        ..add(const DeleteMeasurement('m-1')),
      skip: 2,
      verify: (bloc) {
        expect(bloc.state.measurements, isEmpty);
      },
    );

    blocTest<MeasurementBloc, MeasurementState>(
      'DeleteMeasurement sets error when repository throws',
      build: () => bloc,
      setUp: () {
        repository.setDeleteError(Exception('delete failed'));
      },
      act: (bloc) => bloc
        ..add(const LoadMeasurements('u-1'))
        ..add(const DeleteMeasurement('m-1')),
      skip: 2,
      expect: () => [
        isA<MeasurementState>().having(
          (s) => s.error,
          'error',
          'Exception: delete failed',
        ),
      ],
    );

    blocTest<MeasurementBloc, MeasurementState>(
      'SetDateRange updates date range and reloads',
      build: () => bloc,
      setUp: () {
        repository.setData([_makeMeasurementWithValues(id: 'm-1')]);
      },
      act: (bloc) => bloc
        ..add(const LoadMeasurements('u-1'))
        ..add(
          SetDateRange(
            startDate: DateTime(2025, 1, 1),
            endDate: DateTime(2025, 12, 31),
          ),
        ),
      skip: 2, // skip LoadMeasurements loading + loaded
      verify: (bloc) {
        expect(bloc.state.startDate, DateTime(2025, 1, 1));
        expect(bloc.state.endDate, DateTime(2025, 12, 31));
      },
    );

    blocTest<MeasurementBloc, MeasurementState>(
      'SetDateRange with no current user updates range only',
      build: () => bloc,
      act: (bloc) => bloc.add(
        SetDateRange(
          startDate: DateTime(2025, 1, 1),
          endDate: DateTime(2025, 12, 31),
        ),
      ),
      expect: () => [
        isA<MeasurementState>()
            .having((s) => s.startDate, 'startDate', DateTime(2025, 1, 1))
            .having((s) => s.endDate, 'endDate', DateTime(2025, 12, 31)),
      ],
    );
  });
}
