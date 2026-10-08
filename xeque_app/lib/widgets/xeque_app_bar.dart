import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'organizer_lock_button.dart';
import 'theme_toggle_button.dart';

class XequeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const XequeAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accent, width: 1.4),
                color: AppColors.accentBackground,
              ),
              child: Icon(Icons.extension_rounded, color: AppColors.accent, size: 16),
            ),
            const SizedBox(width: 10),
            Text(title, style: AppTextStyles.logo),
            const Spacer(),
            const OrganizerLockButton(),
            const SizedBox(width: 10),
            const ThemeToggleButton(),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
