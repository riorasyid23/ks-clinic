class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String avatarUrl;
  final double rating;
  final int reviewCount;
  
  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.avatarUrl,
    required this.rating,
    required this.reviewCount,
  });
}
