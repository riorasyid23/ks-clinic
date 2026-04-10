import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';

/// Provides the singleton [BookingRepository].
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository();
});

/// Async provider that fetches patient bookings from the API.
/// Use ref.invalidate(bookingsProvider) to refresh.
final bookingsProvider =
    FutureProvider.autoDispose<List<Booking>>((ref) async {
  final repo = ref.read(bookingRepositoryProvider);
  return repo.getPatientBookings();
});

/// Async provider that fetches a single booking's details.
final bookingDetailsProvider =
    FutureProvider.autoDispose.family<Booking, String>((ref, bookingId) async {
  final repo = ref.read(bookingRepositoryProvider);
  return repo.getBookingDetails(bookingId);
});

/// Async provider that fetches the patient's nearest upcoming appointment.
final nearestAppointmentProvider =
    FutureProvider.autoDispose<Booking?>((ref) async {
  final repo = ref.read(bookingRepositoryProvider);
  return repo.getNearestAppointment();
});
