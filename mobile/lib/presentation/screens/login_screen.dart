import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              // Intentional asymmetry & hang as per \"The Editorial Shift\"
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 16.0),
                child: Text(
                  'Welcome\nBack',
                  style: textTheme.displayLarge,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 16.0),
                child: Text(
                  'Sign in to manage your appointments and health records.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 64),
              const CustomTextField(
                label: 'Email Address',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              const CustomTextField(
                label: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot Password?',
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Sign In',
                onPressed: () {
                  context.go('/home');
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Register',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
