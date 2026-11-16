import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../res/colors.dart';
import '../../../../res/constant.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/brand_logo.dart';
import '../../../shared/widgets/social_login_buttons.dart';
import '../controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorValues.primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Blue Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.chevron_left_rounded,
                            color: ColorValues.primaryForeground,
                            size: 24,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppStrings.back,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: ColorValues.primaryForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Brand Logo in inverted/white style
                  const BrandLogo(
                    size: BrandLogoSize.lg,
                    isInverted: true,
                  ),
                  const SizedBox(height: 10),

                  // Header greeting
                  Text(
                    AppStrings.authHeaderTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: ColorValues.primaryForeground,
                      letterSpacing: -0.4,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.authHeaderSubtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: ColorValues.primaryForeground.withValues(alpha: 0.82),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),

            // White Sheet Container for Form
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: ColorValues.card,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                    child: Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Form Title & Subtitle
                          Text(
                            controller.isSignUp.value
                                ? AppStrings.signUpTitle
                                : AppStrings.signInTitle,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: ColorValues.foreground,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.isSignUp.value
                                ? AppStrings.signUpSubtitle
                                : AppStrings.signInSubtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: ColorValues.mutedForeground,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Error Banner
                          if (controller.errorMessage.value != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: ColorValues.destructiveLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: ColorValues.destructive.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: ColorValues.destructive,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      controller.errorMessage.value!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: ColorValues.destructive,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Name field (Sign Up only)
                          if (controller.isSignUp.value) ...[
                            AppTextField(
                              label: AppStrings.nameLabel,
                              placeholder: AppStrings.namePlaceholder,
                              controller: controller.nameController,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Email field
                          AppTextField(
                            label: AppStrings.emailLabel,
                            placeholder: AppStrings.emailPlaceholder,
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // Password field
                          AppTextField(
                            label: AppStrings.passwordLabel,
                            placeholder: AppStrings.passwordPlaceholder,
                            controller: controller.passwordController,
                            isPassword: true,
                          ),
                          const SizedBox(height: 14),

                          // Terms agreement (Sign Up only)
                          if (controller.isSignUp.value) ...[
                            InkWell(
                              onTap: () {
                                controller.hasAcceptedTerms.value =
                                    !controller.hasAcceptedTerms.value;
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: controller.hasAcceptedTerms.value,
                                        onChanged: (val) {
                                          controller.hasAcceptedTerms.value = val ?? false;
                                        },
                                        activeColor: ColorValues.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        AppStrings.termsAgreement,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w400,
                                          color: ColorValues.mutedForeground,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                          ] else ...[
                            const SizedBox(height: 10),
                          ],

                          // Submit Button
                          AppButton(
                            text: controller.isSignUp.value
                                ? AppStrings.signUp
                                : AppStrings.signIn,
                            isLoading: controller.isLoading.value,
                            onPressed: controller.submit,
                          ),
                          const SizedBox(height: 24),

                          // Divider
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: ColorValues.border, thickness: 1),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  AppStrings.orContinueWith,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: ColorValues.mutedForeground,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: ColorValues.border, thickness: 1),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Social Login Buttons
                          SocialLoginButtons(
                            onGooglePressed: controller.socialDemo,
                            onFacebookPressed: controller.socialDemo,
                            onApplePressed: controller.socialDemo,
                          ),
                          const SizedBox(height: 24),

                          // Mode Switch (Sign In <-> Sign Up)
                          Center(
                            child: InkWell(
                              onTap: controller.toggleMode,
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: RichText(
                                  text: TextSpan(
                                    text: controller.isSignUp.value
                                        ? AppStrings.haveAccountPrompt
                                        : AppStrings.noAccountPrompt,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w400,
                                      color: ColorValues.mutedForeground,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: controller.isSignUp.value
                                            ? AppStrings.signInNow
                                            : AppStrings.registerNow,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: ColorValues.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

