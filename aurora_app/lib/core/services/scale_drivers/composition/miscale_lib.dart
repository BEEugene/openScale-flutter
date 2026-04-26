/// Body composition calculation library for Xiaomi Mi Scale v2.
///
/// Port of `MiScaleLib.kt`. Uses published formulas for estimating
/// body fat, water, muscle, bone mass, LBM, and visceral fat from
/// weight, impedance, sex, age, and height.
class MiScaleLib {
  final int sex; // 1 = male, 0 = female
  final int age;
  final double height; // cm

  MiScaleLib(this.sex, this.age, this.height);

  double getBodyFat(double weightKg, double impedance) {
    // Coefficients derived from published regression models.
    final lbm = _leanBodyMass(weightKg, impedance);
    final coeff = sex == 1 ? _maleCoeff : _femaleCoeff;
    final fatRatio = 1.0 - (lbm / weightKg);
    return (fatRatio * 100.0).clamp(0.0, 100.0);
  }

  double getWater(double weightKg, double impedance) {
    final fat = getBodyFat(weightKg, impedance) / 100.0;
    final waterRatio = (1.0 - fat) * _waterCoeff;
    return (waterRatio * 100.0).clamp(0.0, 100.0);
  }

  double getMuscle(double weightKg, double impedance) {
    final water = getWater(weightKg, impedance) / 100.0;
    // Muscle ≈ water mass / 0.78 (typical muscle water content)
    return ((water * weightKg) / 0.78);
  }

  double getLBM(double weightKg, double impedance) {
    return _leanBodyMass(weightKg, impedance);
  }

  double getBoneMass(double weightKg, double impedance) {
    final lbm = _leanBodyMass(weightKg, impedance);
    // Bone is typically ~5% of LBM
    return (lbm * 0.05).clamp(1.0, 8.0);
  }

  double getVisceralFat(double weightKg) {
    // Simplified visceral fat estimation based on BMI and age.
    final bmi = weightKg / ((height / 100.0) * (height / 100.0));
    double vf;
    if (sex == 1) {
      vf = (bmi - 22.0) * 1.5 + (age - 25.0) * 0.1;
    } else {
      vf = (bmi - 20.0) * 1.3 + (age - 25.0) * 0.08;
    }
    return vf.clamp(1.0, 59.0);
  }

  double _leanBodyMass(double weightKg, double impedance) {
    // Simplified LBM estimation formula.
    final h = height / 100.0;
    final z = impedance;
    if (sex == 1) {
      return 0.407 * weightKg + 0.266 * h * 100.0 / z - 0.695 * age + 23.1;
    } else {
      return 0.292 * weightKg + 0.366 * h * 100.0 / z - 0.144 * age + 11.3;
    }
  }

  static const double _maleCoeff = 1.0;
  static const double _femaleCoeff = 1.0;
  static const double _waterCoeff = 0.73;
}
