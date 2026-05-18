import 'package:ai_service_orchestrator/src/consts/base_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      scaffoldBackgroundColor: BaseColors.background,

      colorScheme: ColorScheme.fromSeed(
        seedColor: BaseColors.primary,
        brightness: Brightness.light,
        surface: BaseColors.surface,
        primary: BaseColors.primary,
        secondary: BaseColors.secondary,
        error: BaseColors.error,
      ),

      // TYPOGRAPHY
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineMedium: GoogleFonts.inter(
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          color: BaseColors.textPrimary,
        ),

        titleLarge: GoogleFonts.inter(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: BaseColors.textPrimary,
        ),

        bodyLarge: GoogleFonts.inter(
          fontSize: 16.sp,
          color: BaseColors.textPrimary,
        ),

        bodyMedium: GoogleFonts.inter(
          fontSize: 14.sp,
          color: BaseColors.textSecondary,
        ),
      ),

      // APPBAR
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: BaseColors.surface,
        foregroundColor: BaseColors.textPrimary,
        surfaceTintColor: BaseColors.surface,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: BaseColors.textPrimary,
        ),
      ),

      // CARD
      cardTheme: CardThemeData(
        color: BaseColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
          side: const BorderSide(color: BaseColors.border),
        ),
      ),

      // BUTTONS
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BaseColors.primary,
          foregroundColor: BaseColors.surface,
          elevation: 0,

          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),

          textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
      ),

      // INPUTS
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BaseColors.surface,

        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),

        hintStyle: TextStyle(fontSize: 14.sp, color: BaseColors.textSecondary),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: BaseColors.border),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: BaseColors.border),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: BaseColors.primary, width: 1.5),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: BaseColors.error),
        ),
      ),

      dividerColor: BaseColors.border,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,

      scaffoldBackgroundColor: BaseColors.darkBackground,

      colorScheme: ColorScheme.fromSeed(
        seedColor: BaseColors.darkPrimary,
        brightness: Brightness.dark,
        surface: BaseColors.darkSurface,
        primary: BaseColors.darkPrimary,
        secondary: BaseColors.darkSecondary,
        error: BaseColors.darkError,
      ),

      // TYPOGRAPHY
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineMedium: GoogleFonts.inter(
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          color: BaseColors.darkTextPrimary,
        ),

        titleLarge: GoogleFonts.inter(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: BaseColors.darkTextPrimary,
        ),

        bodyLarge: GoogleFonts.inter(
          fontSize: 16.sp,
          color: BaseColors.darkTextPrimary,
        ),

        bodyMedium: GoogleFonts.inter(
          fontSize: 14.sp,
          color: BaseColors.darkTextSecondary,
        ),
      ),

      // APPBAR
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: BaseColors.darkSurface,
        foregroundColor: BaseColors.darkTextPrimary,
        surfaceTintColor: BaseColors.darkSurface,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: BaseColors.darkTextPrimary,
        ),
      ),

      // CARD
      cardTheme: CardThemeData(
        color: BaseColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
          side: const BorderSide(color: BaseColors.darkBorder),
        ),
      ),

      // BUTTONS
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BaseColors.darkPrimary,
          foregroundColor: BaseColors.surface,
          elevation: 0,

          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),

          textStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
      ),

      // INPUTS
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BaseColors.darkSurface,

        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),

        hintStyle: TextStyle(
          fontSize: 14.sp,
          color: BaseColors.darkTextSecondary,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: BaseColors.darkBorder),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: BaseColors.darkBorder),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(
            color: BaseColors.darkPrimary,
            width: 1.5,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: BaseColors.darkError),
        ),
      ),

      dividerColor: BaseColors.darkBorder,
    );
  }
}
