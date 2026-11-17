import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/services/session_service.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() {
    Timer(const Duration(milliseconds: 2600), () {
      if (SessionService.to.isLoggedIn) {
        Get.offNamed(AppRoutes.main);
      } else if (SessionService.to.isOnboardingDone.value) {
        Get.offNamed(AppRoutes.auth);
      } else {
        Get.offNamed(AppRoutes.onboarding);
      }
    });
  }
}
