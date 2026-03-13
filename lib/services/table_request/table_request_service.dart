import 'package:bakery_flutter/models/services_model.dart';
import 'package:bakery_flutter/services/api_service.dart';
import 'package:flutter/cupertino.dart';

class TableRequestService {
  TableRequestService._();
  static final TableRequestService instance = TableRequestService._();
  final ApiService _api = ApiService.instance;

  static const String _endpoint = '/ticket/table-request';

  Future<TableRequestResponse> sendFoodRequest(FoodRequest request) async {
    try {
      final response = await _api.post<TableRequestResponse>(
        _endpoint,
        data: request.toJson(),
        fromJson: (json) =>
            TableRequestResponse.fromJson(json as Map<String, dynamic>),
      );

      if (response.success && response.data != null) return response.data!;
      throw Exception(response.message ?? 'Failed to send food request');
    } catch (e) {
      debugPrint("Error sending food request: $e");
      rethrow;
    }
  }

  Future<TableRequestResponse> sendWaterRequest(WaterRequest request) async {
    try {
      final response = await _api.post<TableRequestResponse>(
        _endpoint,
        data: request.toJson(),
        fromJson: (json) =>
            TableRequestResponse.fromJson(json as Map<String, dynamic>),
      );

      if (response.success && response.data != null) return response.data!;
      throw Exception(response.message ?? 'Failed to send water request');
    } catch (e) {
      debugPrint("Error sending water request: $e");
      rethrow;
    }
  }

  Future<void> sendBillRequest(BillRequest request) async {
    try {
      final response = await _api.post<void>(_endpoint, data: request.toJson());

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to send bill request');
      }
    } catch (e) {
      debugPrint("Error sending bill request: $e");
      rethrow;
    }
  }

  Future<void> sendWaiterRequest(WaiterRequest request) async {
    try {
      final response = await _api.post<void>(_endpoint, data: request.toJson());

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to send waiter request');
      }
    } catch (e) {
      debugPrint("Error sending waiter request: $e");
      rethrow;
    }
  }
}