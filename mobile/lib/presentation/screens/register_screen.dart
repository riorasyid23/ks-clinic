import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  int _currentStep = 0;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() => _isLoading = true);
    try {
      final payload = {
        'email': _emailController.text,
        'password': _passwordController.text,
        'confirmPassword': _confirmPasswordController.text,
        'name': _nameController.text,
        'phoneNumber': _phoneController.text,
      };

      await ref.read(authRepositoryProvider).register(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please login.'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextStep() {
    if (_currentStep < 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _handleRegister();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: _previousStep,
        ),
        title: Text(
          'Registration',
          style: textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Simulated clinical text/logo top right on step 1
          if (_currentStep == 0)
            Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Center(
                child: Text(
                  'CLINICAL',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _currentStep == 0
                        ? _buildStep1(textTheme)
                        : _buildStep2(textTheme),
                  ),
                ),
              ),
            ),
            _buildFooter(textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(TextTheme textTheme) {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Step 1 of 2: Set up your credentials',
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outlineVariant.withOpacity(0.15),
            ),
            boxShadow: AppColors.ambientShadow,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CustomTextField(
                label: 'Work Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Password',
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.onSurfaceVariant,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Confirm Password',
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.onSurfaceVariant,
                  ),
                  onPressed: () => setState(
                    () =>
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Next Step',
                onPressed: _nextStep,
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Already have an account?',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.go('/login');
                },
                child: Text(
                  'Back to Login',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(TextTheme textTheme) {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondaryFixed,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            'Step 2 of 2',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSecondaryFixed,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Personal Profile',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tell us about yourself',
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outlineVariant.withOpacity(0.15),
            ),
            boxShadow: AppColors.ambientShadow,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              CustomTextField(
                label: 'Full Name',
                controller: _nameController,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.call, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Security Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.secondaryFixed.withOpacity(0.1),
            border: Border.all(
              color: AppColors.secondaryFixed.withOpacity(0.15),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryFixed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user,
                  color: AppColors.onSecondaryFixed,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Secure Identity',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your details are protected with clinical-grade encryption.',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        PrimaryButton(
          text: 'Complete Registration',
          icon: Icons.chevron_right,
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _nextStep,
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          text: 'Back to Account Details',
          isSecondary: true,
          onPressed: _previousStep,
        ),
      ],
    );
  }

  Widget _buildFooter(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withOpacity(0.7),
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant.withOpacity(0.15)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFooterItem(Icons.help_outline, 'Help', textTheme),
          _buildFooterItem(
            Icons.contact_support_outlined,
            'Support',
            textTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterItem(IconData icon, String label, TextTheme textTheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.onSurfaceVariant, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
