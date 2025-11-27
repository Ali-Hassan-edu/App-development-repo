import 'package:flutter/material.dart';
import '../models/bmi_result.dart';
import '../services/bmi_calculator.dart';
import '../utils/constants.dart';
import '../widgets/result_recommendation_card.dart';
import '../widgets/animated_title.dart'; // Import the dedicated widget


class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  static const String id = 'result_screen';

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Loop duration
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper to determine the color of the result category text
  Color getResultColor(BMICategory category) {
    switch (category) {
      case BMICategory.normal:
        return kNormalResultColor;
      case BMICategory.underweight:
        return Colors.yellow.shade700;
      case BMICategory.overweight:
        return Colors.orange.shade700;
      case BMICategory.obese:
        return Colors.red.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the BMIResult object passed from the previous screen
    final result = ModalRoute.of(context)!.settings.arguments as BMIResult;

    return Scaffold(
      appBar: AppBar(
        // Use the imported AnimatedTitle widget
        title: AnimatedTitle(
          text: 'Your Result',
          animation: _animation,
        ),
      ),
      // FIX: Wrap the main content in SingleChildScrollView and remove Expanded
      // to prevent the bottom overflow (yellow/black striped line).
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Top Result Section (Now using Padding/Column instead of Expanded)
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    result.resultText,
                    style: kResultTextStyle.copyWith(
                      color: getResultColor(result.category),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    result.bmiValue.toString(),
                    style: kResultBMITextStyle,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      result.interpretation,
                      textAlign: TextAlign.center,
                      style: kBodyTextStyle,
                    ),
                  ),
                ],
              ),
            ),

            // Recommendations Section (Now using Padding/Column instead of Expanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Text(
                    'Recommendations',
                    style: kTitleTextStyle,
                  ),
                  SizedBox(height: 20),
                  RecommendationCard(
                    icon: Icons.set_meal,
                    title: 'Balanced Diet',
                    subtitle: 'Maintain a nutrient-rich and caloric-appropriate diet.',
                  ),
                  RecommendationCard(
                    icon: Icons.fitness_center,
                    title: 'Regular Exercise',
                    subtitle: 'Stay active most days of the week, including cardio and strength.',
                  ),
                  RecommendationCard(
                    icon: Icons.water_drop,
                    title: 'Stay Hydrated',
                    subtitle: 'Drink plenty of water daily to support all bodily functions.',
                  ),
                  SizedBox(height: 30), // Added spacing before the button
                ],
              ),
            ),

            // Bottom Re-Calculate Button
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // Go back to the input screen
              },
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(bottom: 20.0),
                margin: const EdgeInsets.only(top: 10.0),
                height: kBottomContainerHeight,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85, // 85% width
                  height: 60.0,
                  decoration: BoxDecoration(
                    color: kRecalculateButtonColor,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: const Center(
                    child: Text(
                      'RE-CALCULATE',
                      style: kBottomButtonTextStyle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}