import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisify/presentation/providers/auth_providers.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: MedisifyApp()));
}

class MedisifyApp extends ConsumerWidget {
  const MedisifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Global listener for session expiry
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next is AuthSessionExpired) {
        AppRouter.router.go('/login');
      }
    });

    return MaterialApp.router(
      title: 'Medisify Appointment Booking',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
