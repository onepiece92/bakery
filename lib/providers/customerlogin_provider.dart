import 'package:bakery_flutter/models/customerlogin_model.dart';
import 'package:bakery_flutter/services/auth/customer_login.dart';
import 'package:bakery_flutter/services/localstorage_service.dart';
import 'package:flutter/material.dart';

class CustomerLoginProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  CustomerLoginResponse? _data;
  bool get isLoggedIn => _data != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CustomerLoginResponse? get data => _data;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    debugPrint('====================================');
    debugPrint('CustomerLoginProvider.login START');
    debugPrint('email : $email');
    debugPrint('====================================');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await CustomerLoginService.instance.login(
        email: email,
        password: password,
      );

      debugPrint('CustomerLoginProvider → SUCCESS');
      debugPrint('sessionToken : ${data.sessionToken}');
      debugPrint('userId       : ${data.userId}');
      debugPrint('customerName : ${data.customerName}');

      // Save to LocalStorage
      final storage = LocalStorageService.instance;
      await storage.saveSessionToken(data.sessionToken);
      await storage.saveUserId(data.userId);
      await storage.saveCustomerName(data.customerName);
      await storage.saveSessionType('customer');
      await storage.saveIsBusinessSession(false);

      debugPrint('CustomerLoginProvider → all saved to LocalStorage');

      _data = data;
      _isLoading = false;
    } catch (e) {
      debugPrint('CustomerLoginProvider → ERROR: $e');
      _isLoading = false;
      _errorMessage = 'Invalid email or password. Please try again.';
    }

    notifyListeners();
  }

  // ── LOGOUT ──────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    debugPrint('====================================');
    debugPrint('CustomerLoginProvider.logout START');
    debugPrint('====================================');

    _isLoading = true;
    notifyListeners();

    try {
      final storage = LocalStorageService.instance;
      await storage
          .clearAll(); // clears token, userId, customerName, sessionType, isBusinessSession

      debugPrint('CustomerLoginProvider → LocalStorage cleared');
    } catch (e) {
      debugPrint('CustomerLoginProvider → logout ERROR: $e');
    }

    _data = null;
    _errorMessage = null;
    _isLoading = false;

    debugPrint('CustomerLoginProvider → logout COMPLETE');
    notifyListeners();
  }
  // ────────────────────────────────────────────────────────────────────────────

  void reset() {
    debugPrint('CustomerLoginProvider → reset');
    _isLoading = false;
    _errorMessage = null;
    _data = null;
    notifyListeners();
  }
}
