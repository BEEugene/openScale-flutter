import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:openscale/core/models/enums.dart';
import 'package:openscale/core/utils/calculation_utils.dart';

void main() {
  group('calculateBmi', () {
    test('calculates correct BMI for 70kg, 175cm', () {
      final bmi = calculateBmi(70.0, 175.0);
      // 70 / (1.75 * 1.75) = 70 / 3.0625 = 22.857...
      expect(bmi, closeTo(22.86, 0.01));
    });

    test('calculates correct BMI for 90kg, 180cm', () {
      final bmi = calculateBmi(90.0, 180.0);
      // 90 / (1.8 * 1.8) = 90 / 3.24 = 27.78
      expect(bmi, closeTo(27.78, 0.01));
    });

    test('returns 0 for zero height', () {
      expect(calculateBmi(70.0, 0.0), 0.0);
    });

    test('returns 0 for negative height', () {
      expect(calculateBmi(70.0, -10.0), 0.0);
    });

    test('returns 0 for zero weight', () {
      expect(calculateBmi(0.0, 175.0), closeTo(0.0, 0.001));
    });

    test('calculates BMI for large values', () {
      final bmi = calculateBmi(150.0, 200.0);
      // 150 / (2.0 * 2.0) = 150 / 4.0 = 37.5
      expect(bmi, closeTo(37.5, 0.01));
    });
  });

  group('calculateBmr', () {
    test('calculates BMR for male using Mifflin-St Jeor', () {
      // Male: (10 * 70) + (6.25 * 175) - (5 * 30) + 5
      // = 700 + 1093.75 - 150 + 5 = 1648.75
      final bmr = calculateBmr(
        weightKg: 70.0,
        heightCm: 175.0,
        age: 30,
        gender: Gender.male,
      );
      expect(bmr, closeTo(1648.75, 0.01));
    });

    test('calculates BMR for female using Mifflin-St Jeor', () {
      // Female: (10 * 60) + (6.25 * 165) - (5 * 25) - 161
      // = 600 + 1031.25 - 125 - 161 = 1345.25
      final bmr = calculateBmr(
        weightKg: 60.0,
        heightCm: 165.0,
        age: 25,
        gender: Gender.female,
      );
      expect(bmr, closeTo(1345.25, 0.01));
    });

    test('male and female give different BMR for same stats', () {
      final maleBmr = calculateBmr(
        weightKg: 70.0,
        heightCm: 175.0,
        age: 30,
        gender: Gender.male,
      );
      final femaleBmr = calculateBmr(
        weightKg: 70.0,
        heightCm: 175.0,
        age: 30,
        gender: Gender.female,
      );
      // Difference should be 166 (5 - (-161))
      expect(maleBmr - femaleBmr, closeTo(166.0, 0.01));
    });

    test('BMR increases with weight', () {
      final bmrLight = calculateBmr(
        weightKg: 60.0,
        heightCm: 175.0,
        age: 30,
        gender: Gender.male,
      );
      final bmrHeavy = calculateBmr(
        weightKg: 80.0,
        heightCm: 175.0,
        age: 30,
        gender: Gender.male,
      );
      expect(bmrHeavy, greaterThan(bmrLight));
    });

    test('BMR decreases with age', () {
      final bmrYoung = calculateBmr(
        weightKg: 70.0,
        heightCm: 175.0,
        age: 20,
        gender: Gender.male,
      );
      final bmrOld = calculateBmr(
        weightKg: 70.0,
        heightCm: 175.0,
        age: 60,
        gender: Gender.male,
      );
      expect(bmrOld, lessThan(bmrYoung));
    });
  });

  group('calculateTdee', () {
    const testBmr = 1648.75;

    test('sedentary multiplier is 1.2', () {
      final tdee = calculateTdee(testBmr, ActivityLevel.sedentary);
      expect(tdee, closeTo(testBmr * 1.2, 0.01));
    });

    test('mild multiplier is 1.375', () {
      final tdee = calculateTdee(testBmr, ActivityLevel.mild);
      expect(tdee, closeTo(testBmr * 1.375, 0.01));
    });

    test('moderate multiplier is 1.55', () {
      final tdee = calculateTdee(testBmr, ActivityLevel.moderate);
      expect(tdee, closeTo(testBmr * 1.55, 0.01));
    });

    test('heavy multiplier is 1.725', () {
      final tdee = calculateTdee(testBmr, ActivityLevel.heavy);
      expect(tdee, closeTo(testBmr * 1.725, 0.01));
    });

    test('extreme multiplier is 1.9', () {
      final tdee = calculateTdee(testBmr, ActivityLevel.extreme);
      expect(tdee, closeTo(testBmr * 1.9, 0.01));
    });

    test('TDEE increases with activity level', () {
      final levels = ActivityLevel.values;
      for (var i = 0; i < levels.length - 1; i++) {
        final lower = calculateTdee(testBmr, levels[i]);
        final higher = calculateTdee(testBmr, levels[i + 1]);
        expect(higher, greaterThan(lower));
      }
    });
  });

  group('estimateBodyFatDeurenberg1991', () {
    test('calculates body fat for male', () {
      // (1.20 * 22.86) + (0.23 * 30) - (10.8 * 1.0) - 5.4
      // = 27.432 + 6.9 - 10.8 - 5.4 = 18.132
      final bf = estimateBodyFatDeurenberg1991(
        bmi: 22.86,
        age: 30,
        gender: Gender.male,
      );
      expect(bf, closeTo(18.13, 0.01));
    });

    test('calculates body fat for female', () {
      // (1.20 * 22.86) + (0.23 * 30) - (10.8 * 0.0) - 5.4
      // = 27.432 + 6.9 - 0 - 5.4 = 28.932
      final bf = estimateBodyFatDeurenberg1991(
        bmi: 22.86,
        age: 30,
        gender: Gender.female,
      );
      expect(bf, closeTo(28.93, 0.01));
    });

    test('female has higher body fat estimate than male at same BMI/age', () {
      final maleBf = estimateBodyFatDeurenberg1991(
        bmi: 22.0,
        age: 30,
        gender: Gender.male,
      );
      final femaleBf = estimateBodyFatDeurenberg1991(
        bmi: 22.0,
        age: 30,
        gender: Gender.female,
      );
      expect(femaleBf, greaterThan(maleBf));
    });

    test('body fat increases with age', () {
      final youngBf = estimateBodyFatDeurenberg1991(
        bmi: 22.0,
        age: 20,
        gender: Gender.male,
      );
      final oldBf = estimateBodyFatDeurenberg1991(
        bmi: 22.0,
        age: 50,
        gender: Gender.male,
      );
      expect(oldBf, greaterThan(youngBf));
    });

    test('body fat increases with BMI', () {
      final lowBmiBf = estimateBodyFatDeurenberg1991(
        bmi: 18.0,
        age: 30,
        gender: Gender.male,
      );
      final highBmiBf = estimateBodyFatDeurenberg1991(
        bmi: 30.0,
        age: 30,
        gender: Gender.male,
      );
      expect(highBmiBf, greaterThan(lowBmiBf));
    });
  });

  group('estimateBodyFatUsNavy', () {
    test('calculates body fat for male', () {
      // waist=85, neck=38, height=175
      final bf = estimateBodyFatUsNavy(
        waistCm: 85.0,
        neckCm: 38.0,
        heightCm: 175.0,
        gender: Gender.male,
      );
      // Male formula: 495 / (1.0324 - 0.19077 * log10(85-38) + 0.15456 * log10(175)) - 450
      // = 495 / (1.0324 - 0.19077 * log10(47) + 0.15456 * log10(175)) - 450
      // log10(47) ≈ 1.6721, log10(175) ≈ 2.2430
      // = 495 / (1.0324 - 0.3189 + 0.3467) - 450
      // = 495 / 1.0602 - 450 = 466.85 - 450 = 16.85
      expect(bf, closeTo(16.85, 0.5));
    });

    test('calculates body fat for female with hips', () {
      // waist=75, neck=34, height=165, hips=95
      final bf = estimateBodyFatUsNavy(
        waistCm: 75.0,
        neckCm: 34.0,
        heightCm: 165.0,
        gender: Gender.female,
        hipsCm: 95.0,
      );
      // Female formula: 495 / (1.29579 - 0.35004 * log10(75+95-34) + 0.22100 * log10(165)) - 450
      // = 495 / (1.29579 - 0.35004 * log10(136) + 0.22100 * log10(165)) - 450
      // log10(136) ≈ 2.1335, log10(165) ≈ 2.2175
      // = 495 / (1.29579 - 0.7469 + 0.4901) - 450
      // = 495 / 1.0390 - 450 = 476.42 - 450 = 26.42
      expect(bf, closeTo(26.42, 0.5));
    });

    test('female with no hips defaults to 0', () {
      final bf = estimateBodyFatUsNavy(
        waistCm: 75.0,
        neckCm: 34.0,
        heightCm: 165.0,
        gender: Gender.female,
        // hipsCm omitted → defaults to 0
      );
      // Should still produce a number (not NaN)
      expect(bf.isNaN, false);
      expect(bf.isFinite, true);
    });
  });

  group('convertWeight', () {
    test('same unit returns same value (kg→kg)', () {
      expect(convertWeight(70.0, UnitType.kg, UnitType.kg), 70.0);
    });

    test('same unit returns same value (lb→lb)', () {
      expect(convertWeight(154.0, UnitType.lb, UnitType.lb), 154.0);
    });

    test('kg to lb conversion', () {
      // 1 kg = 2.20462 lb
      final result = convertWeight(70.0, UnitType.kg, UnitType.lb);
      expect(result, closeTo(154.32, 0.01));
    });

    test('lb to kg conversion', () {
      // 1 lb = 0.45359237 kg
      final result = convertWeight(154.32, UnitType.lb, UnitType.kg);
      expect(result, closeTo(70.0, 0.01));
    });

    test('kg to st conversion', () {
      // 1 kg = 0.157473 st
      final result = convertWeight(70.0, UnitType.kg, UnitType.st);
      expect(result, closeTo(11.02, 0.01));
    });

    test('st to kg conversion', () {
      // 1 st = 6.35029318 kg
      final result = convertWeight(11.02, UnitType.st, UnitType.kg);
      expect(result, closeTo(70.0, 0.1));
    });

    test('lb to st conversion', () {
      final result = convertWeight(154.32, UnitType.lb, UnitType.st);
      // First lb→kg then kg→st
      expect(result, closeTo(11.02, 0.01));
    });

    test('roundtrip kg→lb→kg preserves value', () {
      const original = 75.5;
      final lb = convertWeight(original, UnitType.kg, UnitType.lb);
      final back = convertWeight(lb, UnitType.lb, UnitType.kg);
      expect(back, closeTo(original, 0.001));
    });

    test('roundtrip kg→st→kg preserves value', () {
      const original = 82.3;
      final st = convertWeight(original, UnitType.kg, UnitType.st);
      final back = convertWeight(st, UnitType.st, UnitType.kg);
      expect(back, closeTo(original, 0.001));
    });

    test('zero weight returns zero', () {
      expect(convertWeight(0.0, UnitType.kg, UnitType.lb), closeTo(0.0, 0.001));
    });

    test('non-weight unit returns same value for unsupported conversions', () {
      // percent is not a weight unit, so _toKg returns value as-is
      expect(convertWeight(50.0, UnitType.percent, UnitType.kg), 50.0);
    });
  });
}
