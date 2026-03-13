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
    return ApiResponse(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String message, {Map<String, dynamic>? errors}) {
    return ApiResponse(
      success: false,
      message: message,
      errors: errors,
    );
  }
}

/// API Service for making HTTP requests.
///
/// Handles all API communication with proper error handling
/// and token management through interceptors.
class ApiService {
  ApiService._() {
    _initDio();
  }

  /// Singleton instance.
  static final ApiService instance = ApiService._();

  late final Dio _dio;

  /// Base URL for API requests.
  static const String _baseUrl = 'https://api.order.rebuzzpos.com/api/';

  /// Connection timeout duration.
  static const Duration _connectionTimeout = Duration(seconds: 30);

  /// Receive timeout duration.
  static const Duration _receiveTimeout = Duration(seconds: 30);

  /// Callback for handling logout when token is invalid.
  Function? onLogout;

  /// Initializes Dio with base configuration and interceptors.
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

  /// Gets the access token from storage.
  String? _getAccessToken() {
    return LocalStorageService.instance.getSessionToken();
  }

  /// Gets the refresh token from storage.
  String? _getRefreshToken() {
    return LocalStorageService.instance.getSessionToken(); // TODO: replace with actual refresh token getter
  }

  /// Handles logout — clears session and calls onLogout callback.
  Future<void> handleLogout() async {
    debugPrint('====================================');
    debugPrint('HANDLE LOGOUT — clearing session');
    debugPrint('====================================');
    await LocalStorageService.instance.clearSession();
    onLogout?.call();
  }

  /// Refreshes the access token — CUSTOMER ONLY.
  Future<bool> refreshToken() async {
    debugPrint('--- refreshToken START ---');
    try {
      final refreshToken = _getRefreshToken();
      if (refreshToken == null) {
        debugPrint('refreshToken → no refresh token found');
        return false;
      }

      // Use a clean Dio instance to avoid interceptor loops
      final dio = Dio(BaseOptions(
        baseUrl: _baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken  = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];

        if (newAccessToken != null) {
          await LocalStorageService.instance.saveSessionToken(newAccessToken);
          debugPrint('refreshToken → new access token saved');
        }
        if (newRefreshToken != null) {
          await LocalStorageService.instance.saveSessionToken(newRefreshToken); // TODO: replace with saveRefreshToken when ready
          debugPrint('refreshToken → new refresh token saved');
        }

        debugPrint('refreshToken → SUCCESS');
        return true;
      }

      debugPrint('refreshToken → FAILED: status ${response.statusCode}');
      return false;

    } catch (e) {
      debugPrint('refreshToken → ERROR: $e');
      return false;
    }
  }

  // ── HTTP METHODS ───────────────────────────────────────────────────────────

  /// Performs a GET request.
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// Performs a POST request.
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
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

  /// Performs a PUT request.
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

  /// Performs a PATCH request.
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

  /// Performs a DELETE request.
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

  /// Uploads a file.
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

  // ── RESPONSE HANDLERS ──────────────────────────────────────────────────────

  /// Handles successful API response.
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
    return ApiResponse.error(
      response.data?['message'] ?? 'Request failed',
    );
  }

  /// Handles API errors.
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
        final message    = error.response?.data?['message'] ?? 'Request failed';
        final errors     = error.response?.data?['errors'];
        if (statusCode == 401) {
          return ApiResponse.error('Unauthorized. Please login again.');
        }
        if (statusCode == 403) {
          return ApiResponse.error('You do not have permission.');
        }
        if (statusCode == 404) {
          return ApiResponse.error('Resource not found.');
        }
        if (statusCode == 422) {
          return ApiResponse.error(message, errors: errors);
        }
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

// ── Auth Interceptor ───────────────────────────────────────────────────────

/// Handles token injection and session-based refresh logic.
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._apiService);

  final ApiService _apiService;
  bool _isRefreshing = false;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    final noAuthEndpoints = [
      '/auth/login',
      '/auth/register',
      '/auth/forgot-password',
      '/auth/verify-otp',
      '/auth/refresh',
    ];

    if (!noAuthEndpoints.any((e) => options.path.contains(e))) {
      final token = LocalStorageService.instance.getSessionToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      final sessionType = LocalStorageService.instance.getSessionType();

      debugPrint('====================================');
      debugPrint('401 INTERCEPTED');
      debugPrint('sessionType : $sessionType');
      debugPrint('====================================');

      if (sessionType == 'manual') {
        // ── CUSTOMER: try refresh token ────────────────
        debugPrint('Customer session → trying refresh token');
        final refreshed = await _apiService.refreshToken();
        _isRefreshing = false;

        if (refreshed) {
          debugPrint('Refresh SUCCESS → retrying original request');
          try {
            final token = LocalStorageService.instance.getSessionToken();
            err.requestOptions.headers['Authorization'] = 'Bearer $token';
            final dio      = Dio();
            final response = await dio.fetch(err.requestOptions);
            handler.resolve(response);
            return;
          } catch (e) {
            debugPrint('Retry FAILED → logging out');
            await _apiService.handleLogout();
          }
        } else {
          debugPrint('Refresh FAILED → logging out');
          await _apiService.handleLogout();
        }

      } else {
        // ── BUSINESS / GUEST: no refresh → logout directly
        debugPrint('Business/Guest session → no refresh → logout directly');
        _isRefreshing = false;
        await _apiService.handleLogout();
      }
    }

    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }
}

// ── Logging Interceptor ────────────────────────────────────────────────────

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('🌐 API Request: ${options.method} ${options.path}');
    debugPrint('📤 Headers: ${options.headers}');
    if (options.data != null) {
      debugPrint('📦 Body: ${options.data}');
    }
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