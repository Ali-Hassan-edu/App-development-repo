import 'package:flutter/material.dart';
import '../utils/constants.dart';

// Reusable widget for the animated AppBar title with shimmering gradient.
class AnimatedTitle extends StatelessWidget {
  const AnimatedTitle({
    super.key,
    required this.text,
    required this.animation,
  });

  final String text;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Create a linear gradient with a wide range of colors for the shimmer.
        final gradient = LinearGradient(
          colors: kAnimatedGradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // Use TileMode.mirror to ensure the gradient repeats smoothly
          tileMode: TileMode.mirror,
        );

        return ShaderMask(
          shaderCallback: (bounds) {
            // Calculate the position of the shimmering effect based on the animation value.
            // The bounds.width * 2 ensures the gradient is twice the size of the text
            // bounding box.
            // The animation.value translates the gradient horizontally from -1.0 to 2.0.
            final double xOffset = animation.value * bounds.width * 2;

            return gradient.createShader(
              // The shader is translated horizontally using the xOffset.
              Rect.fromLTWH(-xOffset, 0, bounds.width * 2, bounds.height),
            );
          },
          child: Text(
            text,
            // Use the kTitleTextStyle which has kTextColor (white) defined.
            // This color acts as the 'base' color that the ShaderMask
            // gradient is applied over, making the shimmer visible.
            style: kTitleTextStyle,
          ),
        );
      },
    );
  }
}