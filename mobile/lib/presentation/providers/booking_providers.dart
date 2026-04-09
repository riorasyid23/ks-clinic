import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';

/// Provides the singleton [BookingRepository].
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository();
});

/// Async provider that fetches patient bookings from the API.
/// Use ref.invalidate(bookingsProvider) to refresh.
final bookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final repo = ref.read(bookingRepositoryProvider);
  return repo.getPatientBookings();
});
