import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:openscale/core/utils/body_composition/onebyone_lib.dart';

void main() {
  const double eps = 1e-3;

  // ---------- Snapshots (pre-recorded from Kotlin implementation) ----------

  void checkSnapshot(
    String name, {
    required int sex,
    required int age,
    required double h,
    required double w,
    required double imp,
    required int pt,
    required double expectedBmi,
    required double expectedBf,
    required double expectedLbm,
    required double expectedMuscle,
    required double expectedWater,
    required double expectedBone,
    required double expectedVf,
  }) {
    final lib = OneByoneLib(sex: sex, age: age, height: h, peopleType: pt);
    final bf = lib.getBodyFat(w, imp);

    expect(lib.getBMI(w), closeTo(expectedBmi, eps), reason: '$name:bmi');
    expect(bf, closeTo(expectedBf, eps), reason: '$name:bf');
    expect(lib.getLBM(w, bf), closeTo(expectedLbm, eps), reason: '$name:lbm');
    expect(
      lib.getMuscle(w, imp),
      closeTo(expectedMuscle, eps),
      reason: '$name:muscle',
    );
    expect(
      lib.getWater(bf),
      closeTo(expectedWater, eps),
      reason: '$name:water',
    );
    expect(
      lib.getBoneMass(w, imp),
      closeTo(expectedBone, eps),
      reason: '$name:bone',
    );
    expect(lib.getVisceralFat(w), closeTo(expectedVf, eps), reason: '$name:vf');
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
      expectedBf: 23.315102,
      expectedLbm: 61.34792,
      expectedMuscle: 40.97725,
      expectedWater: 52.60584,
      expectedBone: 3.030576,
      expectedVf: 10.79977,
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
      expectedBf: 25.210106,
      expectedLbm: 44.873936,
      expectedMuscle: 40.181107,
      expectedWater: 51.305866,
      expectedBone: 2.3883991,
      expectedVf: 0.70499706,
    );
    checkSnapshot(
      'male_high',
      sex: 1,
      age: 52,
      h: 175,
      w: 95,
      imp: 430,
      pt: 2,
      expectedBmi: 31.020409,
      expectedBf: 26.381027,
      expectedLbm: 69.93803,
      expectedMuscle: 35.573257,
      expectedWater: 50.502613,
      expectedBone: 3.1443515,
      expectedVf: 13.163806,
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
      expectedBf: 16.04116,
      expectedLbm: 60.450363,
      expectedMuscle: 230.51118,
      expectedWater: 57.595764,
      expectedBone: 3.0263696,
      expectedVf: 9.316022,
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
      expectedBf: 25.14642,
      expectedLbm: 50.900436,
      expectedMuscle: 60.656864,
      expectedWater: 51.349552,
      expectedBone: 2.650265,
      expectedVf: 2.6039982,
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
      expectedBf: 30.914497,
      expectedLbm: 62.176952,
      expectedMuscle: 17.721643,
      expectedWater: 49.32705,
      expectedBone: 2.901557,
      expectedVf: 11.179609,
    );
  });

  // ---------- Property tests ----------

  test('bmi monotonicity: weight up increases, height constant', () {
    final lib = OneByoneLib(sex: 1, age: 30, height: 180, peopleType: 0);
    expect(lib.getBMI(85), greaterThan(lib.getBMI(70)));
  });

  test('bmi monotonicity: height up decreases, weight constant', () {
    final libShort = OneByoneLib(sex: 1, age: 30, height: 170, peopleType: 0);
    final libTall = OneByoneLib(sex: 1, age: 30, height: 190, peopleType: 0);
    expect(libTall.getBMI(80), lessThan(libShort.getBMI(80)));
  });

  test('water switches coeff below and above 50', () {
    final lib = OneByoneLib(sex: 0, age: 40, height: 165, peopleType: 1);
    const double bfHigh = 35.0; // -> (100-35)*0.7 = 45.5 < 50 -> *1.02
    const double bfLow = 20.0; // -> (100-20)*0.7 = 56 > 50 -> *0.98
    final wHigh = lib.getWater(bfHigh);
    final wLow = lib.getWater(bfLow);
    expect(wHigh, lessThan(50.0));
    expect(wLow, greaterThan(50.0));
  });

  test('boneMass is reasonably clamped between 0.5 and 8.0', () {
    final lib = OneByoneLib(sex: 0, age: 55, height: 170, peopleType: 2);
    final candidates = [
      (40.0, 1400.0),
      (150.0, 200.0),
      (55.0, 600.0),
      (95.0, 300.0),
    ];
    for (final (w, imp) in candidates) {
      final bone = lib.getBoneMass(w, imp);
      expect(bone, greaterThanOrEqualTo(0.5));
      expect(bone, lessThanOrEqualTo(8.0));
    }
  });

  test('muscle reacts to impedance reasonably', () {
    final lib = OneByoneLib(sex: 1, age: 30, height: 180, peopleType: 0);
    const double w = 80;

    final mHigh = lib.getMuscle(w, 1300);
    final mMid = lib.getMuscle(w, 400);
    final mLow = lib.getMuscle(w, 80);

    expect(mLow, greaterThan(mMid));
    expect(mMid, greaterThan(mHigh));
  });

  test('bodyFat stays within reasonable bounds', () {
    final lib = OneByoneLib(sex: 1, age: 35, height: 180, peopleType: 1);
    final weights = [50.0, 70.0, 90.0, 110.0];
    final imps = [80.0, 300.0, 600.0, 1200.0];
    for (final w in weights) {
      for (final imp in imps) {
        final bf = lib.getBodyFat(w, imp);
        expect(bf, greaterThanOrEqualTo(1.0 - 1e-3));
        expect(bf, lessThanOrEqualTo(45.0 + 1e-3));
      }
    }
  });

  test('peopleType influences outputs', () {
    final base = OneByoneLib(sex: 1, age: 40, height: 175, peopleType: 0);
    final mid = OneByoneLib(sex: 1, age: 40, height: 175, peopleType: 1);
    final high = OneByoneLib(sex: 1, age: 40, height: 175, peopleType: 2);
    const double w = 85;
    const double imp = 450;

    final boneBase = base.getBoneMass(w, imp);
    final boneMid = mid.getBoneMass(w, imp);
    final boneHigh = high.getBoneMass(w, imp);

    expect((boneBase - boneMid).abs(), greaterThan(0.0));
    expect((boneMid - boneHigh).abs(), greaterThan(0.0));

    final minV = min(boneBase, min(boneMid, boneHigh));
    final maxV = max(boneBase, max(boneMid, boneHigh));
    expect(maxV - minV, lessThan(2.0));
  });

  test('sex flag affects outputs', () {
    final male = OneByoneLib(sex: 1, age: 32, height: 178, peopleType: 1);
    final female = OneByoneLib(sex: 0, age: 32, height: 178, peopleType: 1);
    const double w = 75;
    const double imp = 420;

    final bfM = male.getBodyFat(w, imp);
    final bfF = female.getBodyFat(w, imp);

    expect((bfM - bfF).abs(), greaterThan(0.1));
  });

  test('outputs are finite for typical ranges', () {
    final lib = OneByoneLib(sex: 1, age: 30, height: 180, peopleType: 0);
    const double w = 80;
    const double imp = 500;
    final bf = lib.getBodyFat(w, imp);
    final values = [
      lib.getBMI(w),
      bf,
      lib.getLBM(w, bf),
      lib.getMuscle(w, imp),
      lib.getWater(bf),
      lib.getBoneMass(w, imp),
      lib.getVisceralFat(w),
    ];
    for (final v in values) {
      expect(v.isNaN, isFalse);
      expect(v.isInfinite, isFalse);
    }
  });
}
