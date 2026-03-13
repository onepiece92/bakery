import 'package:bakery_flutter/services/localstorage_service.dart';
import 'package:flutter/foundation.dart';

class ViewModeProvider extends ChangeNotifier {
  bool _isGrid;

  ViewModeProvider()
      : _isGrid = LocalStorageService.instance.getMenuIsGrid();

  bool get isGrid => _isGrid;

  void toggle() {
    _isGrid = !_isGrid;
    LocalStorageService.instance.saveMenuIsGrid(_isGrid);
    notifyListeners();
  }

  void setGrid(bool value) {
    if (_isGrid == value) return;
    _isGrid = value;
    LocalStorageService.instance.saveMenuIsGrid(_isGrid);
    notifyListeners();
  }
}