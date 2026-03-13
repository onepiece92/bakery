import 'package:bakery_flutter/models/product/product_model.dart';
import 'package:bakery_flutter/services/products/product_service.dart';
import 'package:flutter/foundation.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService.instance;

  List<Product> _products = [];
  List<Product> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _productService.fetchProducts();
    } catch (e) {
      _error = e.toString();
      debugPrint("ProductProvider fetchProducts error: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Product> filteredProducts({
    required String category,
    required String searchQuery,
    required String sortBy,
  }) {
    List<Product> list = category == 'all'
        ? List.of(_products)
        : _products.where((p) => p.categories == category).toList();

    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.description.toLowerCase().contains(q) ||
            p.categories.toLowerCase().contains(q) ||
            p.tags.any((t) => t.toLowerCase().contains(q));
      }).toList();
    }

    switch (sortBy) {
      case 'price_low':
        list.sort((a, b) => a.displayPrice.compareTo(b.displayPrice));
        break;
      case 'price_high':
        list.sort((a, b) => b.displayPrice.compareTo(a.displayPrice));
        break;
      case 'popular':
        list.sort((a, b) => b.orderedCount.compareTo(a.orderedCount));
        break;
    }

    return list;
  }
}