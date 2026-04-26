import 'package:flutter_test/flutter_test.dart';
import 'package:openscale/core/models/enums.dart';
import 'package:openscale/core/utils/body_composition/standard_impedance_lib.dart';

void main() {
  const double eps = 1e-3;

  final lib = StandardImpedanceLib(
    gender: Gender.male,
    age: 30,
    weightKg: 80.0,
    heightM: 1.8,
    impedance: 527.0,
  );

  test('bmi is computed correctly for typical male', () {
    expect(lib.bmi, closeTo(24.69136, eps));
    expect(lib.fatFreeMassKg, closeTo(60.622, eps));
    expect(lib.totalFatPercentage, closeTo(24.222, eps));
    expect(lib.totalBodyWaterPercentage, closeTo(53.819, eps));
    expect(lib.basalMetabolicRate, closeTo(1679.436, eps));
    expect(lib.skeletalMusclePercentage, closeTo(39.313, eps));
    expect(lib.boneMassKg, closeTo(3.455, eps));

    // We're within +/-3% of TBW / FFM = 0.732
    const double tbwFFM = 0.732;
    expect(
      lib.totalBodyWaterKg / lib.fatFreeMassKg,
      closeTo(tbwFFM, tbwFFM * 0.03),
    );
  });

  test('bmi monotonicity: weight up, height same -> increases', () {
    final heavier = StandardImpedanceLib(
      gender: Gender.male,
      age: 30,
      weightKg: 85.0,
      heightM: 1.8,
      impedance: 527.0,
    );
    expect(heavier.bmi, greaterThan(lib.bmi));
  });

  test('bmi monotonicity: height up, weight same -> decreases', () {
    final taller = StandardImpedanceLib(
      gender: Gender.male,
      age: 30,
      weightKg: 80.0,
      heightM: 1.85,
      impedance: 527.0,
    );
    expect(taller.bmi, lessThan(lib.bmi));
  });
}
