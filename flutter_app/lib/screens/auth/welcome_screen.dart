import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  static const String _bgUrl = 
    'https://lh3.googleusercontent.com/aida-public/AB6AXuACq1wA0604TpcT4P4D-zC52vW_8f-3_5TIezuQDitbRHJK9yWItu3-Iqd2TizWHRHtnpPhpTpzSAP5ezUuAHqj_V9qRmy5UbbG_qMElofOquRYfN-OJsvKbkJIc3N0PgTw_4SbBfzbmUKDA10ZIndS-D43oB1u7W3XHJnOUNAWG1TYwITLsmJB3W-S7K7OfC4J_EEFMXibxXiPNqlDGZ5fSNazUVUs_RtOht80p3sSBVKpYdaWi9ciwSVBysALyXL3BxeTs3F12jRP';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache the image as soon as dependencies are available
    precacheImage(const NetworkImage(_bgUrl), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MridaColors.surface,
      body: Stack(
        children: [
          // Background Image Layer with Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: MridaColors.surface,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      _bgUrl,
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.4), // Fade image for light look
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            MridaColors.surface.withValues(alpha: 0.2),
                            MridaColors.surface.withValues(alpha: 0.8),
                            MridaColors.surface,
                          ],
                          stops: const [0.0, 0.5, 0.8],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Main Content Shell
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  
                  // Center Branding
                  Column(
                    children: [
                      Text(
                        'मृदा',
                        style: GoogleFonts.sora(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: MridaColors.primary,
                          letterSpacing: -2.0,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Know Your Soil',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: MridaColors.primary.withValues(alpha: 0.7),
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(flex: 7),
                  
                  // Bottom Actions
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => context.go('/login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MridaColors.primary,
                          foregroundColor: MridaColors.surface,
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                          elevation: 0,
                        ),
                        child: const Text('GET STARTED'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
