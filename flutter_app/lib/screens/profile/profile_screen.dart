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
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: MridaColors.surface,
      body: CustomScrollView(
        slivers: [
          // Cinematic Profile Header
          SliverToBoxAdapter(
            child: Container(
              height: 340,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/demo/profile_hero.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'RK',
                        style: theme.textTheme.displayLarge?.copyWith(fontSize: 32, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'RAJAN KUMAR',
                      style: theme.textTheme.displayLarge?.copyWith(color: Colors.white, fontSize: 32),
                    ),
                    Text(
                      '+91 98765 43210',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // High-Contrast Bento Stats
                Row(
                  children: [
                    _buildBentoStat('12', 'SCANS', theme),
                    const SizedBox(width: 12),
                    _buildBentoStat('3', 'FIELDS', theme),
                    const SizedBox(width: 12),
                    _buildBentoStat('4', 'CROPS', theme),
                  ],
                ),
                const SizedBox(height: 32),

                // Preferences
                Text('PREFERENCES', style: theme.textTheme.labelLarge),
                const SizedBox(height: 16),
                _buildSettingsGroup([
                  _buildSettingsTile(Icons.language, 'Language', trailing: 'Hindi (IN)'),
                  _buildSettingsTile(Icons.notifications_none, 'Notifications', hasSwitch: true),
                ]),
                const SizedBox(height: 32),

                // My Farm
                Text('MY FARM', style: theme.textTheme.labelLarge),
                const SizedBox(height: 16),
                _buildSettingsGroup([
                  _buildSettingsTile(Icons.map_outlined, 'Manage Fields', hasChevron: true),
                  _buildSettingsTile(Icons.history, 'Full Scan History', hasChevron: true),
                ]),
                const SizedBox(height: 48),

                // Sign Out
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: MridaColors.gradeD),
                  child: Text(
                    'SECURE SIGN OUT',
                    style: theme.textTheme.labelLarge?.copyWith(color: MridaColors.gradeD),
                  ),
                ),
                const SizedBox(height: 120),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoStat(String value, String label, ThemeData theme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: MridaColors.outline.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.displayMedium?.copyWith(color: MridaColors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MridaColors.outline.withValues(alpha: 0.1)),
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
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(icon, color: MridaColors.primary.withValues(alpha: 0.4), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
            ),
          ),
          if (trailing != null)
            Text(
              trailing,
              style: TextStyle(color: MridaColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          if (hasSwitch) Switch(value: true, onChanged: (_) {}),
          if (hasChevron) const Icon(Icons.chevron_right, size: 16, color: MridaColors.outlineVariant),
        ],
      ),
    );
  }
}
