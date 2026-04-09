import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isSecondary;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100), // fully rounded
        gradient: isSecondary ? null : AppColors.primaryGradient,
        color: isSecondary ? AppColors.secondaryFixed : null,
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSecondary ? AppColors.onSecondaryFixed : AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
