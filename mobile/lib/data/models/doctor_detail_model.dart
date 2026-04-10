class DoctorSchedule {
  final String id;
  final String doctorId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final int slotDuration;

  const DoctorSchedule({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.slotDuration,
  });

  factory DoctorSchedule.fromJson(Map<String, dynamic> json) {
    return DoctorSchedule(
      id: json['id'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      dayOfWeek: json['dayOfWeek'] as int? ?? 0,
      startTime: json['startTime'] as String? ?? '08:00',
      endTime: json['endTime'] as String? ?? '17:00',
      slotDuration: json['slotDuration'] as int? ?? 30,
    );
  }
}

/// Represents detailed information about a doctor.
class DoctorDetail {
  final String id;
  final String profileId;
  final String name;
  final String email;
  final String? phone;
  final String specialty;
  final List<DoctorSchedule> schedule;

  const DoctorDetail({
    required this.id,
    required this.profileId,
    required this.name,
    required this.email,
    this.phone,
    required this.specialty,
    required this.schedule,
  });

  factory DoctorDetail.fromJson(Map<String, dynamic> json) {
    return DoctorDetail(
      id: json['id'] as String? ?? '',
      profileId: json['profileId'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Doctor',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      specialty: json['specialty'] as String? ?? 'General',
      schedule: (json['schedule'] as List<dynamic>?)
              ?.map((s) => DoctorSchedule.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SlotResult {
  final List<String> availableSlots;
  final List<String> unavailableSlots;

  const SlotResult({
    required this.availableSlots,
    required this.unavailableSlots,
  });

  factory SlotResult.fromJson(Map<String, dynamic> json) {
    return SlotResult(
      availableSlots: List<String>.from(json['availableSlots'] ?? []),
      unavailableSlots: List<String>.from(json['unavailableSlots'] ?? []),
    );
  }
}
