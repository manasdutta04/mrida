import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final controller = TextEditingController();
  final auth = AuthService();
  bool loading = false;

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              'Enter your number',
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(height: 12),
            Text(
              "We'll send a 6-digit code",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: MridaColors.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 48),
            
            // Phone Input Cluster
            Row(
              children: [
                // Country Selector Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: MridaColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: MridaColors.outlineVariant.withOpacity(0.15)),
                    boxShadow: MridaColors.editorialShadow,
                  ),
                  child: Row(
                    children: [
                      const Text('🇮🇳', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        '+91',
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.expand_more, size: 18, color: MridaColors.onSecondaryContainer),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                
                // Main Input Field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: MridaColors.editorialShadow,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.phone,
                      style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
                      decoration: const InputDecoration(
                        hintText: 'Phone number',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        fillColor: MridaColors.surfaceContainerLow,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Action Button
            ElevatedButton(
              onPressed: loading ? null : () async {
                try {
                  setState(() => loading = true);
                  final vid = await auth.sendOTP('+91${controller.text}');
                  if (context.mounted) context.push('/login/otp', extra: vid);
                } catch (e) {
                  setState(() => loading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text('SEND OTP'),
            ),
            
            const SizedBox(height: 32),
            Center(
              child: Text(
                'No account needed · Free forever',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: MridaColors.onSecondaryContainer.withOpacity(0.6),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Divider
            Row(
              children: [
                Expanded(child: Divider(color: MridaColors.onSurface.withOpacity(0.1))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: MridaColors.onSurface.withOpacity(0.4),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: MridaColors.onSurface.withOpacity(0.1))),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Google Sign-In Button
            OutlinedButton(
              onPressed: () async {
                try {
                  setState(() => loading = true);
                  await auth.signInWithGoogle();
                  if (context.mounted) context.go('/home');
                } catch (e) {
                  setState(() => loading = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: MridaColors.onSurface,
                side: BorderSide(color: MridaColors.onSurface.withOpacity(0.1)),
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.05),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                    height: 24,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.login),
                  ),
                  const SizedBox(width: 12),
                  const Text('CONTINUE WITH GOOGLE'),
                ],
              ),
            ),
            
            // Brand Vignette
            const SizedBox(height: 64),
            Center(
              child: Container(
                width: 128,
                height: 4,
                decoration: BoxDecoration(
                  color: MridaColors.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: FractionallySizedBox(
                  widthFactor: 0.33,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: MridaColors.primary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
