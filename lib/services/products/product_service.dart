import 'package:bakery_flutter/models/product/product_model.dart';
import 'package:bakery_flutter/services/api_service.dart';
import 'package:flutter/cupertino.dart';

class ProductService {
  ProductService._();
  static final ProductService instance = ProductService._();
  final ApiService _api = ApiService.instance;

  Future<List<Product>> fetchProducts() async {
    try {
      String businessId = "698c89dd6f97647ce9de2194";

      final response = await _api.get<Map<String, dynamic>>(
        'businesses/$businessId/products',
      );

      if (!response.success) {
        throw Exception(response.message ?? 'Failed to fetch products');
      }

      final data = response.data!;
      final productData = data['products'] as List<dynamic>;
      final products = productData
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();

      debugPrint("--------------------------------------");
      debugPrint(products.toString());

      return products;
    } catch (e) {
      debugPrint("Error fetching products: $e");
      throw Exception("Failed to fetch products: $e");
    }
  }
}