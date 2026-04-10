import 'package:go_router/go_router.dart';

import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/search_appointments_screen.dart';
import '../../presentation/screens/my_bookings_screen.dart';
import '../../presentation/screens/doctor_details_screen.dart';
import '../../presentation/screens/booking_form_screen.dart';
import '../../presentation/screens/booking_details_screen.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/edit_profile_screen.dart';
import '../../presentation/screens/availability_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
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
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchAppointmentsScreen(),
      ),
      GoRoute(
        path: '/bookings',
        builder: (context, state) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: '/doctor-details/:doctorId',
        builder: (context, state) {
          final doctorId = state.pathParameters['doctorId']!;
          return DoctorDetailsScreen(doctorId: doctorId);
        },
      ),
      GoRoute(
        path: '/booking-form',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BookingFormScreen(
            date: extra['date'] as String,
            startTime: extra['startTime'] as String,
            doctorProfileId: extra['doctorProfileId'] as String,
            doctorName: extra['doctorName'] as String,
          );
        },
      ),
      GoRoute(
        path: '/booking-details/:bookingId',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return BookingDetailsScreen(bookingId: bookingId);
        },
      ),
      GoRoute(
        path: '/availability',
        builder: (context, state) => const AvailabilityScreen(),
      ),
    ],
  );
}
