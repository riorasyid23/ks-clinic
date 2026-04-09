import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/entities/doctor.dart';

part 'appointment_providers.g.dart';

@riverpod
List<Appointment> upcomingAppointments(UpcomingAppointmentsRef ref) {
  // Mock data
  return [
    Appointment(
      id: '1',
      doctor: const Doctor(
        id: 'd1',
        name: 'Dr. Sarah Sterling',
        specialty: 'Cardiology',
        avatarUrl: '',
        rating: 4.8,
        reviewCount: 124,
      ),
      dateTime: DateTime.now().add(const Duration(hours: 2)),
      status: 'Upcoming',
      type: 'Routine Checkup',
    ),
  ];
}

@riverpod
List<Doctor> recommendedDoctors(RecommendedDoctorsRef ref) {
  // Mock data
  return [
    const Doctor(
      id: 'd1',
      name: 'Dr. Sarah Sterling',
      specialty: 'Cardiology',
      avatarUrl: '',
      rating: 4.8,
      reviewCount: 124,
    ),
    const Doctor(
      id: 'd2',
      name: 'Dr. Marcus Webb',
      specialty: 'Neurology',
      avatarUrl: '',
      rating: 4.9,
      reviewCount: 89,
    ),
  ];
}
