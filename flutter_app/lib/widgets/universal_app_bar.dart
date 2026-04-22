import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class UniversalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showSettings;

  const UniversalAppBar({
    super.key,
    this.title,
    this.showSettings = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.canPop(context);
    return AppBar(
      backgroundColor: MridaColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      primary: true,
      leading: canPop
          ? Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: MridaColors.primary, size: 20),
                onPressed: () => context.pop(),
              ),
            )
          : null,
      titleSpacing: canPop ? 0 : 24,
      title: Text(
        title ?? 'MRIDA',
        style: GoogleFonts.sora(
          fontWeight: FontWeight.w900,
          letterSpacing: title == null ? -1.5 : 0,
          fontSize: title == null ? 24 : 18,
          color: MridaColors.primary,
        ),
      ),
      actions: [
        if (showSettings) ...[
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: MridaColors.primary),
            onPressed: () {
              context.push('/settings');
            },
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }
}
