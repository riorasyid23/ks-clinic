import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/user_model.dart';

class UserRepository {
  final Dio _dio = DioClient.instance;

  Future<User> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '/users/$userId',
        data: data,
      );

      return User.fromJson(response.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to update profile';
      throw Exception(message);
    }
  }
}
