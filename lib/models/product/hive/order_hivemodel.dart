import 'package:bakery_flutter/models/product/hive/order_item_snapshot.dart';
import 'package:hive/hive.dart';


part 'order_hivemodel.g.dart';

@HiveType(typeId: 4)
class OrderModel extends HiveObject {
  @HiveField(0) final String orderId;
  @HiveField(1) final List<HiveOrderItemSnapshot> items;
  @HiveField(2) final double subtotal;
  @HiveField(3) final DateTime createdAt;
  @HiveField(4) final bool isBusinessOrder;

  OrderModel({
    required this.orderId,
    required this.items,
    required this.subtotal,
    required this.createdAt,
    required this.isBusinessOrder,
  });
}