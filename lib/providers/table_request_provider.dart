import 'dart:async';

import 'package:bakery_flutter/models/services_model.dart';
import 'package:bakery_flutter/services/table_request/table_request_service.dart';
import 'package:flutter/foundation.dart';

class TableRequestProvider extends ChangeNotifier {
  final _service = TableRequestService.instance;

  bool _isLoadingWaiter = false;
  bool _isLoadingBill = false;
  bool _isLoadingWater = false;
  bool _isLoadingFood = false;

  bool get isLoadingWaiter => _isLoadingWaiter;
  bool get isLoadingBill => _isLoadingBill;
  bool get isLoadingWater => _isLoadingWater;
  bool get isLoadingFood => _isLoadingFood;

  bool get isAnyLoading =>
      _isLoadingWaiter || _isLoadingBill || _isLoadingWater || _isLoadingFood;

  static const int _cooldownDuration = 60;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;

  bool get isCoolingDown => _cooldownSeconds > 0;
  int get cooldownSeconds => _cooldownSeconds;

  TableRequestResponse? _lastResponse;
  TableRequestResponse? get lastResponse => _lastResponse;
  Map<String, dynamic>? _lastSuccessResponse;
  Map<String, dynamic>? get lastSuccessResponse => _lastSuccessResponse;

  String? _message;
  String? get message => _message;

  void clearMessage() {
    _message = null;
    notifyListeners();
  }

  // ── Cooldown logic ─────────────────────────────────────────────────────
  void _startCooldown() {
    _cooldownTimer?.cancel();
    _cooldownSeconds = _cooldownDuration;
    notifyListeners();

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds <= 0) {
        timer.cancel();
        _cooldownSeconds = 0;
      } else {
        _cooldownSeconds--;
      }
      notifyListeners();
    });
  }

  // ── Food Request ───────────────────────────────────────────────────────
  Future<void> requestFood({
    required String businessId,
    required List<FoodItemRequest> foodItems,
  }) async {
    if (isCoolingDown || _isLoadingFood) return;

    _isLoadingFood = true;
    _message = null;
    notifyListeners();

    try {
      final response = await _service.sendFoodRequest(
        FoodRequest(businessId: businessId, foodItems: foodItems),
      );
      _lastResponse = response;
      _message = response.message;
      _lastSuccessResponse = {
        'success': true,
        'ticket_id': response.ticketId,
        'ticketName': response.ticketName,
        'grandTotal': response.grandTotal,
        'isReorder': response.isReorder,
        'message': response.message,
      };
    } catch (e) {
      _message = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingFood = false;
      notifyListeners();
    }
  }

  // ── Water Request ──────────────────────────────────────────────────────
  Future<void> requestWater({
    required String businessId,
    required String tableNumber,
    // required String waterProductId,
  }) async {
    if (isCoolingDown || _isLoadingWater) return;

    _isLoadingWater = true;
    _message = null;
    notifyListeners();

    try {
      final response = await _service.sendWaterRequest(
        WaterRequest(
          businessId: businessId,
          tableNumber: tableNumber,
          // waterProductId: waterProductId,
        ),
      );
      _lastResponse = response;
      _message = response.message;
      _startCooldown();
    } catch (e) {
      _message = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingWater = false;
      notifyListeners();
    }
  }

  // ── Bill Request ───────────────────────────────────────────────────────
  Future<void> requestBill({
    required String businessId,
    required String tableNumber,
  }) async {
    if (isCoolingDown || _isLoadingBill) return;

    _isLoadingBill = true;
    _message = null;
    notifyListeners();

    try {
      await _service.sendBillRequest(BillRequest(businessId: businessId));
      _lastResponse = null;
      _message = 'BILL request sent to staff!';
      _startCooldown();
    } catch (e) {
      _message = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingBill = false;
      notifyListeners();
    }
  }

  // ── Waiter Request ─────────────────────────────────────────────────────
  Future<void> requestWaiter({
    required String businessId,
    required String tableNumber,
  }) async {
    if (isCoolingDown || _isLoadingWaiter) return;

    _isLoadingWaiter = true;
    _message = null;
    notifyListeners();

    try {
      await _service.sendWaiterRequest(
        WaiterRequest(businessId: businessId, tableNumber: tableNumber),
      );
      _lastResponse = null;
      _message = 'WAITER request sent to staff!';
      _startCooldown();
    } catch (e) {
      _message = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingWaiter = false;
      notifyListeners();
    }
  }

  // ── Cleanup ────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }
}