import 'package:flutter_test/flutter_test.dart';
import 'package:openscale/core/models/enums.dart';
import 'package:openscale/core/utils/body_composition/etekcity_lib.dart';

void main() {
  const double eps = 1e-3;

  final lib = EtekcityLib(
    gender: Gender.male,
    age: 30,
    weightKg: 80.0,
    heightM: 1.8,
    impedance: 527.0,
  );

  test('bmi is computed correctly for typical male', () {
    expect(lib.bmi, closeTo(24.69136, eps));
    expect(lib.bodyFatPercentage, closeTo(17.7, eps));
    expect(lib.fatFreeWeight, closeTo(65.84, eps));
    expect(lib.visceralFat, closeTo(7.64163, eps));
    expect(lib.water, closeTo(59.4206, eps));
    expect(lib.basalMetabolicRate, closeTo(1792.144, eps));
    expect(lib.skeletalMusclePercentage, closeTo(53.1658, eps));
    expect(lib.boneMass, closeTo(3.292, eps));
    expect(lib.subcutaneousFat, closeTo(15.3993, eps));
    expect(lib.muscleMass, closeTo(62.548, eps));
    expect(lib.proteinPercentage, closeTo(18.7644, eps));
    expect(lib.weightScore, equals(76));
    expect(lib.fatScore, equals(97));
    expect(lib.bmiScore, equals(89));
    expect(lib.healthScore, equals(87));
    expect(lib.metabolicAge, equals(29));
  });

  test('bmi monotonicity: weight up, height same -> increases', () {
    final heavier = EtekcityLib(
      gender: Gender.male,
      age: 30,
      weightKg: 85.0,
      heightM: 1.8,
      impedance: 527.0,
    );
    expect(heavier.bmi, greaterThan(lib.bmi));
  });

  test('bmi monotonicity: height up, weight same -> decreases', () {
    final taller = EtekcityLib(
      gender: Gender.male,
      age: 30,
      weightKg: 80.0,
      heightM: 1.85,
      impedance: 527.0,
    );
    expect(taller.bmi, lessThan(lib.bmi));
  });
}
