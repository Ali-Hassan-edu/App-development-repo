import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFF0D47A1); // Professional Blue
  static const secondaryColor = Color(0xFF1976D2);
  static const errorColor = Color(0xFFD32F2F);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF8F9FF),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Colors.white,
        onSurface: primaryColor,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
        titleSmall: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: const TextStyle(color: primaryColor),
        bodyMedium: const TextStyle(color: primaryColor),
        labelLarge: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        titleTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: primaryColor.withValues(alpha: 0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            );
          }
          return TextStyle(color: primaryColor.withValues(alpha: 0.6));
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryColor);
          }
          return IconThemeData(color: primaryColor.withValues(alpha: 0.6));
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: primaryColor),
        hintStyle: TextStyle(color: primaryColor.withValues(alpha: 0.5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    );
  }
}
