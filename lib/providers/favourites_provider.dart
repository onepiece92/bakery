import 'package:flutter/foundation.dart';

class FavouritesProvider extends ChangeNotifier {
  final Set<String> _favourites = {};

  Set<String> get favourites => Set.unmodifiable(_favourites);

  bool isFavourite(String productId) => _favourites.contains(productId);

  void toggle(String productId) {
    if (_favourites.contains(productId)) {
      _favourites.remove(productId);
    } else {
      _favourites.add(productId);
    }
    notifyListeners();
  }
}