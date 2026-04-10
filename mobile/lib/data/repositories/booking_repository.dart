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

  /// Creates a new appointment booking.
  Future<String> createAppointment({
    required String date,
    required String startTime,
    required String reason,
    required String notes,
    required String doctorProfileId,
  }) async {
    try {
      final response = await _dio.post(
        '/encounter/patient/create',
        data: {
          'date': date,
          'startTime': startTime,
          'reason': reason,
          'notes': notes,
          'doctorProfileId': doctorProfileId,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return data['booking']['id'] as String;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to create booking';
      throw Exception(message);
    }
  }

  /// Fetches a single booking's detailed information.
  Future<Booking> getBookingDetails(String bookingId) async {
    try {
      final response = await _dio.get('/encounter/$bookingId');
      final data = response.data as Map<String, dynamic>;
      return Booking.fromJson(data['details'] as Map<String, dynamic>);
    } on DioException {
      throw Exception('Failed to load booking details');
    }
  }

  /// Cancels an existing appointment.
  Future<void> cancelAppointment(String bookingId, String note) async {
    try {
      await _dio.delete(
        '/encounter/$bookingId',
        data: {'note': note},
      );
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Failed to cancel appointment';
      throw Exception(message);
    }
  }

  /// Fetches the nearest upcoming appointment for the patient.
  Future<Booking?> getNearestAppointment() async {
    try {
      final response = await _dio.get('/encounter/patient/nearest');
      final data = response.data as Map<String, dynamic>;
      return Booking.fromJson(data['bookings'] as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to load nearest appointment');
    }
  }
}
