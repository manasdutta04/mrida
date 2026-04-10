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
      backgroundColor: MridaColors.primary,
      body: Stack(
        children: [
          // Background Image Layer with Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                color: MridaColors.primary,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      _bgUrl,
                      fit: BoxFit.cover,
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF0D3B2E).withOpacity(0.2),
                            const Color(0xFF0D3B2E).withOpacity(0.6),
                            const Color(0xFF0D3B2E).withOpacity(0.95),
                          ],
                          stops: const [0.0, 0.6, 1.0],
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
                  // Top Bar
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Text(
                              'ENGLISH',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: MridaColors.surface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const Spacer(flex: 3),
                  
                  // Center Branding (Matching Stitch EXACTLY)
                  Column(
                    children: [
                      Text(
                        'मृदा',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: MridaColors.surface.withOpacity(0.8),
                          letterSpacing: -0.45,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Know Your Soil',
                        style: GoogleFonts.sora(
                          fontSize: 48, // Large impact as per user request
                          fontWeight: FontWeight.bold,
                          color: MridaColors.surface,
                          letterSpacing: -2.0,
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
                          backgroundColor: MridaColors.surface,
                          foregroundColor: MridaColors.primary,
                          elevation: 10,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        child: const Text('GET STARTED'),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => context.go('/demo'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          side: BorderSide(color: MridaColors.surface.withOpacity(0.3), width: 2),
                          shape: const StadiumBorder(),
                          foregroundColor: MridaColors.surface,
                        ),
                        child: const Text(
                          'TRY DEMO',
                          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
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
