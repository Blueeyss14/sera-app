import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/api/api.dart';
import '../../../../core/models/patient_models.dart';
import '../../../../core/services/session_service.dart';
import '../../../../res/constant.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final RxBool isSignUp = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasAcceptedTerms = true.obs;
  final RxnString errorMessage = RxnString(null);

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_clearError);
    passwordController.addListener(_clearError);
    nameController.addListener(_clearError);
  }

  void _clearError() {
    if (errorMessage.value != null) {
      errorMessage.value = null;
    }
  }

  void toggleMode() {
    isSignUp.value = !isSignUp.value;
    errorMessage.value = null;
  }

  String _sanitizeEmail(String raw) {
    return raw
        .replaceAll(RegExp(r'[\s\u200B-\u200D\uFEFF]'), '')
        .trim()
        .toLowerCase();
  }

  bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _validate() {
    errorMessage.value = null;

    if (isSignUp.value) {
      if (nameController.text.trim().isEmpty) {
        errorMessage.value = AppStrings.nameRequired;
        return false;
      }
      if (!hasAcceptedTerms.value) {
        errorMessage.value = AppStrings.termsRequiredError;
        return false;
      }
    }

    final email = _sanitizeEmail(emailController.text);
    if (email.isEmpty) {
      errorMessage.value = AppStrings.emailRequired;
      return false;
    }
    if (!_isValidEmail(email)) {
      errorMessage.value = AppStrings.emailInvalid;
      return false;
    }

    final password = passwordController.text;
    if (password.isEmpty) {
      errorMessage.value = AppStrings.passwordRequired;
      return false;
    }
    if (password.length < 6) {
      errorMessage.value = AppStrings.passwordTooShort;
      return false;
    }

    return true;
  }

  Future<void> submit() async {
    if (!_validate()) return;

    isLoading.value = true;
    errorMessage.value = null;

    final email = _sanitizeEmail(emailController.text);
    final password = passwordController.text;

    try {
      AuthResponse res;
      if (isSignUp.value) {
        res = await ApiService.instance.registerPatient(
          name: nameController.text.trim(),
          email: email,
          password: password,
          hasAcceptedTerms: hasAcceptedTerms.value,
        );
      } else {
        res = await ApiService.instance.loginPatient(
          email: email,
          password: password,
        );
      }

      await SessionService.to.saveSession(res.user, res.token);
      Get.offAllNamed(AppRoutes.main);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> socialDemo() async {
    isLoading.value = true;
    try {
      final res = await ApiService.instance.loginPatient(
        email: 'takeshi.sato@gmail.com',
        password: 'password123',
      );
      await SessionService.to.saveSession(res.user, res.token);
      Get.offAllNamed(AppRoutes.main);
    } catch (_) {
      Get.offAllNamed(AppRoutes.main);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.removeListener(_clearError);
    passwordController.removeListener(_clearError);
    nameController.removeListener(_clearError);
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
