import 'package:equatable/equatable.dart';
import 'package:openscale/core/models/enums.dart';

class UserGoal extends Equatable {
  final String id;
  final String userId;
  final MeasurementTypeKey measurementTypeKey;
  final double goalValue;
  final DateTime? goalDate;

  const UserGoal({
    required this.id,
    required this.userId,
    required this.measurementTypeKey,
    required this.goalValue,
    this.goalDate,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    measurementTypeKey,
    goalValue,
    goalDate,
  ];

  UserGoal copyWith({
    String? id,
    String? userId,
    MeasurementTypeKey? measurementTypeKey,
    double? goalValue,
    DateTime? goalDate,
  }) {
    return UserGoal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      measurementTypeKey: measurementTypeKey ?? this.measurementTypeKey,
      goalValue: goalValue ?? this.goalValue,
      goalDate: goalDate ?? this.goalDate,
    );
  }

  factory UserGoal.fromMap(Map<String, Object?> map) {
    return UserGoal(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      measurementTypeKey: MeasurementTypeKey.fromName(
        map['measurement_type_key'] as String,
      ),
      goalValue: (map['goal_value'] as num).toDouble(),
      goalDate: map['goal_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['goal_date'] as int)
          : null,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'measurement_type_key': measurementTypeKey.name,
      'goal_value': goalValue,
      'goal_date': goalDate?.millisecondsSinceEpoch,
    };
  }
}
