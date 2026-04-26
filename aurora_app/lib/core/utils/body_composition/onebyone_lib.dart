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

/// 1byone v1 body composition formulas.
class OneByoneLib {
  OneByoneLib({
    required this.sex,
    required this.age,
    required this.height,
    required this.peopleType,
  });

  /// male = 1; female = 0
  final int sex;
  final int age;

  /// height in cm
  final double height;

  /// low activity = 0; medium activity = 1; high activity = 2
  final int peopleType;

  double getBMI(double weight) {
    return weight / (((height * height) / 100.0) / 100.0);
  }

  double getLBM(double weight, double bodyFat) {
    return weight - (bodyFat / 100.0 * weight);
  }

  double getMuscle(double weight, double impedanceValue) {
    return (height * height / impedanceValue * 0.401 +
            (sex * 3.825) -
            (age * 0.071) +
            5.102) /
        weight *
        100.0;
  }

  double getWater(double bodyFat) {
    final double coeff;
    final double water = (100.0 - bodyFat) * 0.7;

    if (water < 50) {
      coeff = 1.02;
    } else {
      coeff = 0.98;
    }

    return coeff * water;
  }

  double getBoneMass(double weight, double impedanceValue) {
    double peopleCoeff;
    switch (peopleType) {
      case 0:
        peopleCoeff = 1.0;
      case 1:
        peopleCoeff = 1.0427;
      case 2:
        peopleCoeff = 1.0958;
      default:
        peopleCoeff = 1.0;
    }

    double boneMass =
        (9.058 * (height / 100.0) * (height / 100.0) +
            12.226 +
            (0.32 * weight)) -
        (0.0068 * impedanceValue);

    final double sexConst;
    if (sex == 1) {
      sexConst = 3.49305;
    } else {
      sexConst = 4.76325;
    }

    boneMass = boneMass - sexConst - (age * 0.0542) * peopleCoeff;

    if (boneMass <= 2.2) {
      boneMass = boneMass - 0.1;
    } else {
      boneMass = boneMass + 0.1;
    }

    boneMass = boneMass * 0.05158;

    if (0.5 > boneMass) {
      return 0.5;
    } else if (boneMass > 8.0) {
      return 8.0;
    }

    return boneMass;
  }

  double getVisceralFat(double weight) {
    double visceralFat;

    if (sex == 1) {
      if (height < ((1.6 * weight) + 63.0)) {
        visceralFat =
            (((weight * 305.0) /
                    (0.0826 * height * height - (0.4 * height) + 48.0)) -
                2.9) +
            (age.toDouble() * 0.15);

        if (peopleType == 0) {
          return visceralFat;
        } else {
          return _subVisceralFatA(visceralFat);
        }
      } else {
        visceralFat =
            ((age.toDouble() * 0.15) +
                ((weight * (-0.0015 * height + 0.765)) - height * 0.143)) -
            5.0;

        if (peopleType == 0) {
          return visceralFat;
        } else {
          return _subVisceralFatA(visceralFat);
        }
      }
    } else {
      if (((0.5 * height) - 13.0) > weight) {
        visceralFat =
            ((age.toDouble() * 0.07) +
                ((weight * (-0.0024 * height + 0.691)) - (height * 0.027))) -
            10.5;

        if (peopleType != 0) {
          return _subVisceralFatA(visceralFat);
        } else {
          return visceralFat;
        }
      } else {
        visceralFat =
            (weight * 500.0) /
                (((1.45 * height) + 0.1158 * height * height) - 120.0) -
            6.0 +
            (age.toDouble() * 0.07);

        if (peopleType == 0) {
          return visceralFat;
        } else {
          return _subVisceralFatA(visceralFat);
        }
      }
    }
  }

  double _subVisceralFatA(double visceralFat) {
    if (peopleType != 0) {
      if (10.0 <= visceralFat) {
        return _subVisceralFatB(visceralFat);
      } else {
        return visceralFat - 4.0;
      }
    } else {
      if (10.0 > visceralFat) {
        return visceralFat - 2.0;
      } else {
        return _subVisceralFatB(visceralFat);
      }
    }
  }

  double _subVisceralFatB(double visceralFat) {
    if (visceralFat < 10.0) {
      return visceralFat * 0.85;
    } else {
      if (20.0 < visceralFat) {
        return visceralFat * 0.85;
      } else {
        return visceralFat * 0.8;
      }
    }
  }

  double getBodyFat(double weight, double impedanceValue) {
    double bodyFatConst;

    if (impedanceValue >= 1200.0) {
      bodyFatConst = 8.16;
    } else if (impedanceValue >= 200.0) {
      bodyFatConst = 0.0068 * impedanceValue;
    } else if (impedanceValue >= 50.0) {
      bodyFatConst = 1.36;
    } else {
      bodyFatConst = 0.0;
    }

    final double peopleTypeCoeff;
    if (peopleType == 0) {
      peopleTypeCoeff = 1.0;
    } else if (peopleType == 1) {
      peopleTypeCoeff = 1.0427;
    } else {
      peopleTypeCoeff = 1.0958;
    }

    double bodyVar = (9.058 * height) / 100.0;
    bodyVar = bodyVar * height;
    bodyVar = bodyVar / 100.0 + 12.226;
    bodyVar = bodyVar + 0.32 * weight;
    bodyVar = bodyVar - bodyFatConst;

    if (age > 0x31) {
      bodyFatConst = 7.25;
      if (sex == 1) {
        bodyFatConst = 0.8;
      }
    } else {
      bodyFatConst = 9.25;
      if (sex == 1) {
        bodyFatConst = 0.8;
      }
    }

    bodyVar = bodyVar - bodyFatConst;
    bodyVar = bodyVar - (age * 0.0542);
    bodyVar = bodyVar * peopleTypeCoeff;

    if (sex != 0) {
      if (61.0 > weight) {
        bodyVar *= 0.98;
      }
    } else {
      if (50.0 > weight) {
        bodyVar *= 1.02;
      }

      if (weight > 60.0) {
        bodyVar *= 0.96;
      }

      if (height > 160.0) {
        bodyVar *= 1.03;
      }
    }

    bodyVar = bodyVar / weight;
    final double bodyFat = 100.0 * (1.0 - bodyVar);

    if (1.0 > bodyFat) {
      return 1.0;
    } else {
      if (bodyFat > 45.0) {
        return 45.0;
      } else {
        return bodyFat;
      }
    }
  }
}
