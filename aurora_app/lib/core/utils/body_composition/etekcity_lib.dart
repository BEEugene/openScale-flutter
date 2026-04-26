// openScale
// Copyright (C) 2025 olie.xdev <olie.xdeveloper@googlemail.com>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:math';

import 'package:openscale/core/models/enums.dart';

/// Etekcity ESF551 body composition formulas.
/// Based on https://github.com/ronnnnnnnnnnnnn/etekcity_esf551_ble
class EtekcityLib {
  EtekcityLib({
    required this.gender,
    required this.age,
    required this.weightKg,
    required this.heightM,
    required this.impedance,
  });

  final Gender gender;
  final int age;
  final double weightKg;
  final double heightM;
  final double impedance;

  double get bmi => weightKg / (heightM * heightM);

  bool get isMale => gender == Gender.male;

  double get bodyFatPercentage {
    final double ageFactor = isMale ? 0.103 : 0.097;
    final double bmiFactor = isMale ? 1.524 : 1.545;
    final double constant = isMale ? 22.0 : 12.7;
    final double raw =
        ((ageFactor * age + bmiFactor * bmi - 500.0 / impedance - constant) *
                10)
            .floorToDouble() /
        10.0;
    return raw.clamp(5.0, 75.0);
  }

  double get fatFreeWeight => weightKg * (1 - bodyFatPercentage / 100);

  double get visceralFat {
    final double bmiFactor = isMale ? 0.8666 : 0.8895;
    final double bfpFactor = isMale ? 0.0082 : 0.0943;
    final double fatFactor = isMale ? 0.026 : -0.0534;
    final double constant = isMale ? 14.2692 : 16.215;
    return (bmiFactor * bmi +
            bfpFactor * bodyFatPercentage +
            fatFactor * (weightKg - fatFreeWeight) -
            constant)
        .clamp(1.0, 30.0);
  }

  double get water {
    final double ff1Factor = isMale ? 0.05 : 0.06;
    final double ff2Factor = isMale ? 0.76 : 0.73;
    final double ff1 = max(1.0, ff1Factor * fatFreeWeight);
    return (ff2Factor * (fatFreeWeight - ff1) / weightKg * 100.0).clamp(
      10.0,
      80.0,
    );
  }

  double get basalMetabolicRate =>
      (fatFreeWeight * 21.6 + 370).clamp(900.0, 2500.0);

  double get skeletalMusclePercentage {
    final double ff1Factor = isMale ? 0.05 : 0.06;
    final double ff2Factor = isMale ? 0.68 : 0.62;
    final double ff1 = max(1.0, ff1Factor * fatFreeWeight);
    return ff2Factor * (fatFreeWeight - ff1) / weightKg * 100.0;
  }

  double get boneMass {
    final double ff1Factor = isMale ? 0.05 : 0.06;
    return max(1.0, ff1Factor * fatFreeWeight);
  }

  double get subcutaneousFat {
    final double bfpFactor = isMale ? 0.965 : 0.983;
    final double vfvFactor = isMale ? 0.22 : 0.303;
    return bfpFactor * bodyFatPercentage - vfvFactor * visceralFat;
  }

  double get muscleMass =>
      weightKg - boneMass - 0.01 * bodyFatPercentage * weightKg;

  double get proteinPercentage {
    final double bfpFactor = isMale ? 1.0 : 1.05;
    return max(
      5.0,
      100 - bfpFactor * bodyFatPercentage - boneMass / weightKg * 100 - water,
    );
  }

  int get weightScore {
    final int heightFactor = isMale ? 100 : 137;
    final int constant = isMale ? 80 : 110;
    final double factor = isMale ? 0.7 : 0.45;
    final double res = factor * (heightFactor * heightM - constant);

    if (res <= weightKg) {
      if (1.3 * res < weightKg) {
        return 50;
      }
      return (100 - 50 * (weightKg - res) / (0.3 * res)).toInt();
    }
    if (res * 0.7 < weightKg) {
      return (100 - 50 * (res - weightKg) / (0.3 * res)).toInt();
    }
    for (int x = 0; x < 6; x++) {
      if (res * x / 10 > weightKg) {
        return x * 10;
      }
    }
    return 0;
  }

  int get fatScore {
    final double constant = isMale ? 16.0 : 26.0;
    if (constant < bodyFatPercentage) {
      if (bodyFatPercentage >= 45) {
        return 50;
      } else {
        return (100 - 50 * (bodyFatPercentage - constant) / (45 - constant))
            .toInt();
      }
    } else {
      return (100 - 50 * (constant - bodyFatPercentage) / (constant - 5))
          .toInt();
    }
  }

  int get bmiScore {
    if (bmi >= 35) return 50;
    if (bmi >= 22) return (100 - 3.85 * (bmi - 22)).toInt();
    if (bmi >= 15) return (100 - 3.85 * (22 - bmi)).toInt();
    if (bmi >= 10) return 40;
    if (bmi >= 5) return 30;
    return 20;
  }

  int get healthScore => (weightScore + fatScore + bmiScore) ~/ 3;

  int get metabolicAge {
    final int ageAdjustmentFactor;
    if (healthScore < 50) {
      ageAdjustmentFactor = 0;
    } else if (healthScore < 60) {
      ageAdjustmentFactor = 1;
    } else if (healthScore < 65) {
      ageAdjustmentFactor = 2;
    } else if (healthScore < 68) {
      ageAdjustmentFactor = 3;
    } else if (healthScore < 70) {
      ageAdjustmentFactor = 4;
    } else if (healthScore < 73) {
      ageAdjustmentFactor = 5;
    } else if (healthScore < 75) {
      ageAdjustmentFactor = 6;
    } else if (healthScore < 80) {
      ageAdjustmentFactor = 7;
    } else if (healthScore < 85) {
      ageAdjustmentFactor = 8;
    } else if (healthScore < 88) {
      ageAdjustmentFactor = 9;
    } else if (healthScore < 90) {
      ageAdjustmentFactor = 10;
    } else if (healthScore < 93) {
      ageAdjustmentFactor = 11;
    } else if (healthScore < 95) {
      ageAdjustmentFactor = 12;
    } else if (healthScore < 97) {
      ageAdjustmentFactor = 13;
    } else if (healthScore < 98) {
      ageAdjustmentFactor = 14;
    } else if (healthScore < 99) {
      ageAdjustmentFactor = 15;
    } else {
      ageAdjustmentFactor = 16;
    }
    return max(18, age + 8 - ageAdjustmentFactor);
  }
}
