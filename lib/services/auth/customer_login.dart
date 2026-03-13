import 'package:bakery_flutter/models/customerlogin_model.dart';
import 'package:bakery_flutter/services/api_service.dart';
import 'package:flutter/cupertino.dart';




class CustomerLoginService {
  CustomerLoginService._();
  static final CustomerLoginService instance = CustomerLoginService._();
  final ApiService _api = ApiService.instance;

  Future<CustomerLoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        'auth/login',
        data: {
          'emailOrPhone': email,
          'password': password,
          'type':'user'
        },
         headers: {'app': 'user'},
        fromJson: (json) => CustomerLoginResponse.fromJson(json),
      );

      if (!response.success || response.data == null) {
        debugPrint('Customer login failed: ${response.message}');
        throw Exception(response.message ?? 'Login failed');
      }

      debugPrint('Customer login successful: ${response.data!.customerName}');
      return response.data!;

    } catch (e) {
      debugPrint('Customer login error: $e');
      rethrow;
    }
  }

    Future<void> logout() async {
    try {
      final response = await _api.post(
        'auth/logout',
        data: {},
        headers: {'app': 'user'},
        fromJson: (json) => json,
      );

      if (!response.success) {
        debugPrint('Customer logout failed: ${response.message}');
        throw Exception(response.message ?? 'Logout failed');
      }

      debugPrint('Customer logout successful');

    } catch (e) {
      debugPrint('Customer logout error: $e');
      rethrow;
    }
  }
}