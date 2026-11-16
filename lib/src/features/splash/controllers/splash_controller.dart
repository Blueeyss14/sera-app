import 'dart:async';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() {
    Timer(const Duration(milliseconds: 2800), () {
      Get.offNamed(AppRoutes.onboarding);
    });
  }
}

