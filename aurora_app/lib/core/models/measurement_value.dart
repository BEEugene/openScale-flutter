import 'package:equatable/equatable.dart';
import 'package:openscale/core/models/enums.dart';

class MeasurementValue extends Equatable {
  final String id;
  final String measurementId;
  final MeasurementTypeKey measurementTypeKey;
  final double value;

  const MeasurementValue({
    required this.id,
    required this.measurementId,
    required this.measurementTypeKey,
    required this.value,
  });

  @override
  List<Object?> get props => [id, measurementId, measurementTypeKey, value];

  MeasurementValue copyWith({
    String? id,
    String? measurementId,
    MeasurementTypeKey? measurementTypeKey,
    double? value,
  }) {
    return MeasurementValue(
      id: id ?? this.id,
      measurementId: measurementId ?? this.measurementId,
      measurementTypeKey: measurementTypeKey ?? this.measurementTypeKey,
      value: value ?? this.value,
    );
  }

  factory MeasurementValue.fromMap(Map<String, Object?> map) {
    return MeasurementValue(
      id: map['id'] as String,
      measurementId: map['measurement_id'] as String,
      measurementTypeKey: MeasurementTypeKey.fromName(
        map['measurement_type_key'] as String,
      ),
      value: (map['value'] as num).toDouble(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'measurement_id': measurementId,
      'measurement_type_key': measurementTypeKey.name,
      'value': value,
    };
  }
}
