import 'package:bakery_flutter/models/product/hive/addon_snapshot.dart';
import 'package:bakery_flutter/models/product/hive/product_snapshot.dart';
import 'package:bakery_flutter/models/product/hive/variant_snapshot.dart';
import 'package:hive/hive.dart';


part 'order_item_snapshot.g.dart';

@HiveType(typeId: 3)
class HiveOrderItemSnapshot extends HiveObject {
  @HiveField(0) final HiveProductSnapshot product;
  @HiveField(1) final HiveVariantSnapshot? selectedVariant;
  @HiveField(2) final List<HiveAddonSnapshot> selectedAddons;
  @HiveField(3) final int quantity;
  @HiveField(4) final double lineTotal;
  @HiveField(5) final String? note;

  HiveOrderItemSnapshot({
    required this.product,
    this.selectedVariant,
    required this.selectedAddons,
    required this.quantity,
    required this.lineTotal,
    this.note,
  });
}