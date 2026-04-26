import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: const Color(0xFF1B6585),
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: const Color(0xFFC3E8FF),
      onPrimaryContainer: const Color(0xFF004C68),
      secondary: const Color(0xFF4E616D),
      onSecondary: const Color(0xFFFFFFFF),
      secondaryContainer: const Color(0xFFD1E5F3),
      onSecondaryContainer: const Color(0xFF364955),
      tertiary: const Color(0xFF605A7D),
      onTertiary: const Color(0xFFFFFFFF),
      tertiaryContainer: const Color(0xFFE6DEFF),
      onTertiaryContainer: const Color(0xFF484264),
      error: const Color(0xFFBA1A1A),
      onError: const Color(0xFFFFFFFF),
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF93000A),
      surface: const Color(0xFFF6FAFE),
      onSurface: const Color(0xFF171C1F),
      surfaceContainerHighest: const Color(0xFFDFE3E7),
      surfaceContainerHigh: const Color(0xFFE5E9ED),
      surfaceContainer: const Color(0xFFEAEEF2),
      surfaceContainerLow: const Color(0xFFF0F4F8),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceDim: const Color(0xFFD6DADF),
      surfaceBright: const Color(0xFFF6FAFE),
      outline: const Color(0xFF71787D),
      outlineVariant: const Color(0xFFC0C7CD),
      inverseSurface: const Color(0xFF2C3134),
      onInverseSurface: const Color(0xFFEDF1F5),
      inversePrimary: const Color(0xFF8FCFF3),
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: const Color(0xFF8FCFF3),
      onPrimary: const Color(0xFF003549),
      primaryContainer: const Color(0xFF004C68),
      onPrimaryContainer: const Color(0xFFC3E8FF),
      secondary: const Color(0xFFB5C9D7),
      onSecondary: const Color(0xFF20333D),
      secondaryContainer: const Color(0xFF364955),
      onSecondaryContainer: const Color(0xFFD1E5F3),
      tertiary: const Color(0xFFC9C1EA),
      onTertiary: const Color(0xFF312C4C),
      tertiaryContainer: const Color(0xFF484264),
      onTertiaryContainer: const Color(0xFFE6DEFF),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      surface: const Color(0xFF0F1417),
      onSurface: const Color(0xFFDFE3E7),
      surfaceContainerHighest: const Color(0xFF313539),
      surfaceContainerHigh: const Color(0xFF262B2E),
      surfaceContainer: const Color(0xFF1C2023),
      surfaceContainerLow: const Color(0xFF171C1F),
      surfaceContainerLowest: const Color(0xFF0A0F12),
      surfaceDim: const Color(0xFF0F1417),
      surfaceBright: const Color(0xFF353A3D),
      outline: const Color(0xFF8A9297),
      outlineVariant: const Color(0xFF41484D),
      inverseSurface: const Color(0xFFDFE3E7),
      onInverseSurface: const Color(0xFF2C3134),
      inversePrimary: const Color(0xFF1B6585),
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceContainer,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.primaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant),
      textTheme: ThemeData.light().textTheme.copyWith(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        bodyLarge: TextStyle(color: colorScheme.onSurface),
        bodyMedium: TextStyle(color: colorScheme.onSurface),
        labelLarge: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.resolveWith((states) {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            );
          }),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        backgroundColor: colorScheme.surfaceContainerLow,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      ),
    );
  }
}
