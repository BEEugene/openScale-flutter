import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:openscale/core/utils/body_composition/onebyone_new_lib.dart';

void main() {
  const double eps = 1e-3;

  // ---------- Snapshots ----------

  void checkSnapshot(
    String name, {
    required int sex,
    required int age,
    required double h,
    required double w,
    required int imp,
    required int pt,
    required double expectedBmi,
    required double expectedLbm,
    required double expectedBmmrCoeff,
    required double expectedBmmr,
    required double expectedBodyFatPct,
    required double expectedBoneMass,
    required double expectedMuscleMass,
    required double expectedSkelMusclePct,
    required double expectedVisceralFat,
    required double expectedWaterPct,
    required double expectedProteinPct,
  }) {
    final lib = OneByoneNewLib(sex: sex, age: age, height: h, peopleType: pt);

    final bmi = lib.getBMI(w);
    final lbm = lib.getLBM(w, imp);
    final coeff = lib.getBMMRCoeff(w);
    final bmmr = lib.getBMMR(w);
    final bf = lib.getBodyFatPercentage(w, imp);
    final bone = lib.getBoneMass(w, imp);
    final mm = lib.getMuscleMass(w, imp);
    final skm = lib.getSkeletonMusclePercentage(w, imp);
    final vf = lib.getVisceralFat(w);
    final water = lib.getWaterPercentage(w, imp);
    final prot = lib.getProteinPercentage(w, imp);

    expect(bmi, closeTo(expectedBmi, eps), reason: '$name:bmi');
    expect(lbm, closeTo(expectedLbm, eps), reason: '$name:lbm');
    expect(coeff, closeTo(expectedBmmrCoeff, eps), reason: '$name:bmmrCoeff');
    expect(bmmr, closeTo(expectedBmmr, eps), reason: '$name:bmmr');
    expect(bf, closeTo(expectedBodyFatPct, eps), reason: '$name:bf%');
    expect(bone, closeTo(expectedBoneMass, eps), reason: '$name:bone');
    expect(mm, closeTo(expectedMuscleMass, eps), reason: '$name:muscleMass');
    expect(
      skm,
      closeTo(expectedSkelMusclePct, eps),
      reason: '$name:skelMuscle%',
    );
    expect(vf, closeTo(expectedVisceralFat, eps), reason: '$name:visceralFat');
    expect(water, closeTo(expectedWaterPct, eps), reason: '$name:water%');
    expect(prot, closeTo(expectedProteinPct, eps), reason: '$name:protein%');
  }

  test('snapshots match expected outputs', () {
    checkSnapshot(
      'male_mid',
      sex: 1,
      age: 30,
      h: 180,
      w: 80,
      imp: 500,
      pt: 0,
      expectedBmi: 24.691359,
      expectedLbm: 62.14792,
      expectedBmmrCoeff: 21.0,
      expectedBmmr: 1000.0,
      expectedBodyFatPct: 23.315102,
      expectedBoneMass: 3.1254208,
      expectedMuscleMass: 58.2225,
      expectedSkelMusclePct: 40.566765,
      expectedVisceralFat: 10.79977,
      expectedWaterPct: 52.60584,
      expectedProteinPct: 15.963814,
    );
    checkSnapshot(
      'female_mid',
      sex: 0,
      age: 28,
      h: 165,
      w: 60,
      imp: 520,
      pt: 1,
      expectedBmi: 22.038567,
      expectedLbm: 51.032806,
      expectedBmmrCoeff: 22.0,
      expectedBmmr: 1000.0,
      expectedBodyFatPct: 28.27285,
      expectedBoneMass: 2.486581,
      expectedMuscleMass: 40.549713,
      expectedSkelMusclePct: 36.45647,
      expectedVisceralFat: 4.704997,
      expectedWaterPct: 49.204823,
      expectedProteinPct: 14.44164,
    );
    checkSnapshot(
      'imp_low',
      sex: 1,
      age: 25,
      h: 178,
      w: 72,
      imp: 80,
      pt: 0,
      expectedBmi: 22.724403,
      expectedLbm: 62.06637,
      expectedBmmrCoeff: 23.0,
      expectedBmmr: 1000.0,
      expectedBodyFatPct: 14.907819,
      expectedBoneMass: 3.1212144,
      expectedMuscleMass: 58.145157,
      expectedSkelMusclePct: 45.008743,
      expectedVisceralFat: 9.316022,
      expectedWaterPct: 58.373234,
      expectedProteinPct: 17.714064,
    );
    checkSnapshot(
      'imp_mid',
      sex: 0,
      age: 35,
      h: 170,
      w: 68,
      imp: 300,
      pt: 2,
      expectedBmi: 23.529411,
      expectedLbm: 56.22662,
      expectedBmmrCoeff: 20.0,
      expectedBmmr: 1000.0,
      expectedBodyFatPct: 31.690466,
      expectedBoneMass: 2.754478,
      expectedMuscleMass: 43.696007,
      expectedSkelMusclePct: 36.679123,
      expectedVisceralFat: 6.603998,
      expectedWaterPct: 48.773006,
      expectedProteinPct: 11.583979,
    );
    checkSnapshot(
      'imp_high',
      sex: 1,
      age: 45,
      h: 182,
      w: 90,
      imp: 1300,
      pt: 1,
      expectedBmi: 27.170633,
      expectedLbm: 59.750725,
      expectedBmmrCoeff: 21.0,
      expectedBmmr: 1000.0,
      expectedBodyFatPct: 34.49919,
      expectedBoneMass: 3.0017734,
      expectedMuscleMass: 55.948956,
      expectedSkelMusclePct: 36.065098,
      expectedVisceralFat: 13.974511,
      expectedWaterPct: 46.76758,
      expectedProteinPct: 11.656517,
    );
  });

  // ---------- Behavior / Property tests ----------

  test('BMI is bounded and monotonic with weight', () {
    final lib = OneByoneNewLib(sex: 1, age: 30, height: 180, peopleType: 0);
    final b1 = lib.getBMI(60);
    final b2 = lib.getBMI(80);
    final b3 = lib.getBMI(100);

    for (final b in [b1, b2, b3]) {
      expect(b, greaterThanOrEqualTo(10 - eps));
      expect(b, lessThanOrEqualTo(90 + eps));
    }
    expect(b2, greaterThan(b1));
    expect(b3, greaterThan(b2));
  });

  test('LBM varies with impedance and weight', () {
    final lib = OneByoneNewLib(sex: 0, age: 28, height: 165, peopleType: 1);
    const double w = 60;

    final lbmHighImp = lib.getLBM(w, 1200);
    final lbmLowImp = lib.getLBM(w, 200);
    expect(lbmLowImp, greaterThan(lbmHighImp));

    final lbmHeavier = lib.getLBM(75, 300);
    final lbmLighter = lib.getLBM(55, 300);
    expect(lbmHeavier, greaterThan(lbmLighter));
  });

  test('BMMRCoeff follows age bands and sex', () {
    double coeff(int sex, int age) => OneByoneNewLib(
      sex: sex,
      age: age,
      height: 170,
      peopleType: 0,
    ).getBMMRCoeff(70);

    // male bands
    expect(coeff(1, 10), closeTo(36, eps));
    expect(coeff(1, 14), closeTo(30, eps));
    expect(coeff(1, 17), closeTo(26, eps));
    expect(coeff(1, 25), closeTo(23, eps));
    expect(coeff(1, 50), closeTo(20, eps));

    // female bands
    expect(coeff(0, 10), closeTo(34, eps));
    expect(coeff(0, 15), closeTo(29, eps));
    expect(coeff(0, 17), closeTo(24, eps));
    expect(coeff(0, 25), closeTo(22, eps));
    expect(coeff(0, 50), closeTo(19, eps));
  });

  test('BMMR is bounded and differs by sex', () {
    const double h = 180;
    const int age = 30;

    final male = OneByoneNewLib(
      sex: 1,
      age: age,
      height: h,
      peopleType: 0,
    ).getBMMR(22);
    final female = OneByoneNewLib(
      sex: 0,
      age: age,
      height: h,
      peopleType: 0,
    ).getBMMR(19);

    expect(male, greaterThanOrEqualTo(500 - 1e-3));
    expect(male, lessThanOrEqualTo(1000 + 1e-3));
    expect(female, greaterThanOrEqualTo(500 - 1e-3));
    expect(female, lessThanOrEqualTo(1000 + 1e-3));

    expect((male - female).abs(), greaterThan(0.1));
  });

  test('water switches coeff around 50 and is bounded', () {
    final lib = OneByoneNewLib(sex: 1, age: 35, height: 175, peopleType: 1);
    const double w = 80;
    final waterLow = lib.getWaterPercentage(w, 1200); // typ. <50
    final waterHigh = lib.getWaterPercentage(w, 200); // typ. >50

    for (final w in [waterLow, waterHigh]) {
      expect(w, greaterThanOrEqualTo(35 - eps));
      expect(w, lessThanOrEqualTo(75 + eps));
    }
    expect((waterHigh - waterLow).abs(), greaterThan(0.5));
  });

  test('boneMass is bounded and varies with impedance', () {
    final lib = OneByoneNewLib(sex: 0, age: 50, height: 168, peopleType: 0);
    const double w = 70;

    final boneHighImp = lib.getBoneMass(w, 1200);
    final boneLowImp = lib.getBoneMass(w, 200);

    for (final b in [boneHighImp, boneLowImp]) {
      expect(b, greaterThanOrEqualTo(0.5 - 1e-3));
      expect(b, lessThanOrEqualTo(8.0 + 1e-3));
    }

    expect((boneLowImp - boneHighImp).abs(), greaterThan(0.0));
    expect(boneLowImp, greaterThan(boneHighImp));
  });

  test('muscleMass is bounded and correlates with impedance', () {
    final lib = OneByoneNewLib(sex: 1, age: 28, height: 180, peopleType: 0);
    const double w = 82;

    final mmHighImp = lib.getMuscleMass(w, 1200);
    final mmLowImp = lib.getMuscleMass(w, 200);

    for (final m in [mmHighImp, mmLowImp]) {
      expect(m, greaterThanOrEqualTo(10 - eps));
      expect(m, lessThanOrEqualTo(120 + eps));
    }

    expect(mmLowImp, greaterThan(mmHighImp));
  });

  test('skeletonMuscle is finite and reasonable range', () {
    final lib = OneByoneNewLib(sex: 0, age: 33, height: 165, peopleType: 2);
    final sm = lib.getSkeletonMusclePercentage(58, 400);

    expect(sm.isNaN, isFalse);
    expect(sm.isInfinite, isFalse);
    expect(sm, greaterThan(-20));
    expect(sm, lessThan(120));
  });

  test('bodyFat and protein are finite', () {
    final lib = OneByoneNewLib(sex: 1, age: 40, height: 182, peopleType: 1);
    const double w = 90;
    const int imp = 500;
    final bf = lib.getBodyFatPercentage(w, imp);
    final prot = lib.getProteinPercentage(w, imp);

    expect(bf.isNaN, isFalse);
    expect(prot.isNaN, isFalse);
    expect(bf.isInfinite, isFalse);
    expect(prot.isInfinite, isFalse);
  });
}
