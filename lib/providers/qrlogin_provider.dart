import 'package:bakery_flutter/models/qr_login.dart';
import 'package:bakery_flutter/services/auth/qrlogin_service.dart';
import 'package:bakery_flutter/services/localstorage_service.dart';
import 'package:flutter/material.dart';

class QRLoginProvider extends ChangeNotifier {
  bool _isLoading       = false;
  String? _errorMessage;
  QrLoginModel? _data;

  bool get isLoading          => _isLoading;
  String? get errorMessage    => _errorMessage;
  QrLoginModel? get data      => _data;

  Future<void> login({
    required String businessId,
    required String tableName,
  }) async {
    debugPrint('====================================');
    debugPrint('QRLoginProvider.login START');
    debugPrint('businessId : $businessId');
    debugPrint('tableName  : $tableName');
    debugPrint('====================================');

    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await QrLoginService.instance.qrLogin(
        businessId: businessId,
        tableName:  tableName,
      );

      // Check if session already expired
      if (data.isExpired) {
        debugPrint('QRLoginProvider → session already expired at ${data.expiresAt}');
        _isLoading    = false;
        _errorMessage = 'QR code has expired. Please scan a new one.';
        notifyListeners();
        return;
      }

      debugPrint('QRLoginProvider → SUCCESS');
      debugPrint('sessionToken : ${data.sessionToken}');
      debugPrint('userId       : ${data.userId}');
      debugPrint('role         : ${data.role}');
      debugPrint('customerName : ${data.customerName}');
      debugPrint('adminId      : ${data.adminId}');
      debugPrint('businessId   : ${data.business.id}');
      debugPrint('businessName : ${data.business.name}');
      debugPrint('expiresAt    : ${data.expiresAt}');

      // Save to LocalStorage
      final storage = LocalStorageService.instance;
      await storage.saveSessionToken(data.sessionToken);
      await storage.saveUserId(data.userId);
      await storage.saveRole(data.role);
      await storage.saveCustomerName(data.customerName);
      await storage.saveAdminId(data.adminId);
      await storage.saveBusinessId(data.business.id);
      await storage.saveBusinessName(data.business.name);
      await storage.saveAddress(data.business.address);
      await storage.saveIsBusinessSession(true);
      await storage.saveSessionType('qr');

      debugPrint('QRLoginProvider → all saved to LocalStorage');

      _data      = data;
      _isLoading = false;

    } catch (e) {
      debugPrint('QRLoginProvider → ERROR: $e');
      _isLoading    = false;
      _errorMessage = 'Invalid QR code. Please scan the table QR again.';
    }

    notifyListeners();
  }

  void reset() {
    debugPrint('QRLoginProvider → reset');
    _isLoading    = false;
    _errorMessage = null;
    _data         = null;
    notifyListeners();
  }
}