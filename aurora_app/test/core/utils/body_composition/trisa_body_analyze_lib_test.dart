import 'package:flutter_test/flutter_test.dart';
import 'package:openscale/core/utils/body_composition/trisa_body_analyze_lib.dart';

void main() {
  const double eps = 1e-3;

  // --- Simple BMI checks ---

  test('bmi is computed correctly for typical male', () {
    final lib = TrisaBodyAnalyzeLib(sex: 1, ageYears: 30, heightCm: 180.0);
    const double weight = 80.0;

    final bmi = lib.getBMI(weight);

    expect(bmi, closeTo(24.691358, eps));
  });

  test('bmi monotonicity: weight up, height same -> increases', () {
    final lib = TrisaBodyAnalyzeLib(sex: 0, ageYears: 28, heightCm: 165.0);
    final bmi1 = lib.getBMI(60.0);
    final bmi2 = lib.getBMI(65.0);
    expect(bmi2, greaterThan(bmi1));
  });

  test('bmi monotonicity: height up, weight same -> decreases', () {
    final shorty = TrisaBodyAnalyzeLib(sex: 1, ageYears: 35, heightCm: 170.0);
    final tall = TrisaBodyAnalyzeLib(sex: 1, ageYears: 35, heightCm: 185.0);
    const double weight = 80.0;
    expect(tall.getBMI(weight), lessThan(shorty.getBMI(weight)));
  });

  // --- Behavioral properties ---

  test('impedance effects have expected directions', () {
    final male = TrisaBodyAnalyzeLib(sex: 1, ageYears: 30, heightCm: 180.0);
    final female = TrisaBodyAnalyzeLib(sex: 0, ageYears: 30, heightCm: 165.0);

    const double w = 70.0;
    const double impLow = 300.0;
    const double impHigh = 700.0;

    expect(male.getWater(w, impHigh), lessThan(male.getWater(w, impLow)));
    expect(male.getMuscle(w, impHigh), lessThan(male.getMuscle(w, impLow)));
    expect(male.getBone(w, impHigh), lessThan(male.getBone(w, impLow)));
    expect(male.getFat(w, impHigh), greaterThan(male.getFat(w, impLow)));

    expect(female.getWater(w, impHigh), lessThan(female.getWater(w, impLow)));
    expect(female.getMuscle(w, impHigh), lessThan(female.getMuscle(w, impLow)));
    expect(female.getBone(w, impHigh), lessThan(female.getBone(w, impLow)));
    expect(female.getFat(w, impHigh), greaterThan(female.getFat(w, impLow)));
  });

  test('sex flag changes branch outputs', () {
    final male = TrisaBodyAnalyzeLib(sex: 1, ageYears: 30, heightCm: 175.0);
    final female = TrisaBodyAnalyzeLib(sex: 0, ageYears: 30, heightCm: 175.0);
    const double w = 70.0;
    const double imp = 500.0;

    expect(male.getWater(w, imp), isNot(equals(female.getWater(w, imp))));
    expect(male.getFat(w, imp), isNot(equals(female.getFat(w, imp))));
    expect(male.getMuscle(w, imp), isNot(equals(female.getMuscle(w, imp))));
    expect(male.getBone(w, imp), isNot(equals(female.getBone(w, imp))));
  });

  test('outputs are finite for typical inputs', () {
    final lib = TrisaBodyAnalyzeLib(sex: 1, ageYears: 30, heightCm: 180.0);
    const double w = 80.0;
    const double imp = 500.0;

    final nums = [
      lib.getBMI(w),
      lib.getWater(w, imp),
      lib.getFat(w, imp),
      lib.getMuscle(w, imp),
      lib.getBone(w, imp),
    ];

    for (final v in nums) {
      expect(v.isNaN, isFalse);
      expect(v.isInfinite, isFalse);
    }
  });

  // --- Regression fixtures ---

  void checkFixture(
    TrisaBodyAnalyzeLib lib,
    double w,
    double imp, {
    required double bmi,
    required double water,
    required double fat,
    required double muscle,
    required double bone,
  }) {
    expect(lib.getBMI(w), closeTo(bmi, eps));
    expect(lib.getWater(w, imp), closeTo(water, eps));
    expect(lib.getFat(w, imp), closeTo(fat, eps));
    expect(lib.getMuscle(w, imp), closeTo(muscle, eps));
    expect(lib.getBone(w, imp), closeTo(bone, eps));
  }

  test('regression male 30y 180cm 80kg imp500', () {
    final lib = TrisaBodyAnalyzeLib(sex: 1, ageYears: 30, heightCm: 180.0);
    checkFixture(
      lib,
      80.0,
      500.0,
      bmi: 24.691359,
      water: 57.031845,
      fat: 23.186619,
      muscle: 40.767307,
      bone: 4.254889,
    );
  });

  test('regression female 28y 165cm 60kg imp520', () {
    final lib = TrisaBodyAnalyzeLib(sex: 0, ageYears: 28, heightCm: 165.0);
    checkFixture(
      lib,
      60.0,
      520.0,
      bmi: 22.038567,
      water: 51.246567,
      fat: 27.63467,
      muscle: 32.776436,
      bone: 4.575968,
    );
  });

  test('regression male 45y 175cm 95kg imp430', () {
    final lib = TrisaBodyAnalyzeLib(sex: 1, ageYears: 45, heightCm: 175.0);
    checkFixture(
      lib,
      95.0,
      430.0,
      bmi: 31.020409,
      water: 51.385693,
      fat: 34.484245,
      muscle: 30.524948,
      bone: 3.1716952,
    );
  });

  test('regression female 55y 160cm 50kg imp600', () {
    final lib = TrisaBodyAnalyzeLib(sex: 0, ageYears: 55, heightCm: 160.0);
    checkFixture(
      lib,
      50.0,
      600.0,
      bmi: 19.53125,
      water: 55.407524,
      fat: 26.659752,
      muscle: 27.356312,
      bone: 3.8092093,
    );
  });

  test('regression male 20y 190cm 65kg imp480', () {
    final lib = TrisaBodyAnalyzeLib(sex: 1, ageYears: 20, heightCm: 190.0);
    checkFixture(
      lib,
      65.0,
      480.0,
      bmi: 18.00554,
      water: 64.203964,
      fat: 10.668964,
      muscle: 49.972504,
      bone: 5.2273664,
    );
  });

  test('regression female 22y 155cm 55kg imp510', () {
    final lib = TrisaBodyAnalyzeLib(sex: 0, ageYears: 22, heightCm: 155.0);
    checkFixture(
      lib,
      55.0,
      510.0,
      bmi: 22.89282,
      water: 49.936302,
      fat: 28.405312,
      muscle: 33.747982,
      bone: 4.713689,
    );
  });

  test('regression male 35y 175cm 85kg imp200', () {
    final lib = TrisaBodyAnalyzeLib(sex: 1, ageYears: 35, heightCm: 175.0);
    checkFixture(
      lib,
      85.0,
      200.0,
      bmi: 27.755102,
      water: 56.290474,
      fat: 25.228241,
      muscle: 38.142612,
      bone: 3.9760387,
    );
  });

  test('regression female 40y 170cm 70kg imp800', () {
    final lib = TrisaBodyAnalyzeLib(sex: 0, ageYears: 40, heightCm: 170.0);
    checkFixture(
      lib,
      70.0,
      800.0,
      bmi: 24.221453,
      water: 47.909973,
      fat: 35.216103,
      muscle: 27.238312,
      bone: 3.7960525,
    );
  });
}
