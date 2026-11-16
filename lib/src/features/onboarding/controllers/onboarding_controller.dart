import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../res/assets.dart';
import '../../../../res/constant.dart';
import '../../../routes/app_routes.dart';
import '../models/onboarding_item.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentIndex = 0.obs;

  final List<OnboardingItem> items = const [
    OnboardingItem(
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDesc1,
      image: ImageAssets.seraGreeting,
      hasFloatingHearts: true,
    ),
    OnboardingItem(
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDesc2,
      image: ImageAssets.seraClipboard,
      hasFloatingHearts: false,
    ),
    OnboardingItem(
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDesc3,
      image: ImageAssets.seraExcited,
      hasFloatingHearts: false,
    ),
  ];

  bool get isLastPage => currentIndex.value == items.length - 1;
  bool get canGoBack => currentIndex.value > 0;

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  void nextPage() {
    if (currentIndex.value < items.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Get.toNamed(AppRoutes.auth);
    }
  }

  void previousPage() {
    if (currentIndex.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

