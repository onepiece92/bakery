import 'package:bakery_flutter/models/product/hive/order_hivemodel.dart';
import 'package:intl/intl.dart';

class OrderItemAddon {
  final String id;
  final String name;
  final double price;

  const OrderItemAddon({
    required this.id,
    required this.name,
    required this.price,
  });
}

class OrderItemVariant {
  final String id;
  final List<String> optionValues;
  final double price;

  const OrderItemVariant({
    required this.id,
    required this.optionValues,
    required this.price,
  });
}

class OrderItem {
  final String name;
  final String image;
  final int qty;
  final double unitPrice;
  final double lineTotal;
  final OrderItemVariant? variant;
  final List<OrderItemAddon> addons;

  const OrderItem({
    required this.name,
    required this.image,
    required this.qty,
    required this.unitPrice,
    required this.lineTotal,
    this.variant,
    this.addons = const [],
  });

  /// Total price of all addons combined
  double get addonTotal => addons.fold(0.0, (sum, a) => sum + a.price);

  /// Effective unit price including addons
  double get effectiveUnitPrice => unitPrice + addonTotal;

  /// Variant label e.g. 'Large / Chocolate'
  String get variantLabel => variant?.optionValues.join(' / ') ?? '';

  /// Addon names joined e.g. 'Extra Butter, Jam'
  String get addonLabel => addons.map((a) => a.name).join(', ');
}

class Order {
  final String id;
  final String date;
  final List<OrderItem> items;
  final double total;
  final String status;
  final bool isBusinessOrder;

  const Order({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
    this.isBusinessOrder = false,
  });

  /// Total item count across all lines
  int get totalQty => items.fold(0, (sum, i) => sum + i.qty);

  /// Build an Order directly from a Hive OrderModel
  factory Order.fromHive(OrderModel hive) => Order(
        id: hive.orderId,
        date: DateFormat('MMM d, yyyy · h:mm a').format(hive.createdAt),
        total: hive.subtotal,
        status: hive.isBusinessOrder ? 'Business' : 'Standard',
        isBusinessOrder: hive.isBusinessOrder,
        items: hive.items.map((i) {
          // Map addons
          final addons = i.selectedAddons
              .map((a) => OrderItemAddon(
                    id: a.id,
                    name: a.name,
                    price: a.price,
                  ))
              .toList();

          // Map variant
          final variant = i.selectedVariant == null
              ? null
              : OrderItemVariant(
                  id: i.selectedVariant!.id,
                  optionValues: i.selectedVariant!.optionValues,
                  price: i.selectedVariant!.price,
                );

          return OrderItem(
            name: i.product.name,
            image: i.product.image,
            unitPrice: i.product.price,
            lineTotal: i.lineTotal,
            qty: i.quantity,
            variant: variant,
            addons: addons,
          );
        }).toList(),
      );
}