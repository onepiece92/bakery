import 'package:bakery_flutter/services/api_service.dart';
import 'package:flutter/cupertino.dart';

class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();
  final ApiService _api = ApiService.instance;

  Future<Map<String, dynamic>> fetchProfile() async {
    try {
      final response = await _api.get('auth/me');

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to fetch profile');
      }

      final data = response.data!;

      return {
        'id': data['_id'],
        'name': data['name'],
        'phone': data['phone'],
        'email': data['email'],
        'role': data['role'],
      };
    } catch (e) {
      debugPrint('fetchProfile error: $e');
      throw Exception('fetchProfile error: $e');
    }
  }
}