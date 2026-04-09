import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: textTheme.titleSmall?.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: textTheme.titleSmall?.copyWith(
            color: AppColors.primary,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: const UnderlineInputBorder(
            borderSide: BorderSide.none,
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide.none,
          ),
          errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.error, width: 2),
          ),
        ),
      ),
    );
  }
}
