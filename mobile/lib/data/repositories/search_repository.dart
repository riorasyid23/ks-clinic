import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import '../models/region_model.dart';
import '../models/doctor_result_model.dart';
import '../models/doctor_detail_model.dart';
import '../../core/network/dio_client.dart';

/// Repository for fetching regions and doctors from the API.
class SearchRepository {
  final Dio _dio = DioClient.instance;

  /// Fetches all available clinic regions.
  Future<List<Region>> getRegions() async {
    try {
      final response = await _dio.get('/regions');
      final data = response.data as Map<String, dynamic>;
      final regionsJson = data['data'] as List<dynamic>;

      return regionsJson
          .map((json) => Region.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException {
      throw Exception('Failed to load regions');
    }
  }

  /// Fetches doctors with optional filters.
  ///
  /// [regionId] - filter by region ID
  /// [specialties] - comma-separated list of specialties (e.g. "Neurology,Surgery")
  /// [availableToday] - 1 for available today, 0 or null for no filter
  Future<List<DoctorResult>> getDoctors({
    String? regionId,
    String? specialties,
    bool availableToday = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (regionId != null && regionId.isNotEmpty) {
        queryParams['regionId'] = regionId;
      }
      if (specialties != null && specialties.isNotEmpty) {
        queryParams['specialty'] = specialties;
      }
      if (availableToday) {
        queryParams['availableToday'] = '1';
      }

      final response = await _dio.get('/doctors', queryParameters: queryParams);
      final data = response.data as Map<String, dynamic>;
      final doctorsJson = data['doctors'] as List<dynamic>;

      return doctorsJson
          .map((json) => DoctorResult.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException {
      throw Exception('Failed to load doctors');
    }
  }

  /// Fetches detailed information about a doctor by their ID.
  Future<DoctorDetail> getDoctorDetails(String doctorId) async {
    try {
      final response = await _dio.get('/doctors/$doctorId');
      final data = response.data as Map<String, dynamic>;
      final doctorDetailsJson = data['doctorDetails'] as Map<String, dynamic>;

      return DoctorDetail.fromJson(doctorDetailsJson);
    } on DioException {
      debugPrint('Failed to load doctor details');
      throw Exception('Failed to load doctor details');
    }
  }

  /// Fetches available and unavailable slots for a doctor on a specific date.
  Future<SlotResult> getDoctorSlots({
    required String doctorProfileId,
    required String date,
  }) async {
    try {
      final response = await _dio.get(
        '/doctors/slots',
        queryParameters: {'doctorProfileId': doctorProfileId, 'date': date},
      );
      return SlotResult.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Return empty slots if no schedule is found for that day
        return const SlotResult(availableSlots: [], unavailableSlots: []);
      }
      throw Exception('Failed to load available slots');
    }
  }
}
