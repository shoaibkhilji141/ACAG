import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/constants/app_constants.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/utils/pakistan_input.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/primary_button.dart';
import '../../theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cnicController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _captchaController = TextEditingController();
  final _random = Random();
  late String _captchaCode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _captchaCode = _nextCaptcha();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  String _nextCaptcha() => _random.nextInt(1000).toString().padLeft(3, '0');

  void _refreshCaptcha() {
    setState(() {
      _captchaCode = _nextCaptcha();
      _captchaController.clear();
    });
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.signUpOwner(
        fullName: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: _phoneController.text,
        cnic: _cnicController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created! Please sign in.'),
          backgroundColor: AppColors.primaryContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    } on AuthException catch (e) {
      if (!mounted) return;
      _refreshCaptcha();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _refreshCaptcha();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: AppColors.surfaceLowest,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join ACAG',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Register as a home owner to track your construction project',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              AppTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Muhammad Usman',
                leadingIcon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'you@gmail.com',
                leadingIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: PakistanInput.validateGmail,
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _phoneController,
                label: 'Phone',
                hint: '+92 3XX XXXXXXX',
                leadingIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: PakistanInput.validatePhone,
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _cnicController,
                label: 'CNIC',
                hint: 'XXXXX-XXXXXXX-X',
                leadingIcon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: PakistanInput.validateCnic,
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Minimum 8 characters',
                leadingIcon: Icons.lock_outline,
                obscureText: true,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 8) return 'Minimum 8 characters';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _confirmController,
                label: 'Confirm Password',
                hint: 'Re-enter password',
                leadingIcon: Icons.lock_outline,
                obscureText: true,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Captcha',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 96,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      _captchaCode,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Refresh captcha',
                    onPressed: _isLoading ? null : _refreshCaptcha,
                    icon: const Icon(Icons.refresh),
                    color: AppColors.outline,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _captchaController,
                label: 'Enter Captcha',
                hint: '3 digits',
                leadingIcon: Icons.verified_user_outlined,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: 3,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSubmitted: (_) => _signUp(),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Captcha is required';
                  }
                  if (v.trim() != _captchaCode) {
                    return 'Captcha does not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Sign Up',
                icon: Icons.person_add_outlined,
                isLoading: _isLoading,
                onPressed: _signUp,
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        TextSpan(
                          text: 'Login',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
