import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/field_provider.dart';
import '../../models/user_profile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userProfileAsync = ref.watch(userProfileProvider);
    final profile = userProfileAsync.value;

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
                      Colors.black.withValues(alpha: 0.9),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 40, color: MridaColors.primary),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.displayName?.toUpperCase() ?? 'ADD NAME',
                              style: theme.textTheme.displayLarge?.copyWith(color: Colors.white, fontSize: 32),
                            ),
                            Text(
                              profile?.phoneNumber ?? '+91 XXXXX XXXXX',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
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
                const Row(
                  children: [
                    _BentoStatCard(value: '12', label: 'SCANS'),
                    SizedBox(width: 12),
                    _BentoStatCard(value: '3', label: 'FIELDS'),
                    SizedBox(width: 12),
                    _BentoStatCard(value: '4', label: 'CROPS'),
                  ],
                ),
                const SizedBox(height: 32),

                // Preferences
                Text('PREFERENCES', style: theme.textTheme.labelLarge),
                const SizedBox(height: 16),
                _SettingsGroup(children: [
                  _LanguageSettingTile(currentCode: profile?.languageCode ?? 'en'),
                  _SettingsTile(
                    icon: Icons.edit_outlined,
                    title: 'Edit Profile',
                    hasChevron: true,
                    onTap: () => _showEditProfileModal(context, ref, profile),
                  ),
                ]),
                const SizedBox(height: 24),

                _SettingsGroup(children: [
                  _SettingsTile(icon: Icons.map_outlined, title: 'Manage Fields', hasChevron: true),
                  _SettingsTile(icon: Icons.history, title: 'Full Scan History', hasChevron: true, onTap: () => context.push('/history')),
                ]),
                const SizedBox(height: 48),

                // Sign Out
                TextButton(
                  onPressed: () => ref.read(authServiceProvider).signOut(),
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

  void _showEditProfileModal(BuildContext context, WidgetRef ref, UserProfile? profile) {
    final nameController = TextEditingController(text: profile?.displayName);
    final phoneController = TextEditingController(text: profile?.phoneNumber);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 120),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: MridaColors.outlineVariant, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 32),
            const Text('EDIT PROFILE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2.0)),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'FULL NAME', hintText: 'Enter your name'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'PHONE NUMBER', hintText: '+91 ...'),
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final userId = ref.read(currentUserIdProvider);
                  if (userId != null) {
                    await ref.read(firestoreServiceProvider).updateUserProfile(userId, {
                      'displayName': nameController.text.trim(),
                      'phoneNumber': phoneController.text.trim(),
                    });
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('SAVE CHANGES'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageSettingTile extends ConsumerWidget {
  const _LanguageSettingTile({required this.currentCode});
  final String currentCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(Icons.language, color: MridaColors.primary.withValues(alpha: 0.4), size: 20),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'LANGUAGE',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
            ),
          ),
          DropdownButton<String>(
            value: currentCode,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down, size: 18),
            style: const TextStyle(color: MridaColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
            items: const [
              DropdownMenuItem(value: 'en', child: Text('ENGLISH')),
              DropdownMenuItem(value: 'hi', child: Text('HINDI')),
            ],
            onChanged: (val) async {
              if (val != null) {
                final userId = ref.read(currentUserIdProvider);
                if (userId != null) {
                  await ref.read(firestoreServiceProvider).updateUserProfile(userId, {'languageCode': val});
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _BentoStatCard extends StatelessWidget {
  const _BentoStatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: MridaColors.outline.withValues(alpha: 0.1)),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.hasSwitch = false,
    this.hasChevron = false,
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String? trailing;
  final bool hasSwitch;
  final bool hasChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
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
                trailing!,
                style: const TextStyle(color: MridaColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            if (hasSwitch) Switch(value: true, onChanged: (_) {}),
            if (hasChevron) const Icon(Icons.chevron_right, size: 16, color: MridaColors.outlineVariant),
          ],
        ),
      ),
    );
  }
}
