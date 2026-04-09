import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isSecondary;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isSecondary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100), // fully rounded
        gradient: isSecondary ? null : AppColors.primaryGradient,
        color: isSecondary ? AppColors.white : null,
        border: isSecondary ? Border.all(color: AppColors.outlineVariant.withOpacity(0.2)) : null,
        boxShadow: isSecondary ? null : [
          const BoxShadow(
            color: Color.fromRGBO(0, 64, 133, 0.2),
            offset: Offset(0, 8),
            blurRadius: 30,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSecondary && icon != null) ...[
                  Icon(icon, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: isSecondary ? AppColors.onSurface : AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isSecondary ? 14 : 18,
                  ),
                ),
                if (!isSecondary && icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, color: AppColors.white, size: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
