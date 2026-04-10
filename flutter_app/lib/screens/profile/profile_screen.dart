import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu, color: MridaColors.primary),
            onPressed: () {},
          ),
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
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: MridaColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('RK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(width: 16),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
          children: [
            // Profile Hero
            Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: MridaColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: MridaColors.primary.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'RK',
                    style: GoogleFonts.sora(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Rajan Kumar',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  '+91 98765 43210',
                  style: TextStyle(color: MridaColors.secondary, fontWeight: FontWeight.w500),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 48),
            
            // Stats Grid
            Row(
              children: [
                _buildStatCard('12', 'SCANS'),
                const SizedBox(width: 12),
                _buildStatCard('3', 'FIELDS'),
                const SizedBox(width: 12),
                _buildStatCard('4', 'CROPS'),
              ],
            ),
            const SizedBox(height: 48),
            
            // Preferences Group
            _buildGroupHeader('PREFERENCES'),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: MridaColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildListTile(Icons.language, 'Language', trailing: 'Hindi'),
                  _buildListTile(Icons.notifications_none, 'Notifications', hasSwitch: true),
                  _buildListTile(Icons.eco_outlined, 'Default Crop', trailing: 'Wheat', isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // My Farm Group
            _buildGroupHeader('MY FARM'),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: MridaColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildListTile(Icons.map_outlined, 'Manage Fields', hasChevron: true),
                  _buildListTile(Icons.history, 'Scan History', hasChevron: true, isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Support Group
            _buildGroupHeader('SUPPORT'),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: MridaColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildListTile(Icons.info_outline, 'About', hasChevron: true),
                  _buildListTile(Icons.security_outlined, 'Privacy Policy', hasChevron: true),
                  _buildListTile(Icons.star_outline, 'Rate App', hasChevron: true, isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 48),
            
            // Sign Out
            ElevatedButton.icon(
              onPressed: () => context.go('/welcome'),
              icon: const Icon(Icons.logout),
              label: const Text('SIGN OUT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: MridaColors.errorContainer,
                foregroundColor: MridaColors.error,
              ),
            ),
            const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    ],
  );
}

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.bold, color: MridaColors.primary)),
            Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: MridaColors.secondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          title,
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: MridaColors.onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, {String? trailing, bool hasSwitch = false, bool hasChevron = false, bool isLast = false}) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: MridaColors.outlineVariant.withOpacity(0.1))),
      ),
      child: ListTile(
        leading: Icon(icon, color: MridaColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: hasSwitch 
          ? Switch(value: true, onChanged: (_) {}, activeColor: MridaColors.primary)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailing != null) Text(trailing, style: const TextStyle(fontWeight: FontWeight.bold, color: MridaColors.onSurfaceVariant, fontSize: 13)),
                if (hasChevron) const Icon(Icons.chevron_right, color: MridaColors.outlineVariant),
              ],
            ),
      ),
    );
  }
}
