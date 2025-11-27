import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/gender_card.dart';
import '../services/bmi_calculator.dart';
import '../models/bmi_result.dart';
import 'result_screen.dart';
import '../widgets/animated_title.dart'; // Import the dedicated widget


class BMICalculatorScreen extends StatefulWidget {
  const BMICalculatorScreen({super.key});

  static const String id = 'bmi_calculator_screen';

  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> with SingleTickerProviderStateMixin {
  // --- State Variables ---
  Gender? selectedGender;
  int height = 175; // Default from image
  int weight = 70;  // Default from image
  int age = 30;     // Default from image

  // Animation Controller for the AppBar Title
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Loop duration
    )..repeat(reverse: true); // Repeat the animation

    // The animation tween controls the gradient position from -1.0 to 2.0
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose controller to prevent memory leaks
    super.dispose();
  }

  // --- UI Card Builder ---
  Widget buildCard({
    required Widget child,
    LinearGradient gradient = kInactiveCardGradient
  }) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: child,
    );
  }

  // --- Main Calculation Logic ---
  void calculateAndNavigate() {
    // Basic validation for gender selection
    if (selectedGender == null) {
      // In a real app, you'd show a Snackbar or a dialog here.
      debugPrint('Please select a gender.');
      return;
    }

    // 1. Create the calculator instance
    BMICalculator calc = BMICalculator(
      heightCm: height,
      weightKg: weight,
    );

    // 2. Calculate and create the result model
    BMIResult result = BMIResult.fromCalculator(calc);

    // 3. Navigate to the result screen
    Navigator.pushNamed(
      context,
      ResultScreen.id,
      arguments: result,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Use the imported AnimatedTitle widget
        title: AnimatedTitle(
          text: 'BMI Calculator',
          animation: _animation,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // 1. Gender Selection Row
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: GenderCard(
                    icon: Icons.male,
                    label: 'Male',
                    isSelected: selectedGender == Gender.male,
                    onTap: () {
                      setState(() {
                        selectedGender = Gender.male;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: GenderCard(
                    icon: Icons.female,
                    label: 'Female',
                    isSelected: selectedGender == Gender.female,
                    onTap: () {
                      setState(() {
                        selectedGender = Gender.female;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // 2. Height Slider Card
          Expanded(
            child: buildCard(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text('Height', style: kLabelTextStyle),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: <Widget>[
                        Text(height.toString(), style: kNumberTextStyle),
                        const SizedBox(width: 5.0),
                        const Text('cm', style: kLabelTextStyle),
                      ],
                    ),
                    Slider(
                      value: height.toDouble(),
                      min: 100.0,
                      max: 220.0,
                      onChanged: (double newValue) {
                        setState(() {
                          height = newValue.round();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Weight and Age Row
          Expanded(
            child: Row(
              children: <Widget>[
                // Weight Card
                Expanded(
                  child: buildCard(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text('Weight', style: kLabelTextStyle),
                        Text(weight.toString(), style: kNumberTextStyle),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('kg', style: kLabelTextStyle.copyWith(fontSize: 20)),
                            const SizedBox(width: 15),
                            // Minus button
                            FloatingActionButton(
                              heroTag: "btnWeightMinus",
                              mini: true,
                              onPressed: () => setState(() => weight--),
                              backgroundColor: kCardColor,
                              child: const Icon(Icons.remove, color: Colors.white),
                            ),
                            // Plus button
                            FloatingActionButton(
                              heroTag: "btnWeightPlus",
                              mini: true,
                              onPressed: () => setState(() => weight++),
                              backgroundColor: kCardColor,
                              child: const Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                // Age Card
                Expanded(
                  child: buildCard(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text('Age', style: kLabelTextStyle),
                        Text(age.toString(), style: kNumberTextStyle),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('yrs', style: kLabelTextStyle.copyWith(fontSize: 20)),
                            const SizedBox(width: 15),
                            // Minus button
                            FloatingActionButton(
                              heroTag: "btnAgeMinus",
                              mini: true,
                              onPressed: () => setState(() => age--),
                              backgroundColor: kCardColor,
                              child: const Icon(Icons.remove, color: Colors.white),
                            ),
                            // Plus button
                            FloatingActionButton(
                              heroTag: "btnAgePlus",
                              mini: true,
                              onPressed: () => setState(() => age++),
                              backgroundColor: kCardColor,
                              child: const Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Bottom Button (Fixed to bottom center)
          GestureDetector(
            onTap: calculateAndNavigate,
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(bottom: 20.0),
              color: Colors.transparent, // Color is handled by gradient
              margin: const EdgeInsets.only(top: 10.0),
              height: kBottomContainerHeight,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85, // 85% width
                height: 60.0,
                decoration: BoxDecoration(
                  gradient: kGradient,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: const Center(
                  child: Text(
                    'CALCULATE BMI',
                    style: kBottomButtonTextStyle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}