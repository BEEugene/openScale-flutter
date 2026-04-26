import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class MeasurementUiValue extends Equatable {
  final String typeId;
  final String typeKey;
  final String typeName;
  final double value;
  final String unit;
  final Color color;

  const MeasurementUiValue({
    required this.typeId,
    required this.typeKey,
    required this.typeName,
    required this.value,
    required this.unit,
    this.color = Colors.grey,
  });

  @override
  List<Object?> get props => [typeId, typeKey, typeName, value, unit, color];
}

class MeasurementUiModel extends Equatable {
  final String id;
  final DateTime dateTime;
  final double weight;
  final String trend;
  final String? comment;
  final List<MeasurementUiValue> values;

  const MeasurementUiModel({
    required this.id,
    required this.dateTime,
    required this.weight,
    this.trend = 'stable',
    this.comment,
    this.values = const [],
  });

  @override
  List<Object?> get props => [id, dateTime, weight, trend, comment, values];
}

class MeasurementState extends Equatable {
  final bool isLoading;
  final List<MeasurementUiModel> measurements;
  final String? error;
  final DateTime? startDate;
  final DateTime? endDate;

  const MeasurementState({
    this.isLoading = false,
    this.measurements = const [],
    this.error,
    this.startDate,
    this.endDate,
  });

  MeasurementState copyWith({
    bool? isLoading,
    List<MeasurementUiModel>? measurements,
    String? error,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return MeasurementState(
      isLoading: isLoading ?? this.isLoading,
      measurements: measurements ?? this.measurements,
      error: error,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    measurements,
    error,
    startDate,
    endDate,
  ];
}
