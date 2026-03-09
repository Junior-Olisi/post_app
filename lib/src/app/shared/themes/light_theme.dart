import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.white,
      surface: AppColors.lightBackground,
      onSurface: AppColors.lightTextPrimary,
      onSurfaceVariant: AppColors.lightTextSecondary,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: AppColors.lightBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.lightTextPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.headlineSmall.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
    ),
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      displayMedium: AppTypography.displayMedium.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      displaySmall: AppTypography.displaySmall.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      headlineLarge: AppTypography.headlineLarge.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      headlineMedium: AppTypography.headlineMedium.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      headlineSmall: AppTypography.headlineSmall.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      titleLarge: AppTypography.titleLarge.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      titleMedium: AppTypography.titleMedium.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      titleSmall: AppTypography.titleSmall.copyWith(
        color: AppColors.lightTextSecondary,
      ),
      bodyLarge: AppTypography.bodyLarge.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      bodyMedium: AppTypography.bodyMedium.copyWith(
        color: AppColors.lightTextSecondary,
      ),
      bodySmall: AppTypography.bodySmall.copyWith(
        color: AppColors.lightTextSecondary,
      ),
      labelLarge: AppTypography.labelLarge.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      labelMedium: AppTypography.labelMedium.copyWith(
        color: AppColors.lightTextSecondary,
      ),
      labelSmall: AppTypography.labelSmall.copyWith(
        color: AppColors.lightTextSecondary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.white,
        textStyle: AppTypography.titleMedium.copyWith(
          color: AppColors.white,
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.lightPrimary,
        side: const BorderSide(
          color: AppColors.lightTextSecondary,
          width: 1,
        ),
        textStyle: AppTypography.titleMedium.copyWith(
          color: AppColors.lightPrimary,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.lightPrimary,
        textStyle: AppTypography.titleMedium.copyWith(
          color: AppColors.lightPrimary,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderSide: const BorderSide(
          color: AppColors.lightTextSecondary,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: AppColors.lightTextSecondary,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: AppColors.lightPrimary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.lightTextSecondary,
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.lightTextSecondary,
      ),
      errorStyle: AppTypography.bodySmall.copyWith(
        color: Colors.red,
      ),
    ),
    iconTheme: const IconThemeData(
      color: AppColors.lightTextPrimary,
      size: 24,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.lightPrimary;
        }
        return AppColors.lightTextSecondary;
      }),
      checkColor: WidgetStateProperty.all(AppColors.white),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.lightPrimary;
        }
        return AppColors.lightTextSecondary;
      }),
    ),
  );
}
