BMI Calculator (Body Mass Index)

This is a modern, responsive BMI Calculator application built with Flutter. It follows a clean, dark-themed UI pattern and features a unique animated title bar using a ShaderMask for a dynamic gradient shimmer effect.

✨ Key Features

Responsive UI: Fully adaptive design for various screen sizes and mobile orientations.

Shimmering AppBar Title: Utilizes an AnimatedBuilder and ShaderMask to create a dynamic, multi-color gradient shimmer on the title text.

Interactive Input: Allows users to select gender, adjust height via a slider, and modify weight/age using increment/decrement buttons.

Gradient Styling: Extensive use of LinearGradient for card backgrounds and action buttons to create a polished, visually appealing dark theme.

Result Interpretation: Provides a calculated BMI value, categorization (Underweight, Normal, Overweight, Obese), and practical health interpretations/recommendations.

Navigation: Uses named routes for clean transitions between the input and result screens.

📁 Project Structure

The core logic and UI components are organized within the lib directory:

bmi_calculator_app/
├── lib/
│   ├── models/
│   │   └── bmi_result.dart                # Defines the BMIResult data structure and category enum.
│   ├── screens/
│   │   ├── bmi_calculator_screen.dart     # Main screen for user input (gender, height, weight, age).
│   │   └── result_screen.dart             # Screen displaying the final BMI result and health interpretations.
│   ├── services/
│   │   └── bmi_calculator.dart            # Contains the core logic for BMI calculation (BMI = kg / (m^2)).
│   ├── utils/
│   │   └── constants.dart                 # Centralized file for all UI constants (colors, gradients, text styles).
│   └── widgets/
│       ├── animated_title.dart            # **NEW**: Reusable widget for the shimmering, gradient AppBar title effect.
│       ├── gender_card.dart               # Reusable card widget for selecting male/female gender.
│       └── result_recommendation_card.dart# Component for displaying actionable health recommendations.
└── ... (Standard Flutter files: main.dart, pubspec.yaml, etc.)


🎨 UI Implementation Highlights

Animated Title (lib/widgets/animated_title.dart)

The shimmering title effect is achieved by combining several Flutter concepts:

AnimationController: Drives the animation timing over a 4-second loop (repeat(reverse: true)).

Tween<double>: Maps the controller's value to a spatial translation range (e.g., -1.0 to 2.0).

ShaderMask: This is the key component. It takes a shaderCallback that uses the animated value to shift a wide LinearGradient (containing the kAnimatedGradientColors) across the bounding box of the title text. Since the text color is set to white, the gradient acts as a mask, revealing the shimmering effect.

Card Styling

All interactive cards and the main button use BoxDecoration with LinearGradient to provide depth and visual distinction between active (kGradient) and inactive (kInactiveCardGradient) states.