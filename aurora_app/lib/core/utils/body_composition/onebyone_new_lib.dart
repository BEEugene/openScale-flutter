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

/// 1byone v2 body composition formulas.
///
/// Similar to OneByoneLib but with slightly different calculations.
class OneByoneNewLib {
  OneByoneNewLib({
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

  double _getBounded(double value, double lowerBound, double upperBound) {
    if (value < lowerBound) return lowerBound;
    if (value > upperBound) return upperBound;
    return value;
  }

  double getBMI(double weight) {
    final double bmi = weight / (((height * height) / 100.0) / 100.0);
    return _getBounded(bmi, 10, 90);
  }

  double getLBM(double weight, int impedance) {
    double lbmCoeff = height / 100 * height / 100 * 9.058;
    lbmCoeff += 12.226;
    lbmCoeff += (weight * 0.32);
    lbmCoeff -= (impedance * 0.0068);
    lbmCoeff -= (age * 0.0542);
    return lbmCoeff;
  }

  double getBMMRCoeff(double weight) {
    double bmmrCoeff = 20;
    if (sex == 1) {
      bmmrCoeff = 21;
      if (age < 0xd) {
        bmmrCoeff = 36;
      } else if (age < 0x10) {
        bmmrCoeff = 30;
      } else if (age < 0x12) {
        bmmrCoeff = 26;
      } else if (age < 0x1e) {
        bmmrCoeff = 23;
      } else if (age >= 0x32) {
        bmmrCoeff = 20;
      }
    } else {
      if (age < 0xd) {
        bmmrCoeff = 34;
      } else if (age < 0x10) {
        bmmrCoeff = 29;
      } else if (age < 0x12) {
        bmmrCoeff = 24;
      } else if (age < 0x1e) {
        bmmrCoeff = 22;
      } else if (age >= 0x32) {
        bmmrCoeff = 19;
      }
    }
    return bmmrCoeff;
  }

  double getBMMR(double weight) {
    double bmmr;
    if (sex == 1) {
      bmmr = (weight * 14.916 + 877.8) - height * 0.726;
      bmmr -= (age * 8.976);
    } else {
      bmmr = (weight * 10.2036 + 864.6) - height * 0.39336;
      bmmr -= (age * 6.204);
    }

    return _getBounded(bmmr, 500, 1000);
  }

  double getBodyFatPercentage(double weight, int impedance) {
    double bodyFat = getLBM(weight, impedance);

    final double bodyFatConst;
    if (sex == 0) {
      if (age < 0x32) {
        bodyFatConst = 9.25;
      } else {
        bodyFatConst = 7.25;
      }
    } else {
      bodyFatConst = 0.8;
    }

    bodyFat -= bodyFatConst;

    if (sex == 0) {
      if (weight < 50) {
        bodyFat *= 1.02;
      } else if (weight > 60) {
        bodyFat *= 0.96;
      }

      if (height > 160) {
        bodyFat *= 1.03;
      }
    } else {
      if (weight < 61) {
        bodyFat *= 0.98;
      }
    }

    return 100 * (1 - bodyFat / weight);
  }

  double getBoneMass(double weight, int impedance) {
    final double lbmCoeff = getLBM(weight, impedance);

    double boneMassConst;
    if (sex == 1) {
      boneMassConst = 0.18016894;
    } else {
      boneMassConst = 0.245691014;
    }

    boneMassConst = lbmCoeff * 0.05158 - boneMassConst;
    final double boneMass;
    if (boneMassConst <= 2.2) {
      boneMass = boneMassConst - 0.1;
    } else {
      boneMass = boneMassConst + 0.1;
    }

    return _getBounded(boneMass, 0.5, 8);
  }

  double getMuscleMass(double weight, int impedance) {
    double muscleMass =
        weight - getBodyFatPercentage(weight, impedance) * 0.01 * weight;
    muscleMass -= getBoneMass(weight, impedance);
    return _getBounded(muscleMass, 10, 120);
  }

  double getSkeletonMusclePercentage(double weight, int impedance) {
    double skeletonMuscleMass = getWaterPercentage(weight, impedance);
    skeletonMuscleMass *= weight;
    skeletonMuscleMass *= 0.8422 * 0.01;
    skeletonMuscleMass -= 2.9903;
    skeletonMuscleMass /= weight;
    return skeletonMuscleMass * 100;
  }

  double getVisceralFat(double weight) {
    final double visceralFat;
    if (sex == 1) {
      if (height < weight * 1.6 + 63.0) {
        visceralFat =
            age * 0.15 +
            ((weight * 305.0) /
                    ((height * 0.0826 * height - height * 0.4) + 48.0) -
                2.9);
      } else {
        visceralFat =
            age * 0.15 +
            (weight * (height * -0.0015 + 0.765) - height * 0.143) -
            5.0;
      }
    } else {
      if (weight <= height * 0.5 - 13.0) {
        visceralFat =
            age * 0.07 +
            (weight * (height * -0.0024 + 0.691) - height * 0.027) -
            10.5;
      } else {
        visceralFat =
            age * 0.07 +
            ((weight * 500.0) /
                    ((height * 1.45 + height * 0.1158 * height) - 120.0) -
                6.0);
      }
    }

    return _getBounded(visceralFat, 1, 50);
  }

  double getWaterPercentage(double weight, int impedance) {
    double waterPercentage =
        (100 - getBodyFatPercentage(weight, impedance)) * 0.7;
    if (waterPercentage > 50) {
      waterPercentage *= 0.98;
    } else {
      waterPercentage *= 1.02;
    }

    return _getBounded(waterPercentage, 35, 75);
  }

  double getProteinPercentage(double weight, int impedance) {
    return (((100.0 - getBodyFatPercentage(weight, impedance)) -
            getWaterPercentage(weight, impedance) * 1.08)) -
        (getBoneMass(weight, impedance) / weight) * 100.0;
  }
}
