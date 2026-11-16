import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../res/colors.dart';
import '../../../../res/constant.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/brand_logo.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/onboarding_card.dart';
import '../widgets/onboarding_indicator.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorValues.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar with Brand Logo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: const BoxDecoration(
                color: ColorValues.background,
                border: Border(
                  bottom: BorderSide(
                    color: ColorValues.border,
                    width: 1,
                  ),
                ),
              ),
              child: const BrandLogo(
                size: BrandLogoSize.sm,
                isInverted: false,
              ),
            ),

            // Page View with Card and Text
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.items.length,
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),
                        OnboardingCard(item: item),
                        const SizedBox(height: 28),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: ColorValues.foreground,
                            letterSpacing: -0.5,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            item.description,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: ColorValues.mutedForeground,
                              height: 1.55,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Buttons & Progress Indicator
            Obx(
              () => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Main Action (Next / Get Started)
                    AppButton(
                      text: controller.isLastPage
                          ? AppStrings.getStarted
                          : AppStrings.next,
                      onPressed: controller.nextPage,
                    ),

                    // Back Button (Animated appearance to prevent layout shift)
                    SizedBox(
                      height: 44,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: controller.canGoBack ? 1.0 : 0.0,
                        child: TextButton(
                          onPressed: controller.canGoBack
                              ? controller.previousPage
                              : null,
                          style: TextButton.styleFrom(
                            foregroundColor: ColorValues.foreground,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Text(
                            AppStrings.back,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: ColorValues.foreground,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 3-Bar Indicator
                    OnboardingIndicator(
                      currentIndex: controller.currentIndex.value,
                      count: controller.items.length,
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

