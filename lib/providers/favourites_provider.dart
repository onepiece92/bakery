import 'package:bakery_flutter/services/localstorage_service.dart';
import 'package:flutter/material.dart';

class FavouritesProvider extends ChangeNotifier {
  FavouritesProvider() {
    loadFavourites();
  }
  
  final Set<String> _favourites = {};

  Set<String> get favourites => Set.unmodifiable(_favourites);

  bool isFavourite(String productId) => _favourites.contains(productId);

  Future<void> loadFavourites() async {

    final saved = LocalStorageService.instance.getFavouriteIds();
    debugPrint(saved.toList().toString());
    debugPrint("---------------FAVOURITES-----------------");
    
    _favourites
      ..clear()
      ..addAll(saved);

    notifyListeners();
  }

  void toggle(String productId) {
    if (_favourites.contains(productId)) {
      _favourites.remove(productId);
    } else {
      _favourites.add(productId);
    }

    LocalStorageService.instance.saveFavouriteIds(_favourites.toList());
    notifyListeners();
  }
}