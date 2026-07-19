import 'package:flutter/material.dart';

class AuthBrandHeaderWidgets extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;

  const AuthBrandHeaderWidgets({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme =
        theme.colorScheme;

    return Column(
      children: <Widget>[
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
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
            boxShadow: <BoxShadow>[
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
            icon,
            size: 38,
            color: colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 21),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium
              ?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium
              ?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}