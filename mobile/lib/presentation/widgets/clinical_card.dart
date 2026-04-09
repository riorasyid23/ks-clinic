import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ClinicalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ClinicalCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12), // xl / 0.75rem ~ 12px
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.15), // ghost border
          width: 1,
        ),
        boxShadow: AppColors.ambientShadow, // Ambient light shadow
      ),
      child: child,
    );
  }
}
