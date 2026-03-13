import 'package:bakery_flutter/services/profile/profile_service.dart';
import 'package:flutter/foundation.dart';

enum ProfileState { initial, loading, loaded, error }

class ProfileProvider extends ChangeNotifier {
  final ProfileService _service = ProfileService.instance;

  ProfileState _state = ProfileState.initial;
  Map<String, dynamic>? _profile;
  String? _errorMessage;

  ProfileState get state => _state;
  Map<String, dynamic>? get profile => _profile;
  String? get errorMessage => _errorMessage;


  String get name => _profile?['name'] ?? '';
  String get email => _profile?['email'] ?? '';
  String get phone => _profile?['phone'] ?? '';
  String get role => _profile?['role'] ?? '';
  String get id => _profile?['id'] ?? '';

  bool get isLoading => _state == ProfileState.loading;
  bool get hasError => _state == ProfileState.error;
  bool get isLoaded => _state == ProfileState.loaded;

  Future<void> fetchProfile() async {
    _state = ProfileState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _service.fetchProfile();
      _state = ProfileState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ProfileState.error;
    } finally {
      notifyListeners();
    }
  }

  void clearProfile() {
    _profile = null;
    _state = ProfileState.initial;
    _errorMessage = null;
    notifyListeners();
  }
}