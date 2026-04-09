/// Represents a doctor's schedule slot.
class DoctorSchedule {
  final String id;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final int slotDuration;

  const DoctorSchedule({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.slotDuration,
  });

  factory DoctorSchedule.fromJson(Map<String, dynamic> json) {
    return DoctorSchedule(
      id: json['id'] as String,
      dayOfWeek: json['dayOfWeek'] as int,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      slotDuration: json['slotDuration'] as int,
    );
  }
}

/// Represents detailed information about a doctor.
class DoctorDetail {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String specialty;
  final List<DoctorSchedule> schedule;

  const DoctorDetail({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.specialty,
    required this.schedule,
  });

  factory DoctorDetail.fromJson(Map<String, dynamic> json) {
    return DoctorDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      specialty: json['specialty'] as String,
      schedule: (json['schedule'] as List<dynamic>)
          .map((s) => DoctorSchedule.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
