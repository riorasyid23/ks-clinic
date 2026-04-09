/// Represents a doctor from the GET /doctors API.
class DoctorResult {
  final String id;
  final String name;
  final String specialty;
  final String? profileImgUrl;
  final String? region;
  final String? city;
  final String? userEmail;

  const DoctorResult({
    required this.id,
    required this.name,
    required this.specialty,
    this.profileImgUrl,
    this.region,
    this.city,
    this.userEmail,
  });

  factory DoctorResult.fromJson(Map<String, dynamic> json) {
    return DoctorResult(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      profileImgUrl: json['profileImgUrl'] as String?,
      region: json['region'] as String?,
      city: json['city'] as String?,
      userEmail: json['userEmail'] as String?,
    );
  }
}
