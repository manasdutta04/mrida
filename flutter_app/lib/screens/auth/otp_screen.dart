import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({
    super.key, 
    required this.verificationId,
    required this.phoneNumber,
  });
  
  final String verificationId;
  final String phoneNumber;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final controller = TextEditingController();
  final auth = AuthService();
  late String currentVerificationId;
  bool loading = false;
  int seconds = 45;

  @override
  void initState() {
    super.initState();
    currentVerificationId = widget.verificationId;
    _startTimer();
  }

  void _startTimer() {
    setState(() => seconds = 45);
    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted || seconds == 0) return false;
      setState(() => seconds--);
      return seconds > 0;
    });
  }

  Future<void> _resendCode() async {
    if (seconds > 0) return;
    try {
      setState(() => loading = true);
      final newVid = await auth.sendOTP(widget.phoneNumber);
      setState(() {
        currentVerificationId = newVid;
        loading = false;
      });
      _startTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code resent')),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Simple mask for phone number: +91 98XXX XX001
    String maskedPhone = widget.phoneNumber;
    if (maskedPhone.length > 7) {
      maskedPhone = '${maskedPhone.substring(0, 6)}XXXXX${maskedPhone.substring(maskedPhone.length - 2)}';
    }

    return Scaffold(
      backgroundColor: MridaColors.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
              'Enter code',
              style: theme.textTheme.displayMedium?.copyWith(color: MridaColors.primary),
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyLarge?.copyWith(color: MridaColors.secondary),
                children: [
                  const TextSpan(text: "We've sent a 6-digit verification code to\n"),
                  TextSpan(
                    text: maskedPhone,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: MridaColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            
            // OTP Input Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return Container(
                  width: 48,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: MridaColors.surfaceContainerLow,
                    border: Border(
                      bottom: BorderSide(
                        color: controller.text.length > index 
                            ? MridaColors.primary 
                            : MridaColors.outlineVariant.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    controller.text.length > index ? controller.text[index] : '',
                    style: GoogleFonts.sora(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: MridaColors.onSurface,
                    ),
                  ),
                );
              }),
            ),
            
            // Hidden input for logic
            Opacity(
              opacity: 0,
              child: SizedBox(
                height: 0,
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  onChanged: (v) {
                    setState(() {});
                    if (v.length == 6) {
                      _verify();
                    }
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Actions
            Center(
              child: Column(
                children: [
                  if (seconds > 0)
                    Text(
                      'Resend in 0:${seconds.toString().padLeft(2, '0')}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: MridaColors.onSecondaryContainer,
                      ),
                    )
                  else
                    TextButton(
                      onPressed: loading ? null : _resendCode,
                      child: Text(
                        'RESEND CODE',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: MridaColors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: loading ? null : _verify,
                    child: loading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('VERIFY ACCOUNT'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Try another method',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: MridaColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Decorative Brand Identity
            const SizedBox(height: 64),
            Center(
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: MridaColors.primary, width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.eco_outlined, size: 48, color: MridaColors.primary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verify() async {
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
  }
}
