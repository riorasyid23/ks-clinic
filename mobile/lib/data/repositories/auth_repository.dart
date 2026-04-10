import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../core/network/dio_client.dart';

/// Repository that handles all authentication-related operations.
class AuthRepository {
  final Dio _dio = DioClient.instance;

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _userEmailKey = 'user_email';
  static const _userRoleKey = 'user_role';
  static const _userNameKey = 'user_name';
  static const _expiryKey = 'auth_expiry';

  /// Sends login credentials and returns a [LoginResponse] on success.
  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final loginResponse = LoginResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Persist token and basic user info locally
      await _saveSession(loginResponse);

      return loginResponse;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final msg = e.response!.data['message'] ?? 'Login failed';
        throw AuthException(msg.toString());
      }
      throw AuthException('Network error. Please check your connection.');
    }
  }

  /// Persist essential session data.
  Future<void> _saveSession(LoginResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, response.token);
    await prefs.setString(_userIdKey, response.user.id);
    await prefs.setString(_userEmailKey, response.user.email);
    await prefs.setString(_userRoleKey, response.user.role);
    if (response.user.profile != null) {
      await prefs.setString(_userNameKey, response.user.profile!.name);
    }

    // Set expiry to 1 hour from now
    final expiry = DateTime.now().add(const Duration(hours: 1));
    await prefs.setString(_expiryKey, expiry.toIso8601String());
  }

  /// Read the saved token (returns null if not logged in).
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Read saved user name for greeting.
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  /// Read session expiry time.
  Future<DateTime?> getExpiryAt() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryStr = prefs.getString(_expiryKey);
    if (expiryStr == null) return null;
    return DateTime.tryParse(expiryStr);
  }

  /// Check whether a valid session exists.
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;

    // Also check expiry
    final expiry = await getExpiryAt();
    if (expiry == null) return false;

    return DateTime.now().isBefore(expiry);
  }

  /// Clear all session data (logout).
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_expiryKey);
  }
}

/// A simple exception type for auth errors to display in the UI.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
