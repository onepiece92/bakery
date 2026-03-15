import 'package:bakery_flutter/models/qr_login.dart';
import 'package:bakery_flutter/services/api_service.dart';
import 'package:flutter/cupertino.dart';

class QrLoginService {
  QrLoginService._();
  static final QrLoginService instance = QrLoginService._();
  final ApiService _api = ApiService.instance;

  Future<QrLoginModel> qrLogin({
    required String businessId,
    required String tableName,
  }) async {
    debugPrint('--- QrLoginService.qrLogin START ---');
    debugPrint('businessId : $businessId');
    debugPrint('tableName  : $tableName');

    try {
      final response = await _api.post(
        'auth/qr-login',
        data: {
          'businessId': businessId,
          'name': tableName,
        },
        fromJson: (json) => QrLoginModel.fromJson(json),
      );
      debugPrint("-----------------------------------------------");
      if (!response.success || response.data == null) {
        debugPrint('QrLoginService → FAILED: ${response.message}');
        throw Exception(response.message ?? 'QR login failed');
      }

      debugPrint('QrLoginService → SUCCESS');
      return response.data!;
    } catch (e) {
      debugPrint('QrLoginService → ERROR: $e');
      rethrow;
    }
  }
}
