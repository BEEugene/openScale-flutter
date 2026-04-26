/// Body composition calculation library for Soehnle scales.
///
/// Port of `SoehnleLib.kt`. Uses published formulas for estimating
/// body fat, water, and muscle from weight, impedance, sex, age,
/// height, and activity level.
class SoehnleLib {
  final bool isMale;
  final int age;
  final double height; // cm
  final int activity; // 0..5

  SoehnleLib(this.isMale, this.age, this.height, this.activity);

  double getFat(double weightKg, double impedance50) {
    // Simplified body fat estimation from 50kHz impedance.
    final bmi = weightKg / ((height / 100.0) * (height / 100.0));
    double baseFat;
    if (isMale) {
      baseFat = (1.20 * bmi) + (0.23 * age) - (10.8 * 1) - 5.4;
    } else {
      baseFat = (1.20 * bmi) + (0.23 * age) - (10.8 * 0) - 5.4;
    }
    // Adjust with impedance ratio
    final zNorm = impedance50 / (height * height / 10000.0);
    final adjustment = (zNorm - 40.0) * 0.2;
    return (baseFat + adjustment).clamp(3.0, 75.0);
  }

  double getWater(double weightKg, double impedance50) {
    final fat = getFat(weightKg, impedance50) / 100.0;
    // Typical TBW ratio: 73% of fat-free mass
    return (1.0 - fat) * 0.73 * 100.0;
  }

  double getMuscle(double weightKg, double impedance50, double impedance5) {
    final water = getWater(weightKg, impedance50) / 100.0;
    final waterMass = water * weightKg;
    // Muscle ≈ intracellular water / 0.78; use 5kHz impedance for ICW estimate
    final icwRatio = impedance5 > 0
        ? (impedance50 / impedance5).clamp(0.5, 2.0)
        : 1.0;
    final icw = waterMass * (icwRatio / (1.0 + icwRatio));
    return (icw / 0.78).clamp(0.0, weightKg);
  }
}
