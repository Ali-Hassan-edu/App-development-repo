import '../services/bmi_calculator.dart';

// Data model to cleanly pass the calculation results between screens.
class BMIResult {
  final double bmiValue;
  final BMICategory category;
  final String resultText;
  final String interpretation;

  BMIResult({
    required this.bmiValue,
    required this.category,
    required this.resultText,
    required this.interpretation,
  });

  // Factory method to create an instance from a calculator object
  factory BMIResult.fromCalculator(BMICalculator calculator) {
    // Perform calculation and get all derived results
    final double calculatedBMI = calculator.calculateBMI();

    return BMIResult(
      bmiValue: calculatedBMI,
      category: calculator.getCategory(),
      resultText: calculator.getResultText(),
      interpretation: calculator.getInterpretation(),
    );
  }
}