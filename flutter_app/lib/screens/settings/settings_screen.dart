import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/universal_app_bar.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: MridaColors.surface,
      appBar: UniversalAppBar(title: 'PREFERENCES', showSettings: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const SizedBox(height: 12),
            _buildSettingsGroup([
              _buildSettingsTile(Icons.language, 'Language', trailing: 'Hindi (IN)'),
              _buildSettingsTile(Icons.notifications_none, 'Notifications', hasSwitch: true),
              _buildSettingsTile(Icons.eco_outlined, 'Default Crop', trailing: 'Rice (Paddy)'),
              _buildSettingsTile(Icons.straighten_outlined, 'Measurement Units', trailing: 'Metric (kg, m)'),
            ]),
            const SizedBox(height: 32),

            _buildSectionHeader('SUPPORT'),
            const SizedBox(height: 12),
            _buildSettingsGroup([
              _buildSettingsTile(Icons.info_outline, 'About MRIDA', hasChevron: true, onTap: () => context.push('/settings/about')),
              _buildSettingsTile(Icons.help_outline, 'Help Center', hasChevron: true, onTap: () => context.push('/settings/help')),
              _buildSettingsTile(Icons.description_outlined, 'Terms of Service', hasChevron: true, onTap: () => context.push('/settings/terms')),
              _buildSettingsTile(Icons.privacy_tip_outlined, 'Privacy Policy', hasChevron: true, onTap: () => context.push('/settings/privacy')),
            ]),
            const SizedBox(height: 32),

            _buildSectionHeader('ACCOUNT'),
            const SizedBox(height: 12),
            _buildSettingsGroup([
              _buildSettingsTile(Icons.delete_outline, 'Delete Account', color: MridaColors.gradeD),
            ]),
            const SizedBox(height: 48),

            // Sign Out
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  try {
                    await ref.read(authServiceProvider).signOut();
                    if (context.mounted) {
                      context.go('/welcome');
                    }
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Unable to sign out. Please try again.'),
                        ),
                      );
                    }
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: MridaColors.gradeD,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Sign Out',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.0,
          color: MridaColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
  Widget _buildSettingsTile(
    IconData icon,
    String title, {
    String? trailing,
    bool hasSwitch = false,
    bool hasChevron = false,
    Color? color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: color ?? MridaColors.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                   fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color ?? MridaColors.onSurface,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: MridaColors.primary,
                ),
              ),
            if (hasSwitch)
              Switch(
                value: true,
                onChanged: (_) {},
                activeThumbColor: MridaColors.primary,
              ),
            if (hasChevron)
              const Icon(Icons.chevron_right, color: MridaColors.outlineVariant),
          ],
        ),
      ),
    );
  }
}
