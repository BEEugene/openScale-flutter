import '../../models/enums.dart';

/// User context provided to scale drivers for body composition calculations
/// and user management on the device.
class ScaleUser {
  final int id;
  final String name;
  final DateTime birthday;
  final double bodyHeight; // always in cm
  final Gender gender;
  final double initialWeight; // always in kg
  final double goalWeight; // always in kg
  final UnitType scaleUnit;
  final ActivityLevel activityLevel;

  ScaleUser({
    required this.id,
    this.name = '',
    DateTime? birthday,
    this.bodyHeight = -1.0,
    this.gender = Gender.male,
    this.initialWeight = 0.0,
    this.goalWeight = 0.0,
    this.scaleUnit = UnitType.kg,
    this.activityLevel = ActivityLevel.sedentary,
  }) : birthday = birthday ?? DateTime(2000, 1, 1);

  /// Calculate age from birthday to [today], or current date if null.
  int age([DateTime? today]) {
    final ref = today ?? DateTime.now();
    int years = ref.year - birthday.year;
    if (ref.month < birthday.month ||
        (ref.month == birthday.month && ref.day < birthday.day)) {
      years--;
    }
    return years;
  }

  bool get isMale => gender == Gender.male;

  @override
  String toString() =>
      'ScaleUser(id=$id, name=$name, height=${bodyHeight}cm, age=${age()}, '
      'gender=$gender)';
}
