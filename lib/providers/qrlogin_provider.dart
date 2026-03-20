import 'package:bakery_flutter/models/qr_login.dart';
import 'package:bakery_flutter/services/api_service.dart';
import 'package:bakery_flutter/services/auth/qrlogin_service.dart';
import 'package:bakery_flutter/services/localstorage_service.dart';
import 'package:flutter/material.dart';

class QRLoginProvider extends ChangeNotifier {
  final QrLoginService _qrLoginService = QrLoginService.instance;
  bool _isLoading = false;
  String? _errorMessage;
  QrLoginModel? _data;
  String? businessName;

  bool get isLoading => _isLoading;
  String? get getbusinessName => businessName;
  String? get errorMessage => _errorMessage;
  QrLoginModel? get data => _data;
  QRLoginProvider() {
    final existing = ApiService.instance.onLogout;
    ApiService.instance.onLogout = () {
      existing?.call();
      final loginType = LocalStorageService.instance.getSessionType();
      if (loginType == 'qr') logout();
    };
  }
  Future<void> login({
    required String businessId,
    required String tableName,
  }) async {
    debugPrint('====================================');
    debugPrint('QRLoginProvider.login START');
    debugPrint('businessId : $businessId');
    debugPrint('tableName  : $tableName');
    debugPrint('====================================');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _qrLoginService.qrLogin(
        businessId: businessId,
        tableName: tableName,
      );
      if (data.isExpired) {
        debugPrint(
            'QRLoginProvider → session already expired at ${data.expiresAt}');
        _isLoading = false;
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
      businessName = data.business.name;

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

      _data = data;
      _isLoading = false;
    } catch (e) {
      debugPrint('QRLoginProvider → ERROR: $e');
      _isLoading = false;
      _errorMessage = 'Invalid QR code. Please scan the table QR again.';
    }

    notifyListeners();
  }
  Future<void> logout() async {
    await LocalStorageService.instance.clearSession();
    _data = null;
    notifyListeners();
  }
  void reset() {
    debugPrint('QRLoginProvider → reset');
    _isLoading = false;
    _errorMessage = null;
    _data = null;
    notifyListeners();
  }
}
