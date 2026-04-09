import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key, required this.verificationId});
  final String verificationId;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final controller = TextEditingController();
  final auth = AuthService();
  int seconds = 60;

  @override
  void initState() {
    super.initState();
    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted || seconds == 0) return false;
      setState(() => seconds--);
      return seconds > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Enter 6-digit OTP'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              onChanged: (v) async {
                if (v.length == 6) {
                  await auth.verifyOTP(widget.verificationId, v);
                  if (context.mounted) context.go('/home');
                }
              },
            ),
            Text(seconds > 0 ? 'Resend in ${seconds}s' : 'You can resend OTP'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await auth.verifyOTP(widget.verificationId, controller.text);
                if (context.mounted) context.go('/home');
              },
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
