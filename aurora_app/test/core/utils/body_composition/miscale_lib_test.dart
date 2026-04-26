import 'package:flutter_test/flutter_test.dart';
import 'package:openscale/core/utils/body_composition/miscale_lib.dart';

void main() {
  const double eps = 1e-3;

  // --- Simple BMI checks ---

  test('bmi is computed correctly for typical male', () {
    final lib = MiScaleLib(sex: 1, age: 30, height: 180.0);
    const double weight = 80.0;
    final bmi = lib.getBMI(weight);
    expect(bmi, closeTo(24.691358, eps));
  });

  test('bmi monotonicity: weight up, height same -> increases', () {
    final lib = MiScaleLib(sex: 0, age: 28, height: 165.0);
    final bmi1 = lib.getBMI(60.0);
    final bmi2 = lib.getBMI(65.0);
    expect(bmi2, greaterThan(bmi1));
  });

  test('bmi monotonicity: height up, weight same -> decreases', () {
    final libShort = MiScaleLib(sex: 1, age: 35, height: 170.0);
    final libTall = MiScaleLib(sex: 1, age: 35, height: 185.0);
    const double weight = 80.0;
    expect(libTall.getBMI(weight), lessThan(libShort.getBMI(weight)));
  });

  // --- Regression values for full model ---

  test('regression male 30y 180cm 80kg imp500', () {
    final lib = MiScaleLib(sex: 1, age: 30, height: 180.0);
    const double weight = 80.0;

    expect(lib.getBMI(weight), closeTo(24.691359, eps));
    expect(lib.getBodyFat(weight, 500.0), closeTo(23.315107, eps));
    expect(lib.getBoneMass(weight, 500.0), closeTo(3.1254203, eps));
    expect(lib.getLBM(weight, 500.0), closeTo(58.222496, eps));
    expect(lib.getMuscle(weight, 500.0), closeTo(40.977253, eps));
    expect(lib.getWater(weight, 500.0), closeTo(52.605835, eps));
    expect(lib.getVisceralFat(weight), closeTo(13.359997, eps));
  });

  test('regression female 28y 165cm 60kg imp520', () {
    final lib = MiScaleLib(sex: 0, age: 28, height: 165.0);
    const double weight = 60.0;

    expect(lib.getBMI(weight), closeTo(22.038567, eps));
    expect(lib.getBodyFat(weight, 520.0), closeTo(30.361998, eps));
    expect(lib.getBoneMass(weight, 520.0), closeTo(2.4865808, eps));
    expect(lib.getLBM(weight, 520.0), closeTo(39.29622, eps));
    expect(lib.getMuscle(weight, 520.0), closeTo(40.181103, eps));
    expect(lib.getWater(weight, 520.0), closeTo(49.72153, eps));
    expect(lib.getVisceralFat(weight), closeTo(-36.555004, eps));
  });

  test('regression male 45y 175cm 95kg imp430', () {
    final lib = MiScaleLib(sex: 1, age: 45, height: 175.0);
    const double weight = 95.0;

    expect(lib.getBMI(weight), closeTo(31.020409, eps));
    expect(lib.getBodyFat(weight, 430.0), closeTo(32.41778, eps));
    expect(lib.getBoneMass(weight, 430.0), closeTo(3.2726917, eps));
    expect(lib.getLBM(weight, 430.0), closeTo(60.93042, eps));
    expect(lib.getMuscle(weight, 430.0), closeTo(36.096416, eps));
    expect(lib.getWater(weight, 430.0), closeTo(48.2537, eps));
    expect(lib.getVisceralFat(weight), closeTo(24.462498, eps));
  });

  // --- Special paths & edge behavior ---

  test('muscle fallback when impedance zero uses LBM ratio and is clamped', () {
    final lib = MiScaleLib(sex: 0, age: 52, height: 160.0);
    const double weight = 48.0;

    final double lbm = lib.getLBM(weight, 0.0);
    final double expectedPct = (lbm * 0.46) / weight * 100;
    final double expectedClamped = expectedPct.clamp(10.0, 60.0);

    final double actual = lib.getMuscle(weight, 0.0);
    expect(actual, closeTo(expectedClamped, eps));
    expect(actual, greaterThanOrEqualTo(10.0));
    expect(actual, lessThanOrEqualTo(60.0));
  });

  test('muscle percentage is clamped at 60 when extremely high', () {
    final lib = MiScaleLib(sex: 1, age: 20, height: 190.0);
    final double clamped = lib.getMuscle(40.0, 50.0);
    expect(clamped, closeTo(60.0, eps));
  });

  test('water derives from body fat and uses coeff branch', () {
    final lib = MiScaleLib(sex: 0, age: 50, height: 150.0);
    const double weight = 100.0;
    const double imp = 700.0;

    final double bf = lib.getBodyFat(weight, imp);
    final double raw = (100.0 - bf) * 0.7;
    final double coeff = raw < 50 ? 1.02 : 0.98;
    final double expected = raw * coeff;

    final double water = lib.getWater(weight, imp);
    expect(water, closeTo(expected, eps));
    if (raw < 50) {
      expect(water, lessThan(50.0));
    } else {
      expect(water, greaterThan(50.0));
    }
  });

  test('outputs are finite for typical inputs', () {
    final lib = MiScaleLib(sex: 1, age: 30, height: 180.0);
    const double weight = 80.0;
    const double imp = 500.0;

    final values = [
      lib.getBMI(weight),
      lib.getBodyFat(weight, imp),
      lib.getBoneMass(weight, imp),
      lib.getLBM(weight, imp),
      lib.getMuscle(weight, imp),
      lib.getWater(weight, imp),
      lib.getVisceralFat(weight),
    ];
    for (final v in values) {
      expect(v.isNaN, isFalse);
      expect(v.isInfinite, isFalse);
    }
  });
}
