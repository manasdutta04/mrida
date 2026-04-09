import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(value: false, label: Text('Phone OTP')),
                ButtonSegment<bool>(value: true, label: Text('Email')),
              ],
              selected: {isEmailMode},
              onSelectionChanged: (v) => setState(() => isEmailMode = v.first),
            ),
            const SizedBox(height: 16),
            if (!isEmailMode)
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone (+91XXXXXXXXXX)'),
              ),
            if (isEmailMode) ...[
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
            ],
            const SizedBox(height: 16),
            if (!isEmailMode)
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        try {
                          final raw = _phoneController.text.replaceAll(RegExp(r'\D'), '');
                          if (raw.length != 10) {
                            throw Exception('Enter a valid 10-digit phone number.');
                          }
                          setState(() => loading = true);
                          final verificationId = await _auth.sendOTP('+91$raw');
                          if (!context.mounted) return;
                          setState(() => loading = false);
                          context.go('/login/otp', extra: verificationId);
                        } catch (e) {
                          setState(() => loading = false);
                          await _showError(e);
                        }
                      },
                child: Text(loading ? 'Sending...' : 'Send OTP'),
              ),
            if (isEmailMode) ...[
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        try {
                          setState(() => loading = true);
                          await _auth.authenticateWithEmailPassword(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          if (!context.mounted) return;
                          setState(() => loading = false);
                          context.go('/home');
                        } catch (e) {
                          setState(() => loading = false);
                          await _showError(e);
                        }
                      },
                child: Text(loading ? 'Authenticating...' : 'Authenticate'),
              ),
            ],
            TextButton(
              onPressed: () => context.go('/demo'),
              child: const Text('Try Demo'),
            ),
          ],
        ),
      ),
    );
  }
}
