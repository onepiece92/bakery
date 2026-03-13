import 'package:bakery_flutter/models/category.dart';
import 'package:bakery_flutter/services/category/category_service.dart';

import 'package:flutter/material.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _service = CategoryService.instance;

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _service.fetchCategories();
    } catch (e) {
      _error = e.toString();
      debugPrint("CategoryProvider error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}