import 'package:bakery_flutter/models/category.dart';
import 'package:bakery_flutter/services/api_service.dart';
import 'package:flutter/cupertino.dart';

class CategoryService {
  CategoryService._();
  static final CategoryService instance = CategoryService._();
  final ApiService _api = ApiService.instance;

Future<List<Category>> fetchCategories() async {
  try {
    const String businessId = "698c89dd6f97647ce9de2194";

    final response = await _api.get(
      'businesses/$businessId/products/categories',
    );

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to fetch categories');
    }

    final Map<String, dynamic> data = response.data as Map<String, dynamic>;
    final List<dynamic> categoriesList = data['categories'] as List<dynamic>;

    return categoriesList
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    debugPrint("Error fetching categories: $e");
    throw Exception("Failed to fetch categories: $e");
  }
}
}