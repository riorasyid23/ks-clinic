import 'package:dio/dio.dart';
import '../models/booking_model.dart';
import '../../core/network/dio_client.dart';

/// Repository for fetching patient bookings from the API.
class BookingRepository {
  final Dio _dio = DioClient.instance;

  /// Fetches all bookings for the currently authenticated patient.
  Future<List<Booking>> getPatientBookings() async {
    try {
      final response = await _dio.get('/encounter/patient');
      final data = response.data as Map<String, dynamic>;
      final bookingsJson = data['bookings'] as List<dynamic>;

      return bookingsJson
          .map((json) => Booking.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // No bookings found — not an error, just empty
        return [];
      }
      throw Exception('Failed to load bookings');
    }
  }
}
