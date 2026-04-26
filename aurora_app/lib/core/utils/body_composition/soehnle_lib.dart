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

/// Soehnle body composition formulas.
class SoehnleLib {
  SoehnleLib({
    required bool isMale,
    required this.age,
    required this.height,
    required this.activityLevel,
  }) : _isMale = isMale;

  final bool _isMale;
  final int age;

  /// height in cm
  final double height;

  /// activity level (1..5)
  final int activityLevel;

  double getFat(double weight, double imp50) {
    double activityCorrFac = 0.0;

    switch (activityLevel) {
      case 4:
        if (_isMale) {
          activityCorrFac = 2.5;
        } else {
          activityCorrFac = 2.3;
        }
      case 5:
        if (_isMale) {
          activityCorrFac = 4.3;
        } else {
          activityCorrFac = 4.1;
        }
    }

    final double sexCorrFac;
    final double activitySexDiv;

    if (_isMale) {
      sexCorrFac = 0.250;
      activitySexDiv = 65.5;
    } else {
      sexCorrFac = 0.214;
      activitySexDiv = 55.1;
    }

    return 1.847 * weight * 10000.0 / (height * height) +
        sexCorrFac * age +
        0.062 * imp50 -
        (activitySexDiv - activityCorrFac);
  }

  double computeBodyMassIndex(double weight) {
    return 10000.0 * weight / (height * height);
  }

  double getWater(double weight, double imp50) {
    double activityCorrFac = 0.0;

    switch (activityLevel) {
      case 1:
      case 2:
      case 3:
        if (_isMale) {
          activityCorrFac = 2.83;
        } else {
          activityCorrFac = 0.0;
        }
      case 4:
        if (_isMale) {
          activityCorrFac = 3.93;
        } else {
          activityCorrFac = 0.4;
        }
      case 5:
        if (_isMale) {
          activityCorrFac = 5.33;
        } else {
          activityCorrFac = 1.4;
        }
    }
    return (0.3674 * height * height / imp50 +
            0.17530 * weight -
            0.11 * age +
            (6.53 + activityCorrFac)) /
        weight *
        100.0;
  }

  double getMuscle(double weight, double imp50, double imp5) {
    double activityCorrFac = 0.0;

    switch (activityLevel) {
      case 1:
      case 2:
      case 3:
        if (_isMale) {
          activityCorrFac = 3.6224;
        } else {
          activityCorrFac = 0.0;
        }
      case 4:
        if (_isMale) {
          activityCorrFac = 4.3904;
        } else {
          activityCorrFac = 0.0;
        }
      case 5:
        if (_isMale) {
          activityCorrFac = 5.4144;
        } else {
          activityCorrFac = 1.664;
        }
    }
    return ((0.47027 / imp50 - 0.24196 / imp5) * height * height +
            0.13796 * weight -
            0.1152 * age +
            (5.12 + activityCorrFac)) /
        weight *
        100.0;
  }
}
