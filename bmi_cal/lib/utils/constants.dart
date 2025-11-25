import 'package:flutter/material.dart';

// --- Colors ---

// Primary dark background color
const kPrimaryColor = Color(0xFF0C1032);
// The darker card background used in the UI
const kCardColor = Color(0xFF1D1F33);
// Accent color 1 (Blue/Cyan for gradient)
const kAccentBlue = Color(0xFF00C6FF);
// Accent color 2 (Purple/Magenta for gradient)
const kAccentPurple = Color(0xFF0072FF);
// Light text color
const kTextColor = Color(0xFFFFFFFF);
// The green color for the "NORMAL" result
const kNormalResultColor = Color(0xFF24D876);
// The red color for the "RE-CALCULATE" button
const kRecalculateButtonColor = Color(0xFFEB1555);

// Gradient used for buttons and selected cards
const kGradient = LinearGradient(
  colors: [kAccentBlue, kAccentPurple],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Gradient used for unselected/default cards
const kInactiveCardGradient = LinearGradient(
  colors: [Color(0xFF222649), Color(0xFF1D1F33)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);


// --- Text Styles ---

// Style for screen title (e.g., 'BMI Calculator')
const kTitleTextStyle = TextStyle(
  fontSize: 24.0,
  fontWeight: FontWeight.bold,
  color: kTextColor,
);

// Style for big numbers (e.g., 175 cm, 70 kg, 30 yrs)
const kNumberTextStyle = TextStyle(
  fontSize: 48.0,
  fontWeight: FontWeight.w900,
  color: kTextColor,
);

// Style for small labels (e.g., 'Height', 'cm', 'kg')
const kLabelTextStyle = TextStyle(
  fontSize: 16.0,
  color: Color(0xFF8D8E98),
);

// Style for the main BMI result number (e.g., 24.5)
const kResultBMITextStyle = TextStyle(
  fontSize: 100.0,
  fontWeight: FontWeight.bold,
  color: kTextColor,
);

// Style for the result category text (e.g., 'NORMAL')
const kResultTextStyle = TextStyle(
  color: kNormalResultColor,
  fontSize: 22.0,
  fontWeight: FontWeight.bold,
);

// Style for the recommendation interpretation text
const kBodyTextStyle = TextStyle(
  fontSize: 18.0,
  color: kTextColor,
  height: 1.5,
);

// Style for the main button (e.g., 'CALCULATE BMI')
const kBottomButtonTextStyle = TextStyle(
  fontSize: 25.0,
  fontWeight: FontWeight.bold,
  color: kTextColor,
);

// --- Layout & Dimensions ---

const kBottomContainerHeight = 80.0;