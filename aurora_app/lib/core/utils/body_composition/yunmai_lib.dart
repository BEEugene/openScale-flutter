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

/// Yunmai Mini/SE body composition formulas.
class YunmaiLib {
  YunmaiLib({
    required this.sex,
    required this.height,
    required ActivityLevel activityLevel,
  }) : _fitnessBodyType = toYunmaiActivityLevel(activityLevel) == 1;

  /// male = 1; female = 0
  final int sex;

  /// height in cm
  final double height;

  final bool _fitnessBodyType;

  static int toYunmaiActivityLevel(ActivityLevel activityLevel) {
    switch (activityLevel) {
      case ActivityLevel.heavy:
      case ActivityLevel.extreme:
        return 1;
      default:
        return 0;
    }
  }

  double getWater(double bodyFat) {
    return ((100.0 - bodyFat) * 0.726 * 100.0 + 0.5) / 100.0;
  }

  double getFat(int age, double weight, int resistance) {
    double r = (resistance - 100.0) / 100.0;
    final double h = height / 100.0;

    if (r >= 1) {
      r = sqrt(r);
    }

    double fat = (weight * 1.5 / h / h) + (age * 0.08);
    if (sex == 1) {
      fat -= 10.8;
    }

    fat = (fat - 7.4) + r;

    if (fat < 5.0 || fat > 75.0) {
      fat = 0.0;
    }

    return fat;
  }

  double getMuscle(double bodyFat) {
    double muscle = (100.0 - bodyFat) * 0.67;

    if (_fitnessBodyType) {
      muscle = (100.0 - bodyFat) * 0.7;
    }

    muscle = ((muscle * 100.0) + 0.5) / 100.0;

    return muscle;
  }

  double getSkeletalMuscle(double bodyFat) {
    double muscle = (100.0 - bodyFat) * 0.53;
    if (_fitnessBodyType) {
      muscle = (100.0 - bodyFat) * 0.6;
    }

    muscle = ((muscle * 100.0) + 0.5) / 100.0;

    return muscle;
  }

  double getBoneMass(double muscle, double weight) {
    final double h = height - 170.0;

    double boneMass;
    if (sex == 1) {
      boneMass =
          ((weight * (muscle / 100.0) * 4.0) / 7.0 * 0.22 * 0.6) + (h / 100.0);
    } else {
      boneMass =
          ((weight * (muscle / 100.0) * 4.0) / 7.0 * 0.34 * 0.45) + (h / 100.0);
    }

    boneMass = ((boneMass * 10.0) + 0.5) / 10.0;

    return boneMass;
  }

  double getLeanBodyMass(double weight, double bodyFat) {
    return weight * (100.0 - bodyFat) / 100.0;
  }

  double getVisceralFat(double bodyFat, int age) {
    double f = bodyFat;
    final int a = (age < 18 || age > 120) ? 18 : age;

    if (!_fitnessBodyType) {
      if (sex == 1) {
        if (a < 40) {
          f -= 21.0;
        } else if (a < 60) {
          f -= 22.0;
        } else {
          f -= 24.0;
        }
      } else {
        if (a < 40) {
          f -= 34.0;
        } else if (a < 60) {
          f -= 35.0;
        } else {
          f -= 36.0;
        }
      }

      double d = sex == 1 ? 1.4 : 1.8;
      if (f > 0.0) {
        d = 1.1;
      }

      double vf = (f / d) + 9.5;
      if (vf < 1.0) return 1.0;
      if (vf > 30.0) return 30.0;
      return vf;
    } else {
      double vf;
      if (bodyFat > 15.0) {
        vf = (bodyFat - 15.0) / 1.1 + 12.0;
      } else {
        vf = -1 * (15.0 - bodyFat) / 1.4 + 12.0;
      }
      if (vf < 1.0) return 1.0;
      if (vf > 9.0) return 9.0;
      return vf;
    }
  }
}
