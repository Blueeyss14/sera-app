import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../res/colors.dart';
import '../../../shared/widgets/floating_hearts.dart';
import '../models/onboarding_item.dart';

class OnboardingCard extends StatefulWidget {
  final OnboardingItem item;

  const OnboardingCard({
    super.key,
    required this.item,
  });

  @override
  State<OnboardingCard> createState() => _OnboardingCardState();
}

class _OnboardingCardState extends State<OnboardingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.05,
      child: Container(
        decoration: BoxDecoration(
          color: ColorValues.primary,
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: ColorValues.primary.withValues(alpha: 0.24),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Floating hearts if this is screen 1
              if (widget.item.hasFloatingHearts)
                const Positioned(
                  top: 24,
                  child: FloatingHearts(width: 190, height: 90),
                ),

              // Shadow platform below mascot
              Positioned(
                bottom: 34,
                child: Container(
                  width: 130,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              // Animated Mascot
              Positioned(
                bottom: 38,
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    final double dy = -6.0 * math.sin(_animController.value * math.pi);
                    return Transform.translate(
                      offset: Offset(0, dy),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    widget.item.image,
                    height: 175,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
