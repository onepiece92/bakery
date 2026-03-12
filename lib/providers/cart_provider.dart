import 'package:bakery_flutter/models/cart_item.dart';
import 'package:flutter/foundation.dart';
import 'package:bakery_flutter/models/product_model.dart';


class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalCount => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal =>
      _items.fold(0.0, (sum, i) => sum + i.lineTotal);

  static const double bakingFee = 2.50;
  double get total => subtotal + bakingFee;

  bool contains(Product product) =>
      _items.any((i) => i.product.id == product.id);
      
  void addProduct(
    Product product, {
    int quantity = 1,
    VariantItem? variant,
    List<Addon> addons = const [],
  }) {
    final newItem = CartItem(
      product: product,
      selectedVariant: variant,
      selectedAddons: addons,
      quantity: quantity,
    );

    final index =
        _items.indexWhere((i) => i.lineKey == newItem.lineKey);

    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(newItem);
    }
    notifyListeners();
  }

  /// Update quantity by list index. Removes line if qty <= 0.
  void updateQuantity(int index, int qty) {
    if (qty <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = qty;
    }
    notifyListeners();
  }

  /// Update quantity by product id (for simple products with no variant).
  void updateById(String productId, int qty) {
    final index =
        _items.indexWhere((i) => i.product.id == productId);
    if (index < 0) return;
    if (qty <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = qty;
    }
    notifyListeners();
  }

  /// Update quantity by full lineKey (product + variant combo).
  void updateByLineKey(String lineKey, int qty) {
    final index = _items.indexWhere((i) => i.lineKey == lineKey);
    if (index < 0) return;
    if (qty <= 0) {
      _items.removeAt(index);
    } else {
      _items[index].quantity = qty;
    }
    notifyListeners();
  }

  void removeAt(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}