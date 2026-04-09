/// Represents a clinic region from the API.
class Region {
  final String id;
  final String name;
  final String city;
  final String address;
  final String? mapUrl;
  final String? regionImgUrl;

  const Region({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    this.mapUrl,
    this.regionImgUrl,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      address: json['address'] as String,
      mapUrl: json['mapUrl'] as String?,
      regionImgUrl: json['regionImgUrl'] as String?,
    );
  }
}
