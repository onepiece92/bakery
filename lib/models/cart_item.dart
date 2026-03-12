import 'package:equatable/equatable.dart';
import 'package:bakery_flutter/models/product_model.dart';

class CartItem extends Equatable {
  final Product product;
  final VariantItem? selectedVariant;  
  final List<Addon> selectedAddons;    
  int quantity;

  CartItem({
    required this.product,
    this.selectedVariant,
    this.selectedAddons = const [],
    this.quantity = 1,
  });
  String get lineKey {
    final variantPart = selectedVariant?.id ?? 'no_variant';
    return '${product.id}__$variantPart';
  }

  double get unitPrice =>
      selectedVariant?.price ?? product.displayPrice;
  double get addonTotal =>
      selectedAddons.fold(0.0, (sum, a) => sum + a.price);

  double get effectiveUnitPrice => unitPrice + addonTotal;
  double get lineTotal => effectiveUnitPrice * quantity;
  List<String> get tags => product.tags;
  List<String> get variantLabels => selectedVariant?.optionValues ?? [];

  @override
  List<Object?> get props => [product.id, selectedVariant?.id];
}