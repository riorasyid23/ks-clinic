import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';

class DoctorRepository {
  final Dio _dio = DioClient.instance;

  String _errorMessage(DioException e, String defaultMsg) {
    if (e.response?.data is Map) {
      final data = e.response!.data as Map;
      return data['message'] ??
          (data['error'] is Map ? data['error']['message'] : defaultMsg);
    }
    return defaultMsg;
  }

  Future<Map<String, dynamic>> getInsights() async {
    try {
      final response = await _dio.get('/insights');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Failed to fetch doctor insights'));
    }
  }

  Future<List<dynamic>> getDoctorAppointments() async {
    try {
      final response = await _dio.get('/encounter/doctor');
      if (response.data is! Map) throw Exception('Invalid response format');
      return response.data['bookings'] as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Failed to fetch appointments'));
    }
  }

  Future<List<dynamic>> getDoctorSchedules(String doctorId) async {
    try {
      final response = await _dio.get('/doctors/schedules/$doctorId');
      if (response.data is! Map) throw Exception('Invalid response format');
      return response.data['schedules'] as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Failed to fetch doctor schedules'));
    }
  }
  Future<void> addDoctorSchedule(Map<String, dynamic> data) async {
    try {
      await _dio.post('/doctors/schedules', data: data);
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, 'Failed to add doctor schedule'));
    }
  }
}
