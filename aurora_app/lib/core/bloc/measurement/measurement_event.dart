import 'package:equatable/equatable.dart';

abstract class MeasurementEvent extends Equatable {
  const MeasurementEvent();

  @override
  List<Object?> get props => [];
}

class LoadMeasurements extends MeasurementEvent {
  final String userId;

  const LoadMeasurements(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddMeasurement extends MeasurementEvent {
  final DateTime dateTime;
  final double weight;
  final String? comment;

  const AddMeasurement({
    required this.dateTime,
    required this.weight,
    this.comment,
  });

  @override
  List<Object?> get props => [dateTime, weight, comment];
}

class DeleteMeasurement extends MeasurementEvent {
  final String measurementId;

  const DeleteMeasurement(this.measurementId);

  @override
  List<Object?> get props => [measurementId];
}

class UpdateMeasurementValue extends MeasurementEvent {
  final String measurementId;
  final String typeId;
  final double newValue;

  const UpdateMeasurementValue({
    required this.measurementId,
    required this.typeId,
    required this.newValue,
  });

  @override
  List<Object?> get props => [measurementId, typeId, newValue];
}

class SetDateRange extends MeasurementEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const SetDateRange({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}
