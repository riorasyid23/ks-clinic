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

/// Represents a status update in the booking timeline.
class BookingStatusUpdate {
  final String id;
  final String status;
  final String note;
  final String createdBy;
  final DateTime createdAt;

  const BookingStatusUpdate({
    required this.id,
    required this.status,
    required this.note,
    required this.createdBy,
    required this.createdAt,
  });

  factory BookingStatusUpdate.fromJson(Map<String, dynamic> json) {
    return BookingStatusUpdate(
      id: json['id'] as String,
      status: json['status'] as String,
      note: json['note'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
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
  final String? notes;
  final BookingDoctor doctor;
  final DateTime createdAt;
  final List<BookingStatusUpdate> statusTimeline;

  const Booking({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.currentStatus,
    this.reason,
    this.notes,
    required this.doctor,
    required this.createdAt,
    this.statusTimeline = const [],
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      currentStatus: json['currentStatus'] as String,
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      doctor: BookingDoctor.fromJson(json['doctor'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      statusTimeline: (json['statusTimeline'] as List<dynamic>?)
              ?.map((t) => BookingStatusUpdate.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
