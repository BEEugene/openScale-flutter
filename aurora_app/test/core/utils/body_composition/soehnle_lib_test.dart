import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:openscale/core/utils/body_composition/soehnle_lib.dart';

void main() {
  const double eps = 1e-3;

  // ---------- Snapshots ----------

  void checkSnapshot(
    String name, {
    required bool isMale,
    required int age,
    required double h,
    required double w,
    required double imp50,
    required double imp5,
    required int activity,
    required double expectedBmi,
    required double expectedFat,
    required double expectedWater,
    required double expectedMuscle,
  }) {
    final lib = SoehnleLib(
      isMale: isMale,
      age: age,
      height: h,
      activityLevel: activity,
    );

    expect(
      lib.computeBodyMassIndex(w),
      closeTo(expectedBmi, eps),
      reason: '$name:bmi',
    );
    expect(
      lib.getFat(w, imp50),
      closeTo(expectedFat, eps),
      reason: '$name:fat%',
    );
    expect(
      lib.getWater(w, imp50),
      closeTo(expectedWater, eps),
      reason: '$name:water%',
    );
    expect(
      lib.getMuscle(w, imp50, imp5),
      closeTo(expectedMuscle, eps),
      reason: '$name:muscle%',
    );
  }

  test('snapshots match expected outputs', () {
    checkSnapshot(
      'male_mid',
      isMale: true,
      age: 30,
      h: 180,
      w: 80,
      imp50: 500,
      imp5: 200,
      activity: 3,
      expectedBmi: 24.691359,
      expectedFat: 18.604935,
      expectedWater: 54.8644,
      expectedMuscle: 9.49897,
    );
    checkSnapshot(
      'female_mid',
      isMale: false,
      age: 28,
      h: 165,
      w: 60,
      imp50: 520,
      imp5: 210,
      activity: 4,
      expectedBmi: 22.038567,
      expectedFat: 26.137234,
      expectedWater: 56.005848,
      expectedMuscle: 5.708269,
    );
    checkSnapshot(
      'male_active5',
      isMale: true,
      age: 35,
      h: 178,
      w: 85,
      imp50: 480,
      imp5: 190,
      activity: 5,
      expectedBmi: 26.827421,
      expectedFat: 26.860249,
      expectedWater: 55.484665,
      expectedMuscle: 10.4964695,
    );
    checkSnapshot(
      'female_low',
      isMale: false,
      age: 45,
      h: 160,
      w: 70,
      imp50: 700,
      imp5: 250,
      activity: 1,
      expectedBmi: 27.34375,
      expectedFat: 48.433907,
      expectedWater: 38.981922,
      expectedMuscle: 2.8784876,
    );
  });

  // ---------- Property tests ----------

  test('bmi monotonic with weight', () {
    final lib = SoehnleLib(
      isMale: true,
      age: 30,
      height: 180,
      activityLevel: 3,
    );
    final bmi1 = lib.computeBodyMassIndex(70);
    final bmi2 = lib.computeBodyMassIndex(85);
    expect(bmi2, greaterThan(bmi1));
  });

  test('fat increases with impedance50', () {
    final lib = SoehnleLib(
      isMale: true,
      age: 35,
      height: 178,
      activityLevel: 3,
    );
    const double w = 82;
    final low = lib.getFat(w, 300);
    final high = lib.getFat(w, 600);
    expect(high, greaterThan(low));
  });

  test('water in reasonable range', () {
    final lib = SoehnleLib(
      isMale: false,
      age: 29,
      height: 165,
      activityLevel: 4,
    );
    final water = lib.getWater(60, 520);
    expect(water, greaterThanOrEqualTo(30));
    expect(water, lessThanOrEqualTo(75));
  });

  test('muscle in reasonable range', () {
    final lib = SoehnleLib(
      isMale: true,
      age: 40,
      height: 182,
      activityLevel: 5,
    );
    final muscle = lib.getMuscle(90, 500, 220);
    expect(muscle, greaterThanOrEqualTo(0));
    expect(muscle, lessThanOrEqualTo(70));
  });

  test('male vs female fat differs with same inputs', () {
    const int age = 30;
    const double h = 178;
    const int act = 3;
    const double w = 75;
    const double imp50 = 500;
    final m = SoehnleLib(
      isMale: true,
      age: age,
      height: h,
      activityLevel: act,
    ).getFat(w, imp50);
    final f = SoehnleLib(
      isMale: false,
      age: age,
      height: h,
      activityLevel: act,
    ).getFat(w, imp50);
    expect((m - f).abs(), greaterThan(0.1));
  });
}
