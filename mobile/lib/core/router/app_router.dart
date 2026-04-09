import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/search_appointments_screen.dart';
import '../../presentation/screens/my_bookings_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchAppointmentsScreen(),
      ),
      GoRoute(
        path: '/bookings',
        builder: (context, state) => const MyBookingsScreen(),
      ),
    ],
  );
}
