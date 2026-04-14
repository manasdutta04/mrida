import 'package:flutter/material.dart';
import '../../../widgets/universal_app_bar.dart';
import '../../../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MridaColors.surface,
      appBar: const UniversalAppBar(title: 'ABOUT MRIDA', showSettings: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: MridaColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco_rounded, size: 50, color: MridaColors.primary),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'MRIDA (मृदा)',
              style: GoogleFonts.sora(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: MridaColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'MRIDA is an AI-assisted soil health analysis platform designed for farmers. Using advanced vision AI, it provides instant diagnostic results from a single photograph of soil.',
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 1.6,
                color: MridaColors.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            _buildInfoRow('Version', '1.0.0'),
            _buildInfoRow('Build', '2026.04.14'),
            _buildInfoRow('Engine', 'Gemini 2.0 Flash'),
            const SizedBox(height: 32),
            Text(
              'Built for the Google Solution Challenge 2026.',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: MridaColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: MridaColors.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: MridaColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
