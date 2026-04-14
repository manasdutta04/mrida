import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';

class PhoneEntryScreen extends StatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final auth = AuthService();
  
  bool isLoginMode = true;
  bool loading = false;
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: MridaColors.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Brand Identity & Dynamic Header
              Center(
                child: Column(
                  children: [
                    Text(
                      'मृदा',
                      style: GoogleFonts.sora(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: MridaColors.primary,
                        letterSpacing: -1.0,
                      ),
                    ),
                    Text(
                      isLoginMode ? 'Welcome Back' : 'Create Account',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: MridaColors.secondary.withOpacity(0.7),
                        letterSpacing: 4.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              
              Text(
                'Email Address',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: MridaColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'name@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: MridaColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Text(
                'Password',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: MridaColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  hintText: isLoginMode ? 'Enter your password' : 'Create a password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: MridaColors.secondary,
                    ),
                    onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                  ),
                  filled: true,
                  fillColor: MridaColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              
              if (isLoginMode)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handleForgotPassword,
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: MridaColors.primary,
                      ),
                    ),
                  ),
                ),
              
              // Confirm Password field (only for signup)
              if (!isLoginMode) ...[
                const SizedBox(height: 24),
                Text(
                  'Confirm Password',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: MridaColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Repeat your password',
                    prefixIcon: const Icon(Icons.shield_outlined),
                    filled: true,
                    fillColor: MridaColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 40),
              
              ElevatedButton(
                onPressed: loading ? null : _handleSubmit,
                child: loading 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      ) 
                    : Text(isLoginMode ? 'LOGIN' : 'CREATE ACCOUNT'),
              ),
              
              const SizedBox(height: 24),
              
              // Mode Toggle
              Center(
                child: TextButton(
                  onPressed: () => setState(() => isLoginMode = !isLoginMode),
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium?.copyWith(color: MridaColors.secondary),
                      children: [
                        TextSpan(text: isLoginMode ? "Don't have an account? " : "Already have an account? "),
                        TextSpan(
                          text: isLoginMode ? 'Sign Up' : 'Login',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: MridaColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: MridaColors.outlineVariant.withOpacity(0.5))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: MridaColors.secondary,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: MridaColors.outlineVariant.withOpacity(0.5))),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Google Button
              OutlinedButton(
                onPressed: loading ? null : _handleGoogleSignIn,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: MridaColors.outlineVariant.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.string(
                      '<svg viewBox="0 0 24 24" width="24" height="24"><path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/><path fill="#FBBC05" d="M5.84 14.1c-.22-.66-.35-1.36-.35-2.1s.13-1.44.35-2.1V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l3.66-2.84z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/></svg>',
                    ),
                    const SizedBox(width: 12),
                    const Text('CONTINUE WITH GOOGLE'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || (!isLoginMode && confirm.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (!isLoginMode && password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      setState(() => loading = true);
      if (isLoginMode) {
        await auth.signInWithEmailPassword(email: email, password: password);
      } else {
        await auth.signUpWithEmailPassword(email: email, password: password);
      }
      if (context.mounted) context.go('/home');
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => loading = true);
      await auth.signInWithGoogle();
      if (context.mounted) context.go('/home');
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email to reset password')),
      );
      return;
    }

    try {
      setState(() => loading = true);
      await auth.sendPasswordResetEmail(email);
      setState(() => loading = false);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reset Link Sent'),
            content: Text('A password reset link has been sent to $email. Please check your inbox.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
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
}
