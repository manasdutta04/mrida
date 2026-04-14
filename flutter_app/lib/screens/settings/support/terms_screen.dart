import 'package:flutter/material.dart';
import '../../../widgets/universal_app_bar.dart';
import '../../../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MridaColors.surface,
      appBar: const UniversalAppBar(title: 'TERMS OF SERVICE', showSettings: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
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
            _buildSection('1. Acceptance of Terms', 'By using MRIDA, you agree to follow these terms. If you do not agree, please do not use the application.'),
            _buildSection('2. Service Usage', 'MRIDA provides soil health estimations using AI. You agree to use this service reasonably and not for any malicious purposes.'),
            _buildSection('3. Accuracy Disclaimer', 'MRIDA provides estimates and guidance. Users are encouraged to verify critical agricultural decisions with professional lab diagnostics.'),
            _buildSection('4. User Responsibilities', 'You are responsible for maintaining the confidentiality of your account and for all activities that occur under your account.'),
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
