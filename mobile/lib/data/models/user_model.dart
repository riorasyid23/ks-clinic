/// Represents a user profile from the API.
class UserProfile {
  final String id;
  final String name;
  final String phoneNumber;
  final String? profileImgUrl;
  final String userId;
  final double? height;
  final double? weight;
  final String? bloodType;
  final String? dateOfBirth;

  const UserProfile({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.profileImgUrl,
    required this.userId,
    this.height,
    this.weight,
    this.bloodType,
    this.dateOfBirth,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      profileImgUrl: json['profileImgUrl'] as String?,
      userId: json['userId'] as String,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      bloodType: json['bloodType'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
    );
  }
}

/// Represents a user returned from the login API.
class User {
  final String id;
  final String email;
  final String role;
  final UserProfile? profile;

  const User({
    required this.id,
    required this.email,
    required this.role,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// The full response from the login endpoint.
class LoginResponse {
  final String message;
  final String token;
  final User user;

  const LoginResponse({
    required this.message,
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] as String,
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
