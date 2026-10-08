import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.themeIsDark,
      builder: (context, isDark, _) {
        return GestureDetector(
          onTap: AppColors.toggleTheme,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceAlt,
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) => RotationTransition(
                  turns: Tween<double>(begin: 0.7, end: 1).animate(animation),
                  child: ScaleTransition(scale: animation, child: child),
                ),
                child: Icon(
                  isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  key: ValueKey<bool>(isDark),
                  color: AppColors.accent,
                  size: 18,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
