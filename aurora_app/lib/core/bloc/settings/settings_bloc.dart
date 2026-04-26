import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openscale/core/bloc/settings/settings_state.dart';

export 'settings_state.dart';

class SettingsBloc extends Cubit<SettingsState> {
  static const String _keyIsDarkTheme = 'is_dark_theme';
  static const String _keyLocale = 'locale';
  static const String _keyIsFirstStart = 'is_first_start';
  static const String _keyShowConfirmationOnDelete =
      'show_confirmation_on_delete';
  static const String _keyShowQuestionMarkOnValues =
      'show_question_mark_on_values';
  static const String _keyShowMeanDifferenceLine = 'show_mean_difference_line';

  SettingsBloc() : super(const SettingsState.initial()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_keyIsDarkTheme) ?? false;
    final locale = prefs.getString(_keyLocale) ?? 'en';
    final isFirst = prefs.getBool(_keyIsFirstStart) ?? true;
    final showConfirm = prefs.getBool(_keyShowConfirmationOnDelete) ?? true;
    final showQuestion = prefs.getBool(_keyShowQuestionMarkOnValues) ?? true;
    final showMeanDiff = prefs.getBool(_keyShowMeanDifferenceLine) ?? false;

    emit(
      state.copyWith(
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        isDarkTheme: isDark,
        locale: locale,
        isFirstStart: isFirst,
        showConfirmationOnDelete: showConfirm,
        showQuestionMarkOnValues: showQuestion,
        showMeanDifferenceLine: showMeanDiff,
      ),
    );
  }

  Future<void> toggleTheme() async {
    final isDark = !state.isDarkTheme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDarkTheme, isDark);
    emit(
      state.copyWith(
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        isDarkTheme: isDark,
      ),
    );
  }

  Future<void> setTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDarkTheme, isDark);
    emit(
      state.copyWith(
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        isDarkTheme: isDark,
      ),
    );
  }

  Future<void> setLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale);
    emit(state.copyWith(locale: locale));
  }

  Future<void> markFirstStartComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsFirstStart, false);
    emit(state.copyWith(isFirstStart: false));
  }

  Future<void> setShowConfirmationOnDelete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowConfirmationOnDelete, value);
    emit(state.copyWith(showConfirmationOnDelete: value));
  }

  Future<void> setShowQuestionMarkOnValues(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowQuestionMarkOnValues, value);
    emit(state.copyWith(showQuestionMarkOnValues: value));
  }

  Future<void> setShowMeanDifferenceLine(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowMeanDifferenceLine, value);
    emit(state.copyWith(showMeanDifferenceLine: value));
  }
}
