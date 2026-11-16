import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../res/assets.dart';
import '../../../../res/colors.dart';
import '../../../../res/constant.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/brand_logo.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorValues.background,
      appBar: AppBar(
        backgroundColor: ColorValues.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const BrandLogo(size: BrandLogoSize.sm),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: ColorValues.border, height: 1),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: ColorValues.primaryLight,
                  borderRadius: BorderRadius.circular(32),
                ),
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  ImageAssets.seraHappy,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.homePlaceholderTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ColorValues.foreground,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.homePlaceholderSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: ColorValues.mutedForeground,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),
              AppButton(
                text: 'Sign Out',
                isOutlined: true,
                onPressed: controller.signOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

