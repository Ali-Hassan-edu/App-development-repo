import 'dart:math';

enum BMICategory {
  underweight,
  normal,
  overweight,
  obese,
}

class BMICalculator {
  final int heightCm;
  final int weightKg;

  BMICalculator({required this.heightCm, required this.weightKg});

  double _bmi = 0.0;

  // Calculates BMI (weight in kg / height in m^2)
  double calculateBMI() {
    // Convert height from cm to meters
    final double heightM = heightCm / 100;

    // BMI formula: weight (kg) / [height (m)]^2
    _bmi = weightKg / pow(heightM, 2);

    // Return BMI rounded to one decimal place
    return double.parse(_bmi.toStringAsFixed(1));
  }

  // Determines the BMI category based on standard WHO ranges.
  BMICategory getCategory() {
    if (_bmi < 18.5) {
      return BMICategory.underweight;
    } else if (_bmi >= 18.5 && _bmi <= 24.9) {
      return BMICategory.normal;
    } else if (_bmi >= 25.0 && _bmi <= 29.9) {
      return BMICategory.overweight;
    } else {
      return BMICategory.obese;
    }
  }

  // Returns the category text (e.g., 'NORMAL').
  String getResultText() {
    final BMICategory category = getCategory();
    switch (category) {
      case BMICategory.underweight:
        return 'UNDERWEIGHT';
      case BMICategory.normal:
        return 'NORMAL';
      case BMICategory.overweight:
        return 'OVERWEIGHT';
      case BMICategory.obese:
        return 'OBESE';
    }
  }

  // Provides an interpretation/recommendation message.
  String getInterpretation() {
    final BMICategory category = getCategory();
    switch (category) {
      case BMICategory.underweight:
        return 'You have a lower than normal body weight. Consider seeking advice on gaining weight.';
      case BMICategory.normal:
        return 'You have a normal body weight. Good job!';
      case BMICategory.overweight:
        return 'You have a higher than normal body weight. Focus on regular exercise and diet control.';
      case BMICategory.obese:
        return 'You have an extremely high body weight. It is highly recommended to consult a doctor.';
    }
  }
}