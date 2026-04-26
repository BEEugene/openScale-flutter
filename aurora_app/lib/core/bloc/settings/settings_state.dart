import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final bool isDarkTheme;
  final String locale;
  final bool isFirstStart;
  final bool showConfirmationOnDelete;
  final bool showQuestionMarkOnValues;
  final bool showMeanDifferenceLine;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.isDarkTheme = false,
    this.locale = 'en',
    this.isFirstStart = true,
    this.showConfirmationOnDelete = true,
    this.showQuestionMarkOnValues = true,
    this.showMeanDifferenceLine = false,
  });

  const SettingsState.initial()
    : themeMode = ThemeMode.system,
      isDarkTheme = false,
      locale = 'en',
      isFirstStart = true,
      showConfirmationOnDelete = true,
      showQuestionMarkOnValues = true,
      showMeanDifferenceLine = false;

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? isDarkTheme,
    String? locale,
    bool? isFirstStart,
    bool? showConfirmationOnDelete,
    bool? showQuestionMarkOnValues,
    bool? showMeanDifferenceLine,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      locale: locale ?? this.locale,
      isFirstStart: isFirstStart ?? this.isFirstStart,
      showConfirmationOnDelete:
          showConfirmationOnDelete ?? this.showConfirmationOnDelete,
      showQuestionMarkOnValues:
          showQuestionMarkOnValues ?? this.showQuestionMarkOnValues,
      showMeanDifferenceLine:
          showMeanDifferenceLine ?? this.showMeanDifferenceLine,
    );
  }

  @override
  List<Object?> get props => [
    themeMode,
    isDarkTheme,
    locale,
    isFirstStart,
    showConfirmationOnDelete,
    showQuestionMarkOnValues,
    showMeanDifferenceLine,
  ];
}
