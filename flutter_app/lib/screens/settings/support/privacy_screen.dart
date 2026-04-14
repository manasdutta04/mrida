import 'package:flutter/material.dart';
import '../../../widgets/universal_app_bar.dart';
import '../../../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MridaColors.surface,
      appBar: const UniversalAppBar(title: 'PRIVACY POLICY', showSettings: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: GoogleFonts.sora(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: MridaColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Last Updated: April 14, 2026',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: MridaColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection('1. Data We Collect', 'We collect your phone number for authentication, soil images for analysis, and field location data to improve accuracy based on regional soil profiles.'),
            _buildSection('2. How We Use Data', 'Your data is used solely to provide soil diagnostic services, track history, and generate fertilizer prescriptions.'),
            _buildSection('3. Data Storage', 'Images and results are stored securely in Firebase Storage and Firestore, accessible only through your authenticated account.'),
            _buildSection('4. Third-Party Services', 'We use Google Gemini AI for processing images. Data sent to the AI engine is used for inference and is subject to Google\'s privacy standards.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: MridaColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color: MridaColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
