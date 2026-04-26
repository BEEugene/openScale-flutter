import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Measurement type colors
  static const Color weight = Color(0xFF7E57C2);
  static const Color bmi = Color(0xFFFFCA28);
  static const Color fat = Color(0xFFEF5350);
  static const Color water = Color(0xFF29B6F6);
  static const Color muscle = Color(0xFF66BB6A);
  static const Color lbm = Color(0xFFAB47BC);
  static const Color bone = Color(0xFF8D6E63);
  static const Color waist = Color(0xFF42A5F5);
  static const Color whr = Color(0xFFEC407A);
  static const Color whtr = Color(0xFFF06292);
  static const Color hips = Color(0xFF5C6BC0);
  static const Color visceralFat = Color(0xFFFF7043);
  static const Color chest = Color(0xFF26A69A);
  static const Color thigh = Color(0xFF7E57C2);
  static const Color biceps = Color(0xFF5C6BC0);
  static const Color neck = Color(0xFF78909C);
  static const Color caliper = Color(0xFFFFA726);
  static const Color bmr = Color(0xFFEF5350);
  static const Color tdee = Color(0xFFE53935);
  static const Color heartRate = Color(0xFFE91E63);
  static const Color calories = Color(0xFFFF5722);

  // Evaluation state colors (matching Android EvaluationState enum)
  static const Color evaluationLow = Color(0xFFEF5350);
  static const Color evaluationNormal = Color(0xFF66BB6A);
  static const Color evaluationHigh = Color(0xFFFFA726);
  static const Color evaluationUndefined = Color(0xFFBDBDBD);

  // Trend colors
  static const Color trendUp = Color(0xFFEF5350);
  static const Color trendDown = Color(0xFF66BB6A);
  static const Color trendStable = Color(0xFFFFCA28);

  // Brand color (matching Android AppBrandBlue)
  static const Color brandBlue = Color(0xFF0099CC);
}
