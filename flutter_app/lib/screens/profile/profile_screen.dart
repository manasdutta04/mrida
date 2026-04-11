import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: MridaColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        child: Column(
          children: [
            // User Avatar & Name
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: MridaColors.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'RK',
                      style: GoogleFonts.sora(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rajan Kumar',
                    style: GoogleFonts.sora(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: MridaColors.onSurface,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '+91 98765 43210',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: MridaColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '·',
                        style: TextStyle(color: MridaColors.onSurfaceVariant),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Edit',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: MridaColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Stats row: 3 metric cards
            Row(
              children: [
                _buildStatCard('12', 'SCANS'),
                const SizedBox(width: 12),
                _buildStatCard('3', 'FIELDS'),
                const SizedBox(width: 12),
                _buildStatCard('4', 'CROPS'),
              ],
            ),
            const SizedBox(height: 32),

            // Preferences Section
            _buildSectionHeader('PREFERENCES'),
            const SizedBox(height: 12),
            _buildSettingsGroup([
              _buildSettingsTile(Icons.language, 'Language', trailing: 'Hindi (IN)'),
              _buildSettingsTile(Icons.notifications_none, 'Notifications', hasSwitch: true),
              _buildSettingsTile(Icons.eco_outlined, 'Default Crop', trailing: 'Rice (Paddy)'),
            ]),
            const SizedBox(height: 24),

            // My Farm Section
            _buildSectionHeader('MY FARM'),
            const SizedBox(height: 12),
            _buildSettingsGroup([
              _buildSettingsTile(Icons.map_outlined, 'Manage Fields', hasChevron: true),
              _buildSettingsTile(Icons.history, 'Full Scan History', hasChevron: true),
            ]),
            const SizedBox(height: 24),

            // Support Section
            _buildSectionHeader('SUPPORT'),
            const SizedBox(height: 12),
            _buildSettingsGroup([
              _buildSettingsTile(Icons.info_outline, 'About MRIDA', hasChevron: true),
              _buildSettingsTile(Icons.star_outline, 'Rate the App', hasChevron: true),
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


  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              offset: const Offset(0, 4),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.sora(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: MridaColors.primary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: MridaColors.onSurfaceVariant,
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
  }) {
    return InkWell(
      onTap: () {},
      child: Container(
        height: 56, // 56px tap height as requested
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: MridaColors.primary, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: MridaColors.onSurface,
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
