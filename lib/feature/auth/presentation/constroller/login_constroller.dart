import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../domain/repositories/auth_repository.dart';

class LoginController extends GetxController {
  final AuthRepository authRepository;

  LoginController({
    required this.authRepository,
  });

  final TextEditingController phoneController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxString errorMessage = ''.obs;

  Future<void> login() async {
    final String phone =
    phoneController.text.trim();

    final String password =
    passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      errorMessage.value =
      'Phone number and password are required.';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      await authRepository.login(
        phone: phone,
        password: password,
      );

      Get.offAllNamed(AppRoutes.home);
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void togglePasswordVisibility() {
    obscurePassword.toggle();
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}