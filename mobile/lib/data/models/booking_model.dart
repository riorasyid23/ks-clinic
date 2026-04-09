/// Represents a doctor embedded in a booking response.
class BookingDoctor {
  final String? name;
  final String? specialty;

  const BookingDoctor({this.name, this.specialty});

  factory BookingDoctor.fromJson(Map<String, dynamic> json) {
    return BookingDoctor(
      name: json['name'] as String?,
      specialty: json['specialty'] as String?,
    );
  }
}

/// Represents a single booking/appointment from the API.
class Booking {
  final String id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String currentStatus;
  final String? reason;
  final BookingDoctor doctor;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.currentStatus,
    this.reason,
    required this.doctor,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      currentStatus: json['currentStatus'] as String,
      reason: json['reason'] as String?,
      doctor: BookingDoctor.fromJson(json['doctor'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
