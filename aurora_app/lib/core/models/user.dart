import 'package:equatable/equatable.dart';
import 'package:openscale/core/models/enums.dart';

class User extends Equatable {
  final String id;
  final String name;
  final DateTime birthday;
  final double bodyHeight;
  final Gender gender;
  final double initialWeight;
  final double goalWeight;
  final UnitType scaleUnit;
  final ActivityLevel activityLevel;

  const User({
    required this.id,
    required this.name,
    required this.birthday,
    required this.bodyHeight,
    required this.gender,
    required this.initialWeight,
    required this.goalWeight,
    required this.scaleUnit,
    required this.activityLevel,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    birthday,
    bodyHeight,
    gender,
    initialWeight,
    goalWeight,
    scaleUnit,
    activityLevel,
  ];

  User copyWith({
    String? id,
    String? name,
    DateTime? birthday,
    double? bodyHeight,
    Gender? gender,
    double? initialWeight,
    double? goalWeight,
    UnitType? scaleUnit,
    ActivityLevel? activityLevel,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      birthday: birthday ?? this.birthday,
      bodyHeight: bodyHeight ?? this.bodyHeight,
      gender: gender ?? this.gender,
      initialWeight: initialWeight ?? this.initialWeight,
      goalWeight: goalWeight ?? this.goalWeight,
      scaleUnit: scaleUnit ?? this.scaleUnit,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }

  factory User.fromMap(Map<String, Object?> map) {
    return User(
      id: map['id'] as String,
      name: map['name'] as String,
      birthday: DateTime.fromMillisecondsSinceEpoch(map['birthday'] as int),
      bodyHeight: (map['body_height'] as num).toDouble(),
      gender: Gender.fromName(map['gender'] as String),
      initialWeight: (map['initial_weight'] as num).toDouble(),
      goalWeight: (map['goal_weight'] as num).toDouble(),
      scaleUnit: UnitType.fromName(map['scale_unit'] as String),
      activityLevel: ActivityLevel.fromInt(map['activity_level'] as int),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'birthday': birthday.millisecondsSinceEpoch,
      'body_height': bodyHeight,
      'gender': gender.name,
      'initial_weight': initialWeight,
      'goal_weight': goalWeight,
      'scale_unit': scaleUnit.name,
      'activity_level': activityLevel.value,
    };
  }
}
