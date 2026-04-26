// openScale
// Copyright (C) 2018  Maks Verver <maks@verver.ch>
//               2025  olie.xdev <olie.xdeveloper@googlemail.com>
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

/// Trisa body composition formulas.
class TrisaBodyAnalyzeLib {
  TrisaBodyAnalyzeLib({
    required int sex,
    required this.ageYears,
    required this.heightCm,
  }) : _isMale = sex == 1;

  final bool _isMale;
  final int ageYears;
  final double heightCm;

  double getBMI(double weightKg) {
    return weightKg * 1e4 / (heightCm * heightCm);
  }

  double getWater(double weightKg, double impedance) {
    final double bmi = getBMI(weightKg);

    if (_isMale) {
      return 87.51 + (-1.162 * bmi - 0.00813 * impedance + 0.07594 * ageYears);
    } else {
      return 77.721 + (-1.148 * bmi - 0.00573 * impedance + 0.06448 * ageYears);
    }
  }

  double getFat(double weightKg, double impedance) {
    final double bmi = getBMI(weightKg);

    if (_isMale) {
      return bmi * (1.479 + 4.4e-4 * impedance) + 0.1 * ageYears - 21.764;
    } else {
      return bmi * (1.506 + 3.908e-4 * impedance) + 0.1 * ageYears - 12.834;
    }
  }

  double getMuscle(double weightKg, double impedance) {
    final double bmi = getBMI(weightKg);

    if (_isMale) {
      return 74.627 + (-0.811 * bmi - 0.00565 * impedance - 0.367 * ageYears);
    } else {
      return 57.0 + (-0.694 * bmi - 0.00344 * impedance - 0.255 * ageYears);
    }
  }

  double getBone(double weightKg, double impedance) {
    final double bmi = getBMI(weightKg);

    if (_isMale) {
      return 7.829 + (-0.0855 * bmi - 5.92e-4 * impedance - 0.0389 * ageYears);
    } else {
      return 7.98 + (-0.0973 * bmi - 4.84e-4 * impedance - 0.036 * ageYears);
    }
  }
}
