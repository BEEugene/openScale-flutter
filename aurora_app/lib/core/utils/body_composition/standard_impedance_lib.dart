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

import 'package:openscale/core/models/enums.dart';

/// Science-based algorithms based on impedance measurements.
///
/// Formulas used:
/// - FFM: Sun SS et al. (2003)
/// - TBW: Sun SS et al. (2003)
/// - BMR: Katch-McArdle
/// - SMM: Janssen et al.
class StandardImpedanceLib {
  StandardImpedanceLib({
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

  bool get isMale => gender == Gender.male;
  int get genderInt => isMale ? 1 : 0;

  double get heightCm => heightM * 100.0;

  /// Reusable constant for H_cm^2 / R which appears in several
  /// impedance-based formulas.
  double get h2rCoeff => heightCm * heightCm / impedance;

  /// BMI using standard formula.
  double get bmi => weightKg / (heightM * heightM);

  /// FFM / fat-free mass according to Sun SS et al. (2003).
  double get fatFreeMassKg {
    if (isMale) {
      return -10.68 + 0.65 * h2rCoeff + 0.26 * weightKg + 0.02 * impedance;
    } else {
      return -9.53 + 0.69 * h2rCoeff + 0.17 * weightKg + 0.02 * impedance;
    }
  }

  double get totalFatPercentage => (1.0 - fatFreeMassKg / weightKg) * 100.0;

  /// TBW / total body water according to Sun SS et al. (2003).
  double get totalBodyWaterKg {
    final double liters;
    if (isMale) {
      liters = 1.2 + 0.45 * h2rCoeff + 0.18 * weightKg;
    } else {
      liters = 3.75 + 0.45 * h2rCoeff + 0.11 * weightKg;
    }
    // Convert liters to kg at an average 36.5 C water temperature
    return 0.99513 * liters;
  }

  double get totalBodyWaterPercentage => (totalBodyWaterKg / weightKg) * 100.0;

  /// BMR / basal metabolic rate according to Katch-McArdle.
  double get basalMetabolicRate => fatFreeMassKg * 21.6 + 370;

  /// Skeletal Muscle Mass (kg) according to Janssen et al.
  double get skeletalMuscleMassKg =>
      0.401 * h2rCoeff + 3.825 * genderInt - 0.071 * age + 5.102;

  double get skeletalMusclePercentage =>
      (skeletalMuscleMassKg / weightKg) * 100.0;

  double get boneMassKg {
    final double factor = isMale ? 0.057 : 0.05;
    return factor * fatFreeMassKg;
  }
}
