import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_provider.dart';
import '../../providers/field_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_profile.dart';
import '../../theme/app_theme.dart';
import '../../widgets/universal_app_bar.dart';

const _languageOptions = {
  'en': 'English',
  'hi': 'Hindi',
  'bn': 'Bengali',
  'ta': 'Tamil',
  'te': 'Telugu',
  'mr': 'Marathi',
};

String _themeModeLabel(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.dark:
      return 'Dark';
    case ThemeMode.system:
      return 'System';
    case ThemeMode.light:
    default:
      return 'Light';
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final languageCode = profile?.languageCode ?? 'en';
    final themeMode = ref.watch(appThemeModeProvider);
    final units = ref.watch(measurementUnitsProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final offlineAccess = ref.watch(offlineAccessProvider);

    return Scaffold(
      backgroundColor: MridaColors.surface,
      appBar: const UniversalAppBar(title: 'SETTINGS', showSettings: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildProfileCard(profile, languageCode, themeMode),
            const SizedBox(height: 24),
            _buildSectionHeader('APP PREFERENCES'),
            const SizedBox(height: 12),
            _buildSettingsGroup([
              _buildSettingsTile(
                Icons.language,
                'Language',
                trailing: _languageOptions[languageCode] ?? 'English',
                onTap: () => _showLanguageSheet(context, ref, languageCode),
              ),
              _buildSettingsTile(
                Icons.dark_mode_outlined,
                'App Theme',
                trailing: _themeModeLabel(themeMode),
                onTap: () => _showThemeSheet(context, ref, themeMode),
              ),
              _buildSettingsTile(
                Icons.straighten_outlined,
                'Measurement Units',
                trailing: units,
                onTap: () => _showUnitSheet(context, ref, units),
              ),
              _buildSettingsTile(
                Icons.notifications_none,
                'Notifications',
                hasSwitch: true,
                switchValue: notificationsEnabled,
                onSwitchChanged: (value) => ref
                    .read(notificationsEnabledProvider.notifier)
                    .setEnabled(value),
              ),
              _buildSettingsTile(
                Icons.cloud_download_outlined,
                'Offline Access',
                hasSwitch: true,
                switchValue: offlineAccess,
                onSwitchChanged: (value) =>
                    ref.read(offlineAccessProvider.notifier).setEnabled(value),
              ),
            ]),
            const SizedBox(height: 32),
            _buildSectionHeader('SUPPORT'),
            const SizedBox(height: 12),
            _buildSettingsGroup([
              _buildSettingsTile(
                Icons.info_outline,
                'About MRIDA',
                hasChevron: true,
                onTap: () => context.push('/settings/about'),
              ),
              _buildSettingsTile(
                Icons.help_outline,
                'Help Center',
                hasChevron: true,
                onTap: () => context.push('/settings/help'),
              ),
              _buildSettingsTile(
                Icons.description_outlined,
                'Terms of Service',
                hasChevron: true,
                onTap: () => context.push('/settings/terms'),
              ),
              _buildSettingsTile(
                Icons.privacy_tip_outlined,
                'Privacy Policy',
                hasChevron: true,
                onTap: () => context.push('/settings/privacy'),
              ),
            ]),
            const SizedBox(height: 32),
            _buildSectionHeader('ACCOUNT'),
            const SizedBox(height: 12),
            _buildSettingsGroup([
              _buildSettingsTile(
                Icons.delete_outline,
                'Delete Account',
                color: MridaColors.gradeD,
                onTap: () => _showDeleteAccountNotice(context),
              ),
            ]),
            const SizedBox(height: 32),
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
                          content:
                              Text('Unable to sign out. Please try again.'),
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
            const SizedBox(height: 24),
            Text(
              'Version 1.0.0 • Build 2026.04.14',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: MridaColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
      UserProfile? profile, String languageCode, ThemeMode themeMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 12),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: MridaColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.settings_outlined,
                    color: MridaColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?.displayName?.toUpperCase() ?? 'FARMER PROFILE',
                      style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: MridaColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      profile?.phoneNumber.isNotEmpty == true
                          ? profile!.phoneNumber
                          : 'No phone linked',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: MridaColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildChip(
                  'Language', _languageOptions[languageCode] ?? 'English'),
              _buildChip('Theme', _themeModeLabel(themeMode)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: MridaColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $value',
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: MridaColors.onSurfaceVariant,
        ),
      ),
    );
  }

  void _showLanguageSheet(
      BuildContext context, WidgetRef ref, String currentCode) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Language',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              ..._languageOptions.entries.map((entry) {
                final isSelected = entry.key == currentCode;
                return ListTile(
                  title: Text(entry.value),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: MridaColors.primary)
                      : null,
                  onTap: () async {
                    final selected = entry.key;
                    ref
                        .read(localStorageServiceProvider)
                        .saveProfile(language: selected);
                    final userId = ref.read(currentUserIdProvider);
                    if (userId != null) {
                      try {
                        await ref
                            .read(firestoreServiceProvider)
                            .updateUserProfile(
                                userId, {'languageCode': selected});
                      } catch (_) {
                        // Local save is already complete.
                      }
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showThemeSheet(
      BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeMode.values.map((mode) {
              final label = _themeModeLabel(mode);
              return ListTile(
                title: Text(label),
                trailing: mode == currentMode
                    ? const Icon(Icons.check, color: MridaColors.primary)
                    : null,
                onTap: () {
                  ref.read(appThemeModeProvider.notifier).setThemeMode(mode);
                  if (context.mounted) Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showUnitSheet(
      BuildContext context, WidgetRef ref, String currentUnits) {
    const options = ['Metric', 'Imperial'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              final isSelected = option == currentUnits;
              return ListTile(
                title: Text(option),
                trailing: isSelected
                    ? const Icon(Icons.check, color: MridaColors.primary)
                    : null,
                onTap: () {
                  ref.read(measurementUnitsProvider.notifier).setUnits(option);
                  if (context.mounted) Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showDeleteAccountNotice(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Account',
              style: GoogleFonts.sora(fontWeight: FontWeight.w700)),
          content: Text(
            'Account deletion is not available from this screen. Please contact MRIDA support if you need assistance.',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
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
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 8),
            blurRadius: 18,
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
    bool switchValue = false,
    ValueChanged<bool>? onSwitchChanged,
    Color? color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 18),
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
            if (hasSwitch && onSwitchChanged != null)
              Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeColor: MridaColors.primary,
              ),
            if (hasChevron)
              const Icon(Icons.chevron_right,
                  color: MridaColors.outlineVariant),
          ],
        ),
      ),
    );
  }
}
