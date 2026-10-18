import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';
import '../error/exceptions.dart';

class ApiClient {
  final Dio dio;
  final SecureStorage secureStorage;

  ApiClient({required this.dio, required this.secureStorage}) {
    _configure();
  }

  void _configure() {
    dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.getAccessToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  Future<Response<T>> postForm<T>(
    String path, {
    required Map<String, dynamic> data,
  }) async {
    try {
      return await dio.post<T>(
        path,
        data: data,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.get<T>(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) async {
    try {
      return await dio.put<T>(path, data: data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<T>> delete<T>(String path, {dynamic data}) async {
    try {
      return await dio.delete<T>(path, data: data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();

      default:
        break;
    }

    final statusCode = error.response?.statusCode;

    switch (statusCode) {
      case 401:
      case 403:
        return UnauthorizedException(_extractMessage(error));

      case 404:
        return NotFoundException(_extractMessage(error));

      case 400:
      case 422:
        return ValidationException(_extractMessage(error));

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(_extractMessage(error));

      default:
        return UnknownException(_extractMessage(error));
    }
  }

  String _extractMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final detail = data['detail'];

      if (detail is String) {
        return detail;
      }

      if (detail is List) {
        return detail
            .map((item) {
              if (item is Map<String, dynamic>) {
                return item['msg']?.toString() ?? 'Validation error';
              }

              return item.toString();
            })
            .join(', ');
      }
    }

    return error.message ?? 'An unexpected error occurred.';
  }
}
