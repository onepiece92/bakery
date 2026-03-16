import 'package:bakery_flutter/services/localstorage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
  });

  final bool success;
  final T? data;
  final String? message;
  final Map<String, dynamic>? errors;

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(success: true, data: data, message: message);
  }

  factory ApiResponse.error(String message, {Map<String, dynamic>? errors}) {
    return ApiResponse(success: false, message: message, errors: errors);
  }
}

class ApiService {
  ApiService._() {
    _initDio();
  }

  static final ApiService instance = ApiService._();
  late final Dio _dio;

  static const String _baseUrl = 'https://api.order.rebuzzpos.com/api/';
  static const Duration _connectionTimeout = Duration(seconds: 30);
  static const Duration _receiveTimeout = Duration(seconds: 30);


  Function? onLogout;

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: _connectionTimeout,
        receiveTimeout: _receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _dio.interceptors.addAll([
      _AuthInterceptor(this),
      _LoggingInterceptor(),
    ]);
  }


  Future<void> handleLogout() async {
    onLogout?.call();
  }
  // ── HTTP METHODS ──────────────────────────────────────────────────────────
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: headers != null ? Options(headers: headers) : null,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalFields,
    T Function(dynamic)? fromJson,
    void Function(int, int)? onProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (additionalFields != null) ...additionalFields,
      });
      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onProgress,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // ── RESPONSE HANDLERS ─────────────────────────────────────────────────────

  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data;
      if (fromJson != null && data != null) {
        return ApiResponse.success(fromJson(data));
      }
      return ApiResponse.success(data as T);
    }
    return ApiResponse.error(response.data?['message'] ?? 'Request failed');
  }

  ApiResponse<T> _handleError<T>(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResponse.error('Connection timeout. Please try again.');
      case DioExceptionType.connectionError:
        return ApiResponse.error('Network error. Please check your connection.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Request failed';
        final errors = error.response?.data?['errors'];
        if (statusCode == 401) return ApiResponse.error('Unauthorized. Please login again.');
        if (statusCode == 403) return ApiResponse.error('You do not have permission.');
        if (statusCode == 404) return ApiResponse.error('Resource not found.');
        if (statusCode == 422) return ApiResponse.error(message, errors: errors);
        if (statusCode != null && statusCode >= 500) {
          return ApiResponse.error('Server error. Please try again later.');
        }
        return ApiResponse.error(message);
      case DioExceptionType.cancel:
        return ApiResponse.error('Request cancelled.');
      default:
        return ApiResponse.error('An unexpected error occurred.');
    }
  }
}

// ── Auth Interceptor ──────────────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._apiService);
  final ApiService _apiService;

  static const _noAuthEndpoints = [
    '/auth/login',
    '/auth/register',
    '/auth/forgot-password',
    '/auth/verify-otp',
    '/auth/refresh',
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_noAuthEndpoints.any((e) => options.path.contains(e))) {
      final token = LocalStorageService.instance.getSessionToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      await _apiService.handleLogout();
    }
    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }
}

// ── Logging Interceptor ───────────────────────────────────────────────────────

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('🌐 API Request: ${options.method} ${options.path}');
    debugPrint('📤 Headers: ${options.headers}');
    if (options.data != null) debugPrint('📦 Body: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
    debugPrint('📥 Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('❌ API Error: ${err.response?.statusCode} ${err.requestOptions.path}');
    debugPrint('📛 Error: ${err.message}');
    handler.next(err);
  }
}