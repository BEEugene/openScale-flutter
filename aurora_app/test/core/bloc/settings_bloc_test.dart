import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:openscale/core/bloc/settings/settings_bloc.dart';
import 'package:openscale/core/bloc/settings/settings_state.dart';

void main() {
  group('SettingsBloc', () {
    late SettingsBloc bloc;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      bloc = SettingsBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state has correct defaults', () async {
      // Wait for async _loadSettings to complete
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.themeMode, ThemeMode.system);
      expect(bloc.state.isDarkTheme, false);
      expect(bloc.state.locale, 'en');
      expect(bloc.state.isFirstStart, true);
      expect(bloc.state.showConfirmationOnDelete, true);
      expect(bloc.state.showQuestionMarkOnValues, true);
      expect(bloc.state.showMeanDifferenceLine, false);
    });

    test('toggleTheme switches from light to dark', () async {
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final states = <SettingsState>[];
      final subscription = bloc.stream.listen(states.add);

      await bloc.toggleTheme();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.isDarkTheme, true);
      expect(bloc.state.themeMode, ThemeMode.dark);

      await subscription.cancel();
    });

    test('toggleTheme switches from dark to light', () async {
      SharedPreferences.setMockInitialValues({'is_dark_theme': true});
      bloc = SettingsBloc();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      await bloc.toggleTheme();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.isDarkTheme, false);
      expect(bloc.state.themeMode, ThemeMode.light);
    });

    test('setTheme(true) sets dark theme', () async {
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await bloc.setTheme(true);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.isDarkTheme, true);
      expect(bloc.state.themeMode, ThemeMode.dark);
    });

    test('setTheme(false) sets light theme', () async {
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await bloc.setTheme(false);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.isDarkTheme, false);
      expect(bloc.state.themeMode, ThemeMode.light);
    });

    test('setLocale updates locale', () async {
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await bloc.setLocale('ru');
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.locale, 'ru');
    });

    test('markFirstStartComplete sets isFirstStart to false', () async {
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await bloc.markFirstStartComplete();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.isFirstStart, false);
    });

    test('setShowConfirmationOnDelete updates value', () async {
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await bloc.setShowConfirmationOnDelete(false);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.showConfirmationOnDelete, false);
    });

    test('setShowQuestionMarkOnValues updates value', () async {
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await bloc.setShowQuestionMarkOnValues(false);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.showQuestionMarkOnValues, false);
    });

    test('setShowMeanDifferenceLine updates value', () async {
      await Future<void>.delayed(const Duration(milliseconds: 100));

      await bloc.setShowMeanDifferenceLine(true);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(bloc.state.showMeanDifferenceLine, true);
    });

    test('loads settings from SharedPreferences on construction', () async {
      SharedPreferences.setMockInitialValues({
        'is_dark_theme': true,
        'locale': 'de',
        'is_first_start': false,
        'show_confirmation_on_delete': false,
        'show_question_mark_on_values': false,
        'show_mean_difference_line': true,
      });

      final loadedBloc = SettingsBloc();
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(loadedBloc.state.isDarkTheme, true);
      expect(loadedBloc.state.themeMode, ThemeMode.dark);
      expect(loadedBloc.state.locale, 'de');
      expect(loadedBloc.state.isFirstStart, false);
      expect(loadedBloc.state.showConfirmationOnDelete, false);
      expect(loadedBloc.state.showQuestionMarkOnValues, false);
      expect(loadedBloc.state.showMeanDifferenceLine, true);

      await loadedBloc.close();
    });
  });
}
