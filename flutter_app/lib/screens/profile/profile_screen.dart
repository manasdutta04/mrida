import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: MridaColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: MridaColors.primary.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'RK',
                      style: GoogleFonts.sora(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rajan Kumar',
                    style: GoogleFonts.sora(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: MridaColors.onSurface,
                    ),
                  ),
                  Text(
                    '+91 98765 43210',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: MridaColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Stats row
            Row(
              children: [
                _buildStatCard('12', 'SCANS'),
                const SizedBox(width: 12),
                _buildStatCard('3', 'FIELDS'),
                const SizedBox(width: 12),
                _buildStatCard('4', 'CROPS'),
              ],
            ),
            const SizedBox(height: 40),

            // My Farm Section
            _buildSectionHeader('MY FARM'),
            const SizedBox(height: 12),
            _buildSettingsGroup([
              _buildSettingsTile(Icons.map_outlined, 'Manage Fields', hasChevron: true),
              _buildSettingsTile(Icons.history, 'Full Scan History', hasChevron: true),
              _buildSettingsTile(Icons.assignment_outlined, 'Activity Reports', hasChevron: true),
            ]),
            const SizedBox(height: 32),

            // Achievements Section
            _buildSectionHeader('ACHIEVEMENTS'),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildAchievementCard(Icons.verified_outlined, 'Soil Guardian', '10 Scans'),
                  const SizedBox(width: 12),
                  _buildAchievementCard(Icons.eco_outlined, 'Eco Mapper', '3 Fields'),
                  const SizedBox(width: 12),
                  _buildAchievementCard(Icons.workspace_premium_outlined, 'Pro Farmer', '1 mo streak'),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Edit Profile Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: BorderSide(color: MridaColors.primary.withValues(alpha: 0.1), width: 2),
                ),
                child: const Text('EDIT PROFILE DETAILS'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(IconData icon, String title, String subtitle) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MridaColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MridaColors.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: MridaColors.primary, size: 24),
          const Spacer(),
          Text(title, style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.bold)),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 10, color: MridaColors.onSurfaceVariant)),
        ],
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
    return Container(
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
              activeColor: MridaColors.primary,
            ),
          if (hasChevron)
            const Icon(Icons.chevron_right, color: MridaColors.outlineVariant),
        ],
      ),
    );
  }
}
