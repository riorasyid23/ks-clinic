import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF004085);
  static const Color primaryContainer = Color(0xFF1D57A7);
  static const Color primaryFixed = Color(0xFFD7E2FF);
  
  static const Color secondary = Color(0xFF006C53);
  static const Color secondaryContainer = Color(0xFF60F8CB);
  static const Color secondaryFixed = Color(0xFF64FBCE);
  static const Color onSecondaryFixed = Color(0xFF002117);

  static const Color surface = Color(0xFFF7F9FB);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color surfaceContainerHighest = Color(0xFFFFFFFF);
  
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF424752);
  
  static const Color error = Color(0xFFBA1A1A);
  
  static const Color outlineVariant = Color(0xFFC2C6D4);
  
  static const Color white = Colors.white;
  static const Color transparent = Colors.transparent;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
    transform: GradientRotation(135 * 3.1415927 / 180), // 135 degrees
  );

  // Shadows
  static List<BoxShadow> ambientShadow = [
    BoxShadow(
      color: onSurface.withOpacity(0.06),
      blurRadius: 32,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];
}
