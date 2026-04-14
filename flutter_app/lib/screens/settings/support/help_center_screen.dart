import 'package:flutter/material.dart';
import '../../../widgets/universal_app_bar.dart';
import '../../../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MridaColors.surface,
      appBar: const UniversalAppBar(title: 'HELP CENTER', showSettings: false),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'How can we help?',
            style: GoogleFonts.sora(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: MridaColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          _buildFAQItem('How accurate is MRIDA?', 'MRIDA use state-of-the-art AI grounded by regional soil profiles. While highly accurate for estimation, always consult lab tests for high-investment decisions.'),
          _buildFAQItem('Can I use it offline?', 'You can view past scans and field data offline. Uploading new scans requires an active internet connection to reach our AI engine.'),
          _buildFAQItem('Is my data private?', 'Yes. All soil images and analysis results are private to your account and tied to your phone number.'),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: MridaColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.headset_mic_outlined, color: MridaColors.primary, size: 32),
                const SizedBox(height: 12),
                Text(
                  'Still need help?',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Contact our support team at support@mrida.io',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: MridaColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: MridaColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.5,
              color: MridaColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
