import 'package:bakery_flutter/models/product/hive/addon_snapshot.dart';
import 'package:bakery_flutter/models/product/hive/order_hivemodel.dart';
import 'package:bakery_flutter/models/product/hive/order_item_snapshot.dart';
import 'package:bakery_flutter/models/product/hive/product_snapshot.dart';
import 'package:bakery_flutter/models/product/hive/variant_snapshot.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bakery_flutter/models/cart_item.dart';

class HiveOrderService {
  static const String _boxName = 'orders';

  static Box<OrderModel> get _box => Hive.box<OrderModel>(_boxName);

  static Future<void> openBox() async {
    await Hive.openBox<OrderModel>(_boxName);
  }
  static Future<void> saveOrder({
    required String orderId,
    required List<CartItem> items,
    required double subtotal,
    required bool isBusinessOrder,
  }) async {
    final snapshots = items.map((item) {
      final addonSnapshots = item.selectedAddons
          .map((a) => HiveAddonSnapshot(
                id: a.id,
                name: a.name,
                price: a.price,
              ))
          .toList();

      final variantSnapshot = item.selectedVariant == null
          ? null
          : HiveVariantSnapshot(
              id: item.selectedVariant!.id,
              optionValues: item.selectedVariant!.optionValues,
              price: item.selectedVariant!.price,
            );
      final productSnapshot = HiveProductSnapshot(
        id: item.product.id,
        name: item.product.name,
        image: item.product.image,
        price: item.product.price,
        categories: item.product.categories,
      );

      return HiveOrderItemSnapshot(
        product: productSnapshot,
        selectedVariant: variantSnapshot,
        selectedAddons: addonSnapshots,
        quantity: item.quantity,
        lineTotal: item.lineTotal,
      );
    }).toList();

    final order = OrderModel(
      orderId: orderId,
      items: snapshots,
      subtotal: subtotal,
      createdAt: DateTime.now(),
      isBusinessOrder: isBusinessOrder,
    );

    await _box.put(orderId, order);
  }

  static List<OrderModel> getAllOrders() {
    final orders = _box.values.toList();
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }
  static OrderModel? getOrder(String orderId) {
    return _box.get(orderId);
  }

  static Future<void> deleteOrder(String orderId) async {
    await _box.delete(orderId);
  }
  static Future<void> deleteBulk(List<String> orderIds) async {
    await _box.deleteAll(orderIds);
  }
  static Future<void> clearAll() async {
    await _box.clear();
  }
}