import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
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
  bool loading = false;

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
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: MridaColors.surface,
      appBar: AppBar(
        title: const Text('VERIFY'),
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
              'Confirm access.',
              style: theme.textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 6-digit code sent to your device.',
              style: theme.textTheme.bodyMedium?.copyWith(color: MridaColors.textSecondary),
            ),
            const SizedBox(height: 48),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: theme.textTheme.displaySmall?.copyWith(letterSpacing: 8),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: MridaColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) async {
                if (v.length == 6) {
                  try {
                    setState(() => loading = true);
                    await auth.verifyOTP(widget.verificationId, v);
                    if (context.mounted) context.go('/home');
                  } catch (e) {
                    setState(() => loading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                seconds > 0 ? 'Resend code in ${seconds}s' : 'Code expired. Resend?',
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: loading ? null : () async {
                try {
                  setState(() => loading = true);
                  await auth.verifyOTP(widget.verificationId, controller.text);
                  if (context.mounted) context.go('/home');
                } catch (e) {
                  setState(() => loading = false);
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: Text(loading ? 'VERIFYING...' : 'CONFIRM'),
            ),
          ],
        ),
      ),
    );
  }
}
