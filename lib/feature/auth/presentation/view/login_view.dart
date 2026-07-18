import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constroller/login_constroller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color cardColor = isDark
        ? const Color(0xFF1B1D22)
        : Colors.white;

    final Color borderColor =
    colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.18 : 0.35,
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: 440,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: borderColor,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.note_alt_rounded,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Piisiit Note',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to manage your notes',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(
                      color:
                      colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller:
                    controller.phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                        () => TextField(
                      controller:
                      controller.passwordController,
                      obscureText:
                      controller.obscurePassword.value,
                      onSubmitted: (_) =>
                          controller.login(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon:
                        const Icon(Icons.lock_outline),
                        border:
                        const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: controller
                              .togglePasswordVisibility,
                          icon: Icon(
                            controller
                                .obscurePassword.value
                                ? Icons.visibility_outlined
                                : Icons
                                .visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (controller
                        .errorMessage.value.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding:
                      const EdgeInsets.only(bottom: 12),
                      child: Text(
                        controller.errorMessage.value,
                        style: TextStyle(
                          color: colorScheme.error,
                        ),
                      ),
                    );
                  }),
                  Obx(
                        () => FilledButton(
                      onPressed:
                      controller.isLoading.value
                          ? null
                          : controller.login,
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : const Text('Sign In'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}