import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: MridaColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0), // Wider left margin as per design rules
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              // Brand Mark
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/branding/mrida_logo.svg',
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      MridaColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'MRIDA',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: MridaColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 64),
              // Devanagari Title
              Text(
                'मृदा',
                style: GoogleFonts.sora(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: MridaColors.primary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              // Editorial Subtitle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: Text(
                  'KNOW YOUR SOIL,\nAN ARCHIVE OF GROWTH.',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: MridaColors.textSecondary,
                    height: 1.6,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              // CTA Section
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('GET STARTED'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go('/demo'),
                    child: Text(
                      'EXPLORE DEMO',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: MridaColors.textPrimary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
