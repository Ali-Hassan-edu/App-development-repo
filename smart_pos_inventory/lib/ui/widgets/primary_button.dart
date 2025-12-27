import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final List<Color>? gradient;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradient ?? [
      const Color(0xFF6D5DF6),
      const Color(0xFF3CC5FF),
    ];

    return SizedBox(
      height: 54,
      width: double.infinity,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: loading ? null : onPressed,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(colors: colors),
            boxShadow: [
              BoxShadow(
                color: colors.last.withOpacity(.25),
                blurRadius: 18,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Center(
            child: loading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: .2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
