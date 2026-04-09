import 'package:dio/dio.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.medisify.com/v1', // Placeholder base url
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add token here if available
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );

  static Dio get instance => _dio;
}
