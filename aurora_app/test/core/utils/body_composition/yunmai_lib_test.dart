import 'package:flutter_test/flutter_test.dart';
import 'package:openscale/core/models/enums.dart';
import 'package:openscale/core/utils/body_composition/yunmai_lib.dart';

void main() {
  const double eps = 1e-3;

  // --- Behavior tests ---

  test('toYunmaiActivityLevel maps correctly', () {
    expect(YunmaiLib.toYunmaiActivityLevel(ActivityLevel.heavy), equals(1));
    expect(YunmaiLib.toYunmaiActivityLevel(ActivityLevel.extreme), equals(1));
    expect(YunmaiLib.toYunmaiActivityLevel(ActivityLevel.sedentary), equals(0));
    expect(YunmaiLib.toYunmaiActivityLevel(ActivityLevel.mild), equals(0));
    expect(YunmaiLib.toYunmaiActivityLevel(ActivityLevel.moderate), equals(0));
  });

  test('constructor sets fitness flag indirectly visible in muscle values', () {
    final fit = YunmaiLib(
      sex: 1,
      height: 180.0,
      activityLevel: ActivityLevel.extreme,
    );
    final normal = YunmaiLib(
      sex: 1,
      height: 180.0,
      activityLevel: ActivityLevel.mild,
    );
    const double bf = 20.0;
    expect(fit.getMuscle(bf), greaterThan(normal.getMuscle(bf)));
    expect(
      fit.getSkeletalMuscle(bf),
      greaterThan(normal.getSkeletalMuscle(bf)),
    );
  });

  // --- Regression fixtures ---

  void checkAll(
    YunmaiLib lib,
    int age,
    double w,
    int res,
    double bf, {
    required double water,
    required double fat,
    required double muscle,
    required double skeletal,
    required double bone,
    required double lbm,
    required double visceralFat,
  }) {
    expect(lib.getWater(bf), closeTo(water, eps));
    expect(lib.getFat(age, w, res), closeTo(fat, eps));
    expect(lib.getMuscle(bf), closeTo(muscle, eps));
    expect(lib.getSkeletalMuscle(bf), closeTo(skeletal, eps));
    expect(lib.getBoneMass(muscle, w), closeTo(bone, eps));
    expect(lib.getLeanBodyMass(w, bf), closeTo(lbm, eps));
    expect(lib.getVisceralFat(bf, age), closeTo(visceralFat, eps));
  }

  test('regression male moderate 30y 180cm 80kg res500 bf23', () {
    final lib = YunmaiLib(
      sex: 1,
      height: 180.0,
      activityLevel: ActivityLevel.moderate,
    );
    checkAll(
      lib,
      30,
      80.0,
      500,
      23.0,
      water: 55.907001,
      fat: 23.237043,
      muscle: 51.595001,
      skeletal: 40.814999,
      bone: 3.263390,
      lbm: 61.599998,
      visceralFat: 11.318182,
    );
  });

  test('regression female mild 28y 165cm 60kg res520 bf28', () {
    final lib = YunmaiLib(
      sex: 0,
      height: 165.0,
      activityLevel: ActivityLevel.mild,
    );
    checkAll(
      lib,
      28,
      60.0,
      520,
      28.0,
      water: 52.276997,
      fat: 29.947247,
      muscle: 48.244999,
      skeletal: 38.164993,
      bone: 2.530795,
      lbm: 43.200001,
      visceralFat: 6.166667,
    );
  });

  test('regression male sedentary 55y 175cm 95kg res430 bf32', () {
    final lib = YunmaiLib(
      sex: 1,
      height: 175.0,
      activityLevel: ActivityLevel.sedentary,
    );
    checkAll(
      lib,
      55,
      95.0,
      430,
      32.0,
      water: 49.372997,
      fat: 34.547203,
      muscle: 45.564999,
      skeletal: 36.044998,
      bone: 3.365057,
      lbm: 64.599998,
      visceralFat: 18.590908,
    );
  });

  test('regression female sedentary 55y 160cm 50kg res600 bf27', () {
    final lib = YunmaiLib(
      sex: 0,
      height: 160.0,
      activityLevel: ActivityLevel.sedentary,
    );
    checkAll(
      lib,
      55,
      50.0,
      600,
      27.0,
      water: 53.003002,
      fat: 28.532946,
      muscle: 48.915001,
      skeletal: 38.694996,
      bone: 2.088284,
      lbm: 36.500000,
      visceralFat: 5.055555,
    );
  });

  test('regression male heavy 20y 190cm 72kg res480 bf14', () {
    final lib = YunmaiLib(
      sex: 1,
      height: 190.0,
      activityLevel: ActivityLevel.heavy,
    );
    checkAll(
      lib,
      20,
      72.0,
      480,
      14.0,
      water: 62.441002,
      fat: 15.266259,
      muscle: 60.205002,
      skeletal: 51.605000,
      bone: 3.519648,
      lbm: 61.919998,
      visceralFat: 9.000000,
    );
  });

  test('regression female moderate 22y 155cm 55kg res510 bf29', () {
    final lib = YunmaiLib(
      sex: 0,
      height: 155.0,
      activityLevel: ActivityLevel.moderate,
    );
    checkAll(
      lib,
      22,
      55.0,
      510,
      29.0,
      water: 51.551003,
      fat: 30.724077,
      muscle: 47.575001,
      skeletal: 37.634998,
      bone: 2.187678,
      lbm: 39.049999,
      visceralFat: 6.722222,
    );
  });

  test('regression male mild 35y 175cm 85kg res200 bf25', () {
    final lib = YunmaiLib(
      sex: 1,
      height: 175.0,
      activityLevel: ActivityLevel.mild,
    );
    checkAll(
      lib,
      35,
      85.0,
      200,
      25.0,
      water: 54.455002,
      fat: 27.232653,
      muscle: 50.255001,
      skeletal: 39.754993,
      bone: 3.322063,
      lbm: 63.750000,
      visceralFat: 13.136364,
    );
  });

  test('regression female sedentary 40y 170cm 70kg res800 bf36', () {
    final lib = YunmaiLib(
      sex: 0,
      height: 170.0,
      activityLevel: ActivityLevel.sedentary,
    );
    checkAll(
      lib,
      40,
      70.0,
      800,
      36.0,
      water: 46.468998,
      fat: 34.777931,
      muscle: 42.884998,
      skeletal: 33.924999,
      bone: 2.674562,
      lbm: 44.799999,
      visceralFat: 10.409091,
    );
  });
}
