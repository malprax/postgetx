import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';

abstract final class AppTheme {
  static ThemeData _base(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      surface: dark ? AppColors.surface : AppColors.lightSurface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? AppColors.canvas : AppColors.lightCanvas,
      fontFamily: 'Roboto',
      visualDensity: VisualDensity.compact,
      dividerColor: dark ? AppColors.border : const Color(0xFFDCE4EC),
      textTheme: (dark ? ThemeData.dark() : ThemeData.light())
          .textTheme
          .apply(fontFamily: 'Roboto')
          .copyWith(
            bodyMedium: TextStyle(
                color: dark ? AppColors.text : AppColors.lightText,
                fontSize: 12),
            bodySmall: TextStyle(
                color: dark ? AppColors.textMuted : const Color(0xFF65788B),
                fontSize: 10),
            titleMedium: TextStyle(
                color: dark ? AppColors.text : AppColors.lightText,
                fontSize: 14,
                fontWeight: FontWeight.w700),
          ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: dark ? AppColors.surface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
              color: dark ? AppColors.border : const Color(0xFFDCE4EC)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? AppColors.surfaceHigh : Colors.white,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(
                color: dark ? AppColors.border : const Color(0xFFD5DFE8))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(
                color: dark ? AppColors.border : const Color(0xFFD5DFE8))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.primary)),
        hintStyle: TextStyle(
          color: dark
              ? AppColors.textMuted.withValues(alpha: .78)
              : const Color(0xFF718397),
          fontSize: 11,
        ),
        helperStyle: TextStyle(
          color: dark ? AppColors.textMuted : const Color(0xFF65788B),
          fontSize: 9,
        ),
        errorMaxLines: 2,
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(
            color: dark ? AppColors.borderSoft : const Color(0xFFD5DFE8)),
        backgroundColor: dark ? AppColors.surface : Colors.white,
        selectedColor: AppColors.primary,
        disabledColor: dark ? AppColors.surface : const Color(0xFFF1F4F7),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        labelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: dark ? AppColors.text : AppColors.lightText),
        secondaryLabelStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 40),
          side: BorderSide(
              color: dark ? AppColors.border : const Color(0xFFD5DFE8)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(34, 34),
          padding: const EdgeInsets.all(7),
        ),
      ),
    );
  }

  static final dark = _base(Brightness.dark);
  static final light = _base(Brightness.light);
}
