import 'package:equatable/equatable.dart';
import 'package:bakery_flutter/models/product/product_model.dart';

class CartItem extends Equatable {
  final String cartItemId;
  final Product product;
  final VariantItem? selectedVariant;
  List<Addon> selectedAddons;
  int quantity;
  String? note;

  CartItem({
    String? cartItemId,
    required this.product,
    this.selectedVariant,
    List<Addon>? selectedAddons,
    this.quantity = 1,
    this.note,
  })  : selectedAddons = selectedAddons ?? [],
        cartItemId = cartItemId ??
            '${product.id}__${selectedVariant?.id ?? 'no_variant'}__${DateTime.now().microsecondsSinceEpoch}';

  String get lineKey {
    final variantPart = selectedVariant?.id ?? 'no_variant';
    return '${product.id}__$variantPart';
  }

  double get unitPrice => selectedVariant?.price ?? product.displayPrice;
  double get addonTotal => selectedAddons.fold(0.0, (sum, a) => sum + a.price);
  double get effectiveUnitPrice => unitPrice + addonTotal;
  double get lineTotal => effectiveUnitPrice * quantity;
  List<String> get tags => product.tags;
  List<String> get variantLabels => selectedVariant?.optionValues ?? [];

  @override
  List<Object?> get props => [product.id, selectedVariant?.id];
}
