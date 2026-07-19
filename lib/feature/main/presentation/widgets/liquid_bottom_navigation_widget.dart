import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LiquidBottomNavigationWidget
    extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const LiquidBottomNavigationWidget({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme =
        theme.colorScheme;

    final bool isDark =
        theme.brightness == Brightness.dark;

    final Color backgroundColor = isDark
        ? const Color(0xFF1B1D22).withValues(
      alpha: 0.86,
    )
        : Colors.white.withValues(alpha: 0.80);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 26,
            sigmaY: 26,
          ),
          child: Container(
            height: 72,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius:
              BorderRadius.circular(28),
              border: Border.all(
                color: colorScheme.outlineVariant
                    .withValues(
                  alpha: isDark ? 0.22 : 0.38,
                ),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha:
                    isDark ? 0.28 : 0.09,
                  ),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _NavigationItem(
                    index: 0,
                    label: 'folders'.tr,
                    icon: CupertinoIcons.folder,
                    selectedIcon:
                    CupertinoIcons.folder_fill,
                    selectedIndex: selectedIndex,
                    onChanged: onChanged,
                  ),
                ),
                Expanded(
                  child: _NavigationItem(
                    index: 1,
                    label: 'notes'.tr,
                    icon: CupertinoIcons.doc_text,
                    selectedIcon:
                    CupertinoIcons.doc_text_fill,
                    selectedIndex: selectedIndex,
                    onChanged: onChanged,
                  ),
                ),
                Expanded(
                  child: _NavigationItem(
                    index: 2,
                    label: 'settings'.tr,
                    icon: CupertinoIcons.gear,
                    selectedIcon:
                    CupertinoIcons.gear,
                    selectedIndex: selectedIndex,
                    onChanged: onChanged,
                  ),
                ),
                Expanded(
                  child: _NavigationItem(
                    index: 3,
                    label: 'profile'.tr,
                    icon: CupertinoIcons.person,
                    selectedIcon:
                    CupertinoIcons.person_fill,
                    selectedIndex: selectedIndex,
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final ValueChanged<int> onChanged;

  const _NavigationItem({
    required this.index,
    required this.selectedIndex,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme =
        theme.colorScheme;

    final bool selected =
        index == selectedIndex;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        onChanged(index);
      },
      child: AnimatedContainer(
        duration:
        const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: 57,
        margin: const EdgeInsets.symmetric(
          horizontal: 2,
        ),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withValues(
            alpha: 0.14,
          )
              : Colors.transparent,
          borderRadius: BorderRadius.circular(21),
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: <Widget>[
            AnimatedSwitcher(
              duration:
              const Duration(milliseconds: 180),
              child: Icon(
                selected
                    ? selectedIcon
                    : icon,
                key: ValueKey<bool>(selected),
                size: 21,
                color: selected
                    ? colorScheme.primary
                    : colorScheme
                    .onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
              theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: selected
                    ? colorScheme.primary
                    : colorScheme
                    .onSurfaceVariant,
                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}