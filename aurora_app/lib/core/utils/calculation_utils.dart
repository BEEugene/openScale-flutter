import 'dart:math' as math;
import 'package:openscale/core/models/enums.dart';

double calculateBmi(double weightKg, double heightCm) {
  if (heightCm <= 0) return 0.0;
  final heightM = heightCm / 100.0;
  return weightKg / (heightM * heightM);
}

// Mifflin-St Jeor equation: kcal/day
double calculateBmr({
  required double weightKg,
  required double heightCm,
  required int age,
  required Gender gender,
}) {
  if (gender == Gender.male) {
    return (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * age) + 5.0;
  }
  return (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * age) - 161.0;
}

double calculateTdee(double bmr, ActivityLevel activityLevel) {
  const multipliers = <ActivityLevel, double>{
    ActivityLevel.sedentary: 1.2,
    ActivityLevel.mild: 1.375,
    ActivityLevel.moderate: 1.55,
    ActivityLevel.heavy: 1.725,
    ActivityLevel.extreme: 1.9,
  };
  return bmr * (multipliers[activityLevel] ?? 1.2);
}

// Deurenberg (1991) body fat estimation
double estimateBodyFatDeurenberg1991({
  required double bmi,
  required int age,
  required Gender gender,
}) {
  final genderFactor = gender == Gender.male ? 1.0 : 0.0;
  return (1.20 * bmi) + (0.23 * age) - (10.8 * genderFactor) - 5.4;
}

// US Navy body fat estimation (requires waist and neck circumference in cm)
double estimateBodyFatUsNavy({
  required double waistCm,
  required double neckCm,
  required double heightCm,
  required Gender gender,
  double? hipsCm,
}) {
  if (gender == Gender.male) {
    return 495.0 /
            (1.0324 -
                0.19077 * (waistCm - neckCm).abs().log10() +
                0.15456 * heightCm.log10()) -
        450.0;
  }
  final hips = hipsCm ?? 0.0;
  return 495.0 /
          (1.29579 -
              0.35004 * (waistCm + hips - neckCm).abs().log10() +
              0.22100 * heightCm.log10()) -
      450.0;
}

double convertWeight(double value, UnitType from, UnitType to) {
  if (from == to) return value;
  final kg = _toKg(value, from);
  return _fromKg(kg, to);
}

double _toKg(double value, UnitType unit) {
  switch (unit) {
    case UnitType.kg:
      return value;
    case UnitType.lb:
      return value * 0.45359237;
    case UnitType.st:
      return value * 6.35029318;
    default:
      return value;
  }
}

double _fromKg(double kg, UnitType unit) {
  switch (unit) {
    case UnitType.kg:
      return kg;
    case UnitType.lb:
      return kg / 0.45359237;
    case UnitType.st:
      return kg / 6.35029318;
    default:
      return kg;
  }
}

extension on double {
  double log10() {
    if (this <= 0) return 0.0;
    return math.log(this) / math.ln10;
  }
}
