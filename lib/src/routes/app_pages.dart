import 'package:get/get.dart';

import '../features/onboarding/bindings/onboarding_binding.dart';
import '../features/onboarding/views/onboarding_view.dart';
import '../features/splash/bindings/splash_binding.dart';
import '../features/splash/views/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const String initial = AppRoutes.splash;

  static final List<GetPage<dynamic>> routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}

