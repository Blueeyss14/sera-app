import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../res/assets.dart';
import '../../../../res/colors.dart';
import '../../../../res/constant.dart';
import '../../../shared/widgets/brand_logo.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // ensure controller is initialized
    controller;

    return Scaffold(
      backgroundColor: ColorValues.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Mascot Card with subtle float animation
              const _SplashMascotCard(),
              const SizedBox(height: 28),

              // Brand Logo in inverted/white style
              const BrandLogo(
                size: BrandLogoSize.lg,
                isInverted: true,
              ),
              const SizedBox(height: 10),

              // Tagline
              Text(
                AppStrings.splashTagline,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: ColorValues.primaryForeground.withValues(alpha: 0.85),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashMascotCard extends StatefulWidget {
  const _SplashMascotCard();

  @override
  State<_SplashMascotCard> createState() => _SplashMascotCardState();
}

class _SplashMascotCardState extends State<_SplashMascotCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final double dy = -7.0 * math.sin(_animController.value * math.pi);
        return Transform.translate(
          offset: Offset(0, dy),
          child: child,
        );
      },
      child: Container(
        width: 136,
        height: 136,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1.2,
          ),
        ),
        padding: const EdgeInsets.all(22),
        child: Image.asset(
          ImageAssets.seraGreeting,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
