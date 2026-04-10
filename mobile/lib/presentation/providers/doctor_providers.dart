import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisify/data/models/booking_model.dart';
import 'package:medisify/data/models/doctor_detail_model.dart';
import '../../data/repositories/doctor_repository.dart';
import 'package:medisify/presentation/providers/auth_providers.dart';

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepository();
});

final doctorInsightsProvider = FutureProvider.autoDispose<Map<String, dynamic>>(
  (ref) async {
    // Watch auth state to ensure we re-fetch if user changes
    final authState = ref.watch(authProvider);
    if (authState is! AuthAuthenticated) {
      throw Exception('User not authenticated');
    }

    return ref.watch(doctorRepositoryProvider).getInsights();
  },
);

final doctorAppointmentsProvider = FutureProvider.autoDispose<List<Booking>>((
  ref,
) async {
  // Watch auth state to ensure we re-fetch if user changes
  final authState = ref.watch(authProvider);
  if (authState is! AuthAuthenticated) {
    throw Exception('User not authenticated');
  }

  final dynamicRaw = await ref
      .watch(doctorRepositoryProvider)
      .getDoctorAppointments();
  return dynamicRaw
      .map((b) => Booking.fromJson(b as Map<String, dynamic>))
      .toList();
});

final doctorSchedulesProvider =
    FutureProvider.autoDispose<List<DoctorSchedule>>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState is! AuthAuthenticated) {
    throw Exception('User not authenticated');
  }

  // The API expects userId as doctorId parameter
  final doctorId = authState.user.id;

  final dynamicRaw =
      await ref.watch(doctorRepositoryProvider).getDoctorSchedules(doctorId);
  return dynamicRaw
      .map((s) => DoctorSchedule.fromJson(s as Map<String, dynamic>))
      .toList();
});
