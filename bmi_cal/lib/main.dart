import 'package:flutter/material.dart';
import 'screens/bmi_calculator_screen.dart';
import 'screens/result_screen.dart';
import 'utils/theme.dart';

void main() => runApp(const BMICalculatorApp());

class BMICalculatorApp extends StatelessWidget {
  const BMICalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BMI Calculator',
      // Apply the custom dark theme
      theme: kAppTheme,

      // Define the routes for navigation
      initialRoute: BMICalculatorScreen.id,
      routes: {
        BMICalculatorScreen.id: (context) => const BMICalculatorScreen(),
        ResultScreen.id: (context) => const ResultScreen(),
      },
    );
  }
}