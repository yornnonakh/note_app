import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor:
      Theme.of(context).scaffoldBackgroundColor,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Stack(
          children: [
            const Positioned.fill(
              child: _LiquidLoginBackground(),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    32,
                    20,
                    32,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 440,
                    ),
                    child: const _LoginGlassCard(),
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

class _LoginGlassCard extends GetView<LoginController> {
  const _LoginGlassCard();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme =
        theme.colorScheme;
    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color cardColor = isDark
        ? const Color(0xFF1B1D22).withValues(
      alpha: 0.80,
    )
        : Colors.white.withValues(alpha: 0.76);

    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.86);

    return ClipRRect(
      borderRadius: BorderRadius.circular(34),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 28,
          sigmaY: 28,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            24,
            28,
            24,
            24,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: borderColor,
              width: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? 0.30 : 0.08,
                ),
                blurRadius: 40,
                offset: const Offset(0, 22),
              ),
              BoxShadow(
                color: colorScheme.primary.withValues(
                  alpha: isDark ? 0.08 : 0.05,
                ),
                blurRadius: 28,
                offset: const Offset(-10, -8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              const _LoginBrandHeader(),
              const SizedBox(height: 32),

              _LoginTextField(
                controller: controller.phoneController,
                label: 'Phone number',
                hintText: 'Enter your phone number',
                icon: CupertinoIcons.phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              Obx(
                    () => _LoginTextField(
                  controller:
                  controller.passwordController,
                  label: 'Password',
                  hintText: 'Enter your password',
                  icon: CupertinoIcons.lock,
                  obscureText:
                  controller.obscurePassword.value,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!controller.isLoading.value) {
                      controller.login();
                    }
                  },
                  suffix: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: controller
                        .togglePasswordVisibility,
                    child: Icon(
                      controller.obscurePassword.value
                          ? CupertinoIcons.eye
                          : CupertinoIcons.eye_slash,
                      size: 21,
                      color:
                      colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),

              Obx(() {
                final String error =
                controller.errorMessage.value.trim();

                if (error.isEmpty) {
                  return const SizedBox(height: 8);
                }

                return Padding(
                  padding: const EdgeInsets.only(
                    top: 14,
                  ),
                  child: _LoginErrorMessage(
                    message: error,
                  ),
                );
              }),

              const SizedBox(height: 20),

              Obx(
                    () => _SignInButton(
                  isLoading:
                  controller.isLoading.value,
                  onPressed: controller.login,
                ),
              ),

              const SizedBox(height: 22),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.lock_shield,
                    size: 15,
                    color:
                    colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Your account is securely protected',
                    style:
                    theme.textTheme.bodySmall?.copyWith(
                      color:
                      colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginBrandHeader extends StatelessWidget {
  const _LoginBrandHeader();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme =
        theme.colorScheme;

    return Column(
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.primary.withValues(
                  alpha: 0.72,
                ),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.32,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(
                  alpha: 0.30,
                ),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            CupertinoIcons.doc_text_fill,
            size: 39,
            color: colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Piisiit Note',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Welcome back',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sign in to access and manage your notes.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;

  const _LoginTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.suffix,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme =
        theme.colorScheme;
    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color fieldColor = isDark
        ? Colors.white.withValues(alpha: 0.055)
        : Colors.white.withValues(alpha: 0.74);

    final Color borderColor =
    colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.24 : 0.46,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 4,
            bottom: 8,
          ),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: fieldColor,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: borderColor,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.025,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: obscureText
                ? const [AutofillHints.password]
                : const [AutofillHints.telephoneNumber],
            onSubmitted: onSubmitted,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle:
              theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.70),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 12,
                ),
                child: Icon(
                  icon,
                  size: 21,
                  color: colorScheme.primary,
                ),
              ),
              prefixIconConstraints:
              const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
              suffixIcon: suffix == null
                  ? null
                  : Padding(
                padding: const EdgeInsets.only(
                  right: 8,
                ),
                child: suffix,
              ),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginErrorMessage extends StatelessWidget {
  final String message;

  const _LoginErrorMessage({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme =
        theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(
          alpha: 0.74,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.error.withValues(
            alpha: 0.20,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_circle,
            size: 20,
            color: colorScheme.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SignInButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme =
        theme.colorScheme;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 220,
        ),
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isLoading
              ? colorScheme.primary.withValues(
            alpha: 0.60,
          )
              : colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(
              alpha: 0.18,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(
                alpha: isLoading ? 0.12 : 0.30,
              ),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(
              milliseconds: 180,
            ),
            child: isLoading
                ? SizedBox(
              key: const ValueKey('loading'),
              width: 23,
              height: 23,
              child:
              CircularProgressIndicator.adaptive(
                strokeWidth: 2.2,
                valueColor:
                AlwaysStoppedAnimation<Color>(
                  colorScheme.onPrimary,
                ),
              ),
            )
                : Row(
              key: const ValueKey('sign-in'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sign In',
                  style: theme
                      .textTheme.titleMedium
                      ?.copyWith(
                    color:
                    colorScheme.onPrimary,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 9),
                Icon(
                  CupertinoIcons.arrow_right,
                  size: 18,
                  color: colorScheme.onPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiquidLoginBackground extends StatelessWidget {
  const _LiquidLoginBackground();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme =
        theme.colorScheme;
    final bool isDark =
        theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.scaffoldBackgroundColor,
            Color.alphaBlend(
              colorScheme.primary.withValues(
                alpha: isDark ? 0.14 : 0.07,
              ),
              theme.scaffoldBackgroundColor,
            ),
            Color.alphaBlend(
              colorScheme.secondary.withValues(
                alpha: isDark ? 0.10 : 0.045,
              ),
              theme.scaffoldBackgroundColor,
            ),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -130,
            right: -100,
            child: _LoginAmbientOrb(
              size: 330,
              color: colorScheme.primary.withValues(
                alpha: isDark ? 0.18 : 0.11,
              ),
            ),
          ),
          Positioned(
            top: 280,
            left: -140,
            child: _LoginAmbientOrb(
              size: 300,
              color: colorScheme.secondary.withValues(
                alpha: isDark ? 0.14 : 0.075,
              ),
            ),
          ),
          Positioned(
            bottom: -160,
            right: -110,
            child: _LoginAmbientOrb(
              size: 360,
              color: colorScheme.tertiary.withValues(
                alpha: isDark ? 0.13 : 0.065,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginAmbientOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _LoginAmbientOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}