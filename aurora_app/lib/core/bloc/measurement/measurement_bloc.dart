import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openscale/core/models/measurement.dart';
import 'package:openscale/core/models/measurement_value.dart';
import 'package:openscale/core/models/enums.dart';
import 'package:openscale/core/database/dao/measurement_dao.dart';
import 'package:openscale/core/bloc/measurement/measurement_event.dart';
import 'package:openscale/core/bloc/measurement/measurement_state.dart';
import 'package:openscale/ui/theme/app_colors.dart';

export 'measurement_event.dart';
export 'measurement_state.dart';

abstract class MeasurementRepository {
  Future<List<MeasurementWithValues>> getMeasurementsForUser(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });
  Future<MeasurementWithValues?> getLatestMeasurement(String userId);
  Future<String> insertMeasurementWithValues(
    Measurement measurement,
    List<MeasurementValue> values,
  );
  Future<void> deleteMeasurement(String id);
}

class MeasurementBloc extends Bloc<MeasurementEvent, MeasurementState> {
  final MeasurementRepository _repository;
  String? _currentUserId;

  MeasurementBloc(this._repository) : super(const MeasurementState()) {
    on<LoadMeasurements>(_onLoadMeasurements);
    on<AddMeasurement>(_onAddMeasurement);
    on<DeleteMeasurement>(_onDeleteMeasurement);
    on<UpdateMeasurementValue>(_onUpdateMeasurementValue);
    on<SetDateRange>(_onSetDateRange);
  }

  Future<void> _onLoadMeasurements(
    LoadMeasurements event,
    Emitter<MeasurementState> emit,
  ) async {
    _currentUserId = event.userId;
    emit(state.copyWith(isLoading: true));
    try {
      final results = await _repository.getMeasurementsForUser(
        event.userId,
        startDate: state.startDate,
        endDate: state.endDate,
      );
      final uiModels = results.map(_toUiModel).toList();
      emit(state.copyWith(measurements: uiModels, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onAddMeasurement(
    AddMeasurement event,
    Emitter<MeasurementState> emit,
  ) async {
    if (_currentUserId == null) return;
    try {
      final measurement = Measurement(
        id: '',
        userId: _currentUserId!,
        dateTime: event.dateTime,
        comment: event.comment,
      );
      final values = [
        MeasurementValue(
          id: '',
          measurementId: '',
          measurementTypeKey: MeasurementTypeKey.weight,
          value: event.weight,
        ),
      ];
      await _repository.insertMeasurementWithValues(measurement, values);
      await _reloadMeasurements(emit);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDeleteMeasurement(
    DeleteMeasurement event,
    Emitter<MeasurementState> emit,
  ) async {
    try {
      await _repository.deleteMeasurement(event.measurementId);
      await _reloadMeasurements(emit);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUpdateMeasurementValue(
    UpdateMeasurementValue event,
    Emitter<MeasurementState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _reloadMeasurements(emit);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onSetDateRange(
    SetDateRange event,
    Emitter<MeasurementState> emit,
  ) async {
    emit(state.copyWith(startDate: event.startDate, endDate: event.endDate));
    if (_currentUserId != null) {
      add(LoadMeasurements(_currentUserId!));
    }
  }

  Future<void> _reloadMeasurements(Emitter<MeasurementState> emit) async {
    if (_currentUserId == null) return;
    final results = await _repository.getMeasurementsForUser(
      _currentUserId!,
      startDate: state.startDate,
      endDate: state.endDate,
    );
    final uiModels = results.map(_toUiModel).toList();
    emit(state.copyWith(measurements: uiModels, isLoading: false));
  }

  MeasurementUiModel _toUiModel(MeasurementWithValues data) {
    final measurement = data.measurement;
    final values = data.values;

    double weight = 0;
    final uiValues = <MeasurementUiValue>[];

    for (final v in values) {
      if (v.measurementTypeKey == MeasurementTypeKey.weight) {
        weight = v.value;
      }
      uiValues.add(
        MeasurementUiValue(
          typeId: v.measurementTypeKey.name,
          typeKey: v.measurementTypeKey.name,
          typeName: v.measurementTypeKey.name,
          value: v.value,
          unit: _getUnitForType(v.measurementTypeKey),
          color: _getColorForType(v.measurementTypeKey),
        ),
      );
    }

    return MeasurementUiModel(
      id: measurement.id,
      dateTime: measurement.dateTime,
      weight: weight,
      trend: 'stable',
      comment: measurement.comment,
      values: uiValues,
    );
  }

  String _getUnitForType(MeasurementTypeKey key) {
    return key.allowedUnitTypes.isNotEmpty
        ? key.allowedUnitTypes.first.displayName
        : '';
  }

  Color _getColorForType(MeasurementTypeKey key) {
    return switch (key) {
      MeasurementTypeKey.weight => AppColors.weight,
      MeasurementTypeKey.bmi => AppColors.bmi,
      MeasurementTypeKey.bodyFat => AppColors.fat,
      MeasurementTypeKey.water => AppColors.water,
      MeasurementTypeKey.muscle => AppColors.muscle,
      MeasurementTypeKey.lbm => AppColors.lbm,
      MeasurementTypeKey.bone => AppColors.bone,
      MeasurementTypeKey.waist => AppColors.waist,
      MeasurementTypeKey.whr => AppColors.whr,
      MeasurementTypeKey.whtr => AppColors.whtr,
      MeasurementTypeKey.hips => AppColors.hips,
      MeasurementTypeKey.visceralFat => AppColors.visceralFat,
      MeasurementTypeKey.chest => AppColors.chest,
      MeasurementTypeKey.thigh => AppColors.thigh,
      MeasurementTypeKey.biceps => AppColors.biceps,
      MeasurementTypeKey.neck => AppColors.neck,
      MeasurementTypeKey.caliper => AppColors.caliper,
      MeasurementTypeKey.bmr => AppColors.bmr,
      MeasurementTypeKey.tdee => AppColors.tdee,
      MeasurementTypeKey.heartRate => AppColors.heartRate,
      MeasurementTypeKey.calories => AppColors.calories,
      _ => Colors.grey,
    };
  }
}
