import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class FieldDetailScreen extends StatelessWidget {
  const FieldDetailScreen({super.key, required this.fieldId});

  final String fieldId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: MridaColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MridaColors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Soil Report',
          style: GoogleFonts.sora(
            fontWeight: FontWeight.bold,
            color: MridaColors.primary,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: MridaColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Header Image & Grade
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: const DecorationImage(
                            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBpzq4wkCqKIEdnl6Z02uCfGYan0oMI436nCYeDCoMOk0WVoe_ueZHU2dc6AdVthtP0MRpFMR3G76whvkwq3FDcGM-Prcs3UvI4qevSxowW8qe-kgC-Lf71RK43LbvgaT4rjFVP20zM98BfNfXGP68lDhxWKZ7am3JAZPcQlTDPR8zPaYFcD8cOf7GliLEKEVheCbLAjZzE9DW8bDyEEYZBEIRSDhaY5l6_gbhmIh5Ci5zfYa31fHHG1ccmXnP0vGdhqnwtSHQKkuFW'),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(color: MridaColors.surfaceContainer, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: MridaColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: MridaColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: MridaColors.primary.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'A',
                      style: GoogleFonts.sora(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SOIL GRADE',
                    style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 2.0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Confidence Score
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: MridaColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('CONFIDENCE SCORE', style: theme.textTheme.labelMedium),
                      Text('92%', style: theme.textTheme.labelLarge?.copyWith(color: MridaColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: const LinearProgressIndicator(
                      value: 0.92,
                      minHeight: 8,
                      backgroundColor: MridaColors.surfaceContainerHighest,
                      color: MridaColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            
            // Detected Section
            _buildSectionHeader('WHAT WE DETECTED'),
            const SizedBox(height: 24),
            _buildInfoRow(Icons.palette_outlined, 'Color', 'Dark Brown'),
            _buildInfoRow(Icons.texture_outlined, 'Texture', 'Loamy'),
            _buildInfoRow(Icons.opacity_outlined, 'Moisture', '12%'),
            _buildInfoRow(Icons.eco_outlined, 'Organic Matter', 'High'),
            
            const SizedBox(height: 48),
            
            // NPK Status
            _buildSectionHeader('NPK STATUS', trailingIcon: Icons.science_outlined),
            const SizedBox(height: 24),
            _buildNPKRow('N', 'Nitrogen', 0.25, 'LOW', MridaColors.error),
            _buildNPKRow('P', 'Phosphorus', 0.85, 'HIGH', MridaColors.primary),
            _buildNPKRow('K', 'Potassium', 0.55, 'MED', MridaColors.secondary),
            
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: MridaColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text('pH BALANCE', style: theme.textTheme.labelMedium),
                  const SizedBox(height: 8),
                  Text(
                    '6.2 – 7.0',
                    style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.bold, color: MridaColors.primary),
                  ),
                  Text(
                    '"Slightly acidic"',
                    style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: MridaColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Prescription
            _buildSectionHeader('PRESCRIPTION'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildTag(Icons.warning_amber_rounded, 'Nitrogen Deficiency'),
                _buildTag(Icons.warning_amber_rounded, 'Low Micro-nutrients'),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: MridaColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Based on the scan, your field requires immediate nitrogen supplementation. We recommend applying a slow-release urea-based fertilizer (46-0-0) at a rate of 120kg/hectare.',
                          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15, height: 1.6),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.volume_up, color: MridaColors.primary),
                        style: IconButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.all(12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: MridaColors.primary),
                      const SizedBox(width: 8),
                      Text('APPLY BY: OCT 24, 2026', style: theme.textTheme.labelMedium?.copyWith(color: MridaColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        color: Colors.white.withOpacity(0.4),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: ElevatedButton(
            onPressed: () {},
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save_outlined),
                SizedBox(width: 12),
                Text('SAVE REPORT'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {IconData? trailingIcon}) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: MridaColors.outlineVariant.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: MridaColors.secondary)),
          if (trailingIcon != null)
            Row(
              children: [
                Icon(trailingIcon, size: 14, color: MridaColors.primary),
                const SizedBox(width: 4),
                Text('CHEMICAL SCAN', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: MridaColors.primary)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: MridaColors.secondary),
              const SizedBox(width: 16),
              Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: MridaColors.onSurfaceVariant)),
            ],
          ),
          Text(value, style: GoogleFonts.sora(fontWeight: FontWeight.bold, color: MridaColors.primary)),
        ],
      ),
    );
  }

  Widget _buildNPKRow(String symbol, String name, double value, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: symbol, style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold, color: MridaColors.onSurface)),
                    const TextSpan(text: ' '),
                    TextSpan(text: name, style: GoogleFonts.inter(fontSize: 12, color: MridaColors.secondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: MridaColors.surfaceContainerHigh,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: MridaColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: MridaColors.error.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: MridaColors.error),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: MridaColors.error)),
        ],
      ),
    );
  }
}
