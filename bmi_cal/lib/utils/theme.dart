import 'package:flutter/material.dart';
import 'constants.dart';

// Defines the custom dark theme for the entire application.
final ThemeData kAppTheme = ThemeData.dark().copyWith(
  // Use the primary background color
  scaffoldBackgroundColor: kPrimaryColor,

  // Custom AppBar look (optional, but good for consistency)
  appBarTheme: const AppBarTheme(
    backgroundColor: kPrimaryColor,
    elevation: 0,
    centerTitle: true,
  ),

  // Custom Slider track color to match the gradient look
  sliderTheme: SliderThemeData(
    activeTrackColor: kAccentBlue.withOpacity(0.8),
    inactiveTrackColor: const Color(0xFF8D8E98),
    thumbColor: Colors.white,
    overlayColor: kAccentBlue.withOpacity(0.4),
    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 15.0),
    overlayShape: const RoundSliderOverlayShape(overlayRadius: 30.0),
  ),

  // Custom TextTheme to ensure all text is white by default
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: kTextColor),
    bodyMedium: TextStyle(color: kTextColor),
  ),
);