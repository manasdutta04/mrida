import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();
  bool loading = false;
  bool isEmailMode = false;

  Future<void> _showError(Object error) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: MridaColors.surface,
      appBar: AppBar(
        title: const Text('LOGIN'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: theme.textTheme.labelLarge?.copyWith(
          letterSpacing: 2.0,
          color: MridaColors.textSecondary,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back.',
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Securely access your soil digital archive.',
              style: theme.textTheme.bodyMedium?.copyWith(color: MridaColors.textSecondary),
            ),
            const SizedBox(height: 48),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(value: false, label: Text('PHONE')),
                ButtonSegment<bool>(value: true, label: Text('EMAIL')),
              ],
              selected: {isEmailMode},
              onSelectionChanged: (v) => setState(() => isEmailMode = v.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: MridaColors.primary,
                selectedForegroundColor: MridaColors.onPrimary,
              ),
            ),
            const SizedBox(height: 32),
            if (!isEmailMode)
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'PHONE NUMBER',
                  hintText: '+91XXXXXXXXXX',
                  labelStyle: theme.textTheme.labelLarge,
                  filled: true,
                  fillColor: MridaColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            if (isEmailMode) ...[
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'EMAIL ADDRESS',
                  labelStyle: theme.textTheme.labelLarge,
                  filled: true,
                  fillColor: MridaColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'PASSWORD',
                  labelStyle: theme.textTheme.labelLarge,
                  filled: true,
                  fillColor: MridaColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      try {
                        setState(() => loading = true);
                        if (!isEmailMode) {
                          final raw = _phoneController.text.replaceAll(RegExp(r'\D'), '');
                          if (raw.length != 10) {
                            throw Exception('Enter a valid 10-digit phone number.');
                          }
                          final verificationId = await _auth.sendOTP('+91$raw');
                          if (!context.mounted) return;
                          context.go('/login/otp', extra: verificationId);
                        } else {
                          await _auth.authenticateWithEmailPassword(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          if (!context.mounted) return;
                          context.go('/home');
                        }
                        setState(() => loading = false);
                      } catch (e) {
                        setState(() => loading = false);
                        await _showError(e);
                      }
                    },
              child: Text(loading 
                ? (isEmailMode ? 'AUTHENTICATING...' : 'SENDING...') 
                : (isEmailMode ? 'CONTINUE' : 'SEND OTP')),
            ),
          ],
        ),
      ),
    );
  }
}
