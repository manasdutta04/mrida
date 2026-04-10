import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class UniversalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UniversalAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: MridaColors.surface,
      elevation: 0,
      centerTitle: false,
      primary: false,
      leading: context.canPop()
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: MridaColors.primary),
              onPressed: () => context.pop(),
            )
          : null,
      title: Text(
        'MRIDA',
        style: GoogleFonts.sora(
          fontWeight: FontWeight.w900,
          letterSpacing: -1.5,
          fontSize: 24,
          color: MridaColors.primary,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: MridaColors.primary),
          onPressed: () {
            // For now, settings opens the profile tab
            GoRouter.of(context).go('/profile');
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
