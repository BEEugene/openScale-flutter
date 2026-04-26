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

/// Based on https://github.com/prototux/MIBCS-reverse-engineering by prototux
///
/// Xiaomi Mi Scale v1/v2 body composition formulas.
class MiScaleLib {
  MiScaleLib({required this.sex, required this.age, required this.height});

  /// male = 1; female = 0
  final int sex;

  final int age;

  /// height in cm
  final double height;

  double _getLBMCoefficient(double weight, double impedance) {
    double lbm = (height * 9.058 / 100.0) * (height / 100.0);
    lbm += weight * 0.32 + 12.226;
    lbm -= impedance * 0.0068;
    lbm -= age * 0.0542;
    return lbm;
  }

  /// weight [kg], height [cm]
  double getBMI(double weight) {
    return weight / (((height * height) / 100.0) / 100.0);
  }

  double getLBM(double weight, double impedance) {
    double leanBodyMass =
        weight -
        ((getBodyFat(weight, impedance) * 0.01) * weight) -
        getBoneMass(weight, impedance);

    if (sex == 0 && leanBodyMass >= 84.0) {
      leanBodyMass = 120.0;
    } else if (sex == 1 && leanBodyMass >= 93.5) {
      leanBodyMass = 120.0;
    }

    return leanBodyMass;
  }

  /// Skeletal Muscle Mass (%) derived from Janssen et al. BIA equation.
  /// If impedance is non-positive, falls back to LBM * ratio.
  double getMuscle(double weight, double impedance) {
    if (weight <= 0) return 0;

    final double smmKg;
    if (impedance > 0) {
      // Janssen et al.: SMM(kg) = 0.401*(H^2/R) + 3.825*sex - 0.071*age + 5.102
      final double h2OverR = (height * height) / impedance;
      smmKg = 0.401 * h2OverR + 3.825 * sex - 0.071 * age + 5.102;
    } else {
      // Fallback: approximate as fraction of LBM
      final double lbm = getLBM(weight, impedance);
      final double ratio = sex == 1 ? 0.52 : 0.46;
      smmKg = lbm * ratio;
    }

    final double percent = (smmKg / weight) * 100;
    return percent.clamp(10.0, 60.0);
  }

  double getWater(double weight, double impedance) {
    final double water = (100.0 - getBodyFat(weight, impedance)) * 0.7;
    final double coeff = water < 50 ? 1.02 : 0.98;
    return coeff * water;
  }

  double getBoneMass(double weight, double impedance) {
    final double base = sex == 0 ? 0.245691014 : 0.18016894;
    double boneMass =
        (base - (_getLBMCoefficient(weight, impedance) * 0.05158)) * -1.0;

    boneMass = boneMass > 2.2 ? boneMass + 0.1 : boneMass - 0.1;

    if (sex == 0 && boneMass > 5.1) {
      boneMass = 8.0;
    } else if (sex == 1 && boneMass > 5.2) {
      boneMass = 8.0;
    }

    return boneMass;
  }

  double getVisceralFat(double weight) {
    double visceralFat = 0.0;
    if (sex == 0) {
      if (weight > (13.0 - (height * 0.5)) * -1.0) {
        final double subsubcalc =
            ((height * 1.45) + (height * 0.1158) * height) - 120.0;
        final double subcalc = weight * 500.0 / subsubcalc;
        visceralFat = (subcalc - 6.0) + (age * 0.07);
      } else {
        final double subcalc = 0.691 + (height * -0.0024) + (height * -0.0024);
        visceralFat =
            (((height * 0.027) - (subcalc * weight)) * -1.0) +
            (age * 0.07) -
            age;
      }
    } else {
      if (height < weight * 1.6) {
        final double subcalc =
            ((height * 0.4) - (height * (height * 0.0826))) * -1.0;
        visceralFat =
            ((weight * 305.0) / (subcalc + 48.0)) - 2.9 + (age * 0.15);
      } else {
        final double subcalc = 0.765 + height * -0.0015;
        visceralFat =
            (((height * 0.143) - (weight * subcalc)) * -1.0) +
            (age * 0.15) -
            5.0;
      }
    }
    return visceralFat;
  }

  double getBodyFat(double weight, double impedance) {
    double lbmSub = 0.8;
    if (sex == 0 && age <= 49) {
      lbmSub = 9.25;
    } else if (sex == 0 && age > 49) {
      lbmSub = 7.25;
    }

    final double lbmCoeff = _getLBMCoefficient(weight, impedance);
    double coeff = 1.0;

    if (sex == 1 && weight < 61.0) {
      coeff = 0.98;
    } else if (sex == 0 && weight > 60.0) {
      coeff = 0.96;
      if (height > 160.0) {
        coeff *= 1.03;
      }
    } else if (sex == 0 && weight < 50.0) {
      coeff = 1.02;
      if (height > 160.0) {
        coeff *= 1.03;
      }
    }

    double bodyFat = (1.0 - (((lbmCoeff - lbmSub) * coeff) / weight)) * 100.0;
    if (bodyFat > 63.0) {
      bodyFat = 75.0;
    }
    return bodyFat;
  }
}
