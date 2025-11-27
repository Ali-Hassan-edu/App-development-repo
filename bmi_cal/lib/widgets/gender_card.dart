import 'package:flutter/material.dart';
import '../utils/constants.dart';

enum Gender { male, female }

class GenderCard extends StatelessWidget {
  const GenderCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          // Use the gradient for the background
          gradient: kInactiveCardGradient,
          borderRadius: BorderRadius.circular(15.0),
          // Add a subtle border glow if selected
          border: isSelected
              ? Border.all(color: kAccentBlue, width: 3.0)
              : Border.all(color: Colors.transparent, width: 3.0),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: kAccentPurple.withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 80.0,
              color: isSelected ? Colors.white : const Color(0xFF8D8E98),
            ),
            const SizedBox(height: 15.0),
            Text(
              label,
              style: isSelected
                  ? kLabelTextStyle.copyWith(color: Colors.white)
                  : kLabelTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}