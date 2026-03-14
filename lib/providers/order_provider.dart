import 'package:bakery_flutter/models/cart_item.dart';
import 'package:bakery_flutter/models/order.dart';
import 'package:bakery_flutter/services/hive_services/order_hive_services.dart';
import 'package:flutter/material.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders => _orders;
  List<Order> get recentOrders => _orders.toList();


  void loadOrders() {
    _orders = HiveOrderService.getAllOrders()
        .map((o) => Order.fromHive(o))
        .toList();
    notifyListeners();
  }

  Future<void> placeOrder({
    required List<CartItem> items,
    required double subtotal,
    required bool isBusinessOrder,
  }) async {
    final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
    await HiveOrderService.saveOrder(
      orderId: orderId,
      items: items,
      subtotal: subtotal,
      isBusinessOrder: isBusinessOrder,
    );
    loadOrders();
  }


  Future<void> deleteOrder(String orderId) async {
    await HiveOrderService.deleteOrder(orderId);
    loadOrders();
  }

  Future<void> deleteBulk(List<String> orderIds) async {
    await HiveOrderService.deleteBulk(orderIds);
    loadOrders();
  }

  Future<void> clearAll() async {
    await HiveOrderService.clearAll();
    loadOrders();
  }

  Order? getOrder(String orderId) {
    try {
      return _orders.firstWhere((o) => o.id == orderId);
    } catch (_) {
      return null;
    }
  }
}