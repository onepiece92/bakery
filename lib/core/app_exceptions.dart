/// Base exception class for application errors.
/// 
/// All custom exceptions should extend this class.
abstract class AppException implements Exception {
  /// Creates an AppException with an optional message and code.
  const AppException({
    this.message,
    this.code,
  });

  /// Human-readable error message.
  final String? message;

  /// Error code for programmatic handling.
  final String? code;

  @override
  String toString() => message ?? 'An error occurred';
}

/// Exception thrown when a network error occurs.
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Network error. Please check your connection.',
    super.code = 'NETWORK_ERROR',
  });
}

/// Exception thrown when authentication fails.
class AuthException extends AppException {
  const AuthException({
    super.message = 'Authentication failed.',
    super.code = 'AUTH_ERROR',
  });
}

/// Exception thrown when the session expires.
class SessionExpiredException extends AppException {
  const SessionExpiredException({
    super.message = 'Session expired. Please login again.',
    super.code = 'SESSION_EXPIRED',
  });
}

/// Exception thrown when a refresh token is invalid or expired.
class RefreshTokenException extends AppException {
  const RefreshTokenException({
    super.message = 'Refresh token expired. Please login again.',
    super.code = 'REFRESH_TOKEN_EXPIRED',
  });
}

/// Exception thrown when server returns an error.
class ServerException extends AppException {
  const ServerException({
    super.message = 'Server error. Please try again later.',
    super.code = 'SERVER_ERROR',
    this.statusCode,
  });

  /// HTTP status code from the server.
  final int? statusCode;
}

/// Exception thrown when validation fails.
class ValidationException extends AppException {
  const ValidationException({
    super.message = 'Validation failed.',
    super.code = 'VALIDATION_ERROR',
    this.errors,
  });

  /// Map of field names to error messages.
  final Map<String, String>? errors;
}

/// Exception thrown when a resource is not found.
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Resource not found.',
    super.code = 'NOT_FOUND',
  });
}

/// Exception thrown when user doesn't have permission.
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'You do not have permission to perform this action.',
    super.code = 'UNAUTHORIZED',
  });
}

/// Exception thrown when storage operations fail.
class StorageException extends AppException {
  const StorageException({
    super.message = 'Storage error occurred.',
    super.code = 'STORAGE_ERROR',
  });
}

/// Exception thrown when biometric authentication fails.
class BiometricException extends AppException {
  const BiometricException({
    super.message = 'Biometric authentication failed.',
    super.code = 'BIOMETRIC_ERROR',
  });
}

/// Exception thrown when permission is denied.
class PermissionException extends AppException {
  const PermissionException({
    super.message = 'Permission denied.',
    super.code = 'PERMISSION_DENIED',
    this.isPermanentlyDenied = false,
  });

  /// Whether the permission is permanently denied.
  final bool isPermanentlyDenied;
}

/// Exception thrown for cache-related errors.
class CacheException extends AppException {
  const CacheException({
    super.message = 'Cache error occurred.',
    super.code = 'CACHE_ERROR',
  });
}
