import 'package:flutter/material.dart';
import '../utils/constants.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Custom Icon with a subtle circle background
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kAccentBlue.withOpacity(0.5), width: 1.0),
            ),
            child: Icon(
              icon,
              size: 28.0,
              color: kAccentBlue,
            ),
          ),
          const SizedBox(width: 20.0),
          // Title and Subtitle text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: kBodyTextStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  subtitle,
                  style: kLabelTextStyle.copyWith(
                    fontSize: 14,
                    color: const Color(0xFFCCCCCC),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}