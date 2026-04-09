import 'doctor.dart';

class Appointment {
  final String id;
  final Doctor doctor;
  final DateTime dateTime;
  final String status;
  final String type; // e.g., 'Consultation', 'Follow-up'
  
  const Appointment({
    required this.id,
    required this.doctor,
    required this.dateTime,
    required this.status,
    required this.type,
  });
}
