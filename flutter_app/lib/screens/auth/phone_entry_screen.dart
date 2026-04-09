import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final _controller = TextEditingController();
  final _auth = AuthService();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone (+91XXXXXXXXXX)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      final raw = _controller.text.replaceAll(RegExp(r'\D'), '');
                      if (raw.length != 10) return;
                      setState(() => loading = true);
                      final verificationId = await _auth.sendOTP('+91$raw');
                      if (!context.mounted) return;
                      setState(() => loading = false);
                      context.go('/login/otp', extra: verificationId);
                    },
              child: Text(loading ? 'Sending...' : 'Send OTP'),
            ),
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
