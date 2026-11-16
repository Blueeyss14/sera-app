import 'package:flutter/material.dart';
import '../../../../res/colors.dart';

class OnboardingIndicator extends StatelessWidget {
  final int currentIndex;
  final int count;

  const OnboardingIndicator({
    super.key,
    required this.currentIndex,
    this.count = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final bool isFilled = index <= currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 72,
          height: 4.5,
          decoration: BoxDecoration(
            color: isFilled ? ColorValues.primary : const Color(0xFFD6E8FD),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

