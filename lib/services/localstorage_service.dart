import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  SharedPreferences? _prefs;

  static const String _keySessionToken = 'session_token';
  static const String _keyUserId = 'user_id';
  static const String _keyRole = 'role';
  static const String _keyCustomerName = "customerName";
  static const String _adminId = 'adminId';
  static const String _keyBusinessId = 'id';
  static const String _keyBusinessName = 'name';
  static const String _keyAddress = 'address';
  static const String _keyMenuIsGrid = 'menu_is_grid';
  static const String _keyFavouriteIds = 'favourite_ids';
  static const String _keyIsBusinessSession = 'is_business_session';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveSessionType(String type) async =>
      await _prefs?.setString('session_type', type);

  String? getSessionType() => _prefs?.getString('session_type');

  Future<void> saveWasSessionExpired(bool val) async =>
      await _prefs?.setBool('was_session_expired', val);

  bool getWasSessionExpired() =>
      _prefs?.getBool('was_session_expired') ?? false;

  Future<void> clearWasSessionExpired() async =>
      await _prefs?.remove('was_session_expired');
  Future<void> saveSessionToken(String token) async {
    await _prefs?.setString(_keySessionToken, token);
  }

  Future<void> saveUserId(String userId) async {
    await _prefs?.setString(_keyUserId, userId);
  }

  Future<void> saveRole(String role) async {
    await _prefs?.setString(_keyRole, role);
  }

  Future<void> saveCustomerName(String name) async {
    await _prefs?.setString(_keyCustomerName, name);
  }

  Future<void> saveAdminId(String adminId) async {
    await _prefs?.setString(_adminId, adminId);
  }

  Future<void> saveBusinessId(String id) async {
    await _prefs?.setString(_keyBusinessId, id);
  }

  Future<void> saveMenuIsGrid(bool isGrid) async {
    await _prefs?.setBool(_keyMenuIsGrid, isGrid);
  }

  bool getMenuIsGrid() => _prefs?.getBool(_keyMenuIsGrid) ?? true;
  Future<void> saveBusinessName(String name) async {
    await _prefs?.setString(_keyBusinessName, name);
  }

  Future<void> saveAddress(String address) async {
    await _prefs?.setString(_keyAddress, address);
  }

  /// GET METHODS

  String? getSessionToken() {
    return _prefs?.getString(_keySessionToken);
  }

  String? getUserId() {
    return _prefs?.getString(_keyUserId);
  }

  String? getRole() {
    return _prefs?.getString(_keyRole);
  }

  String? getCustomerName() {
    return _prefs?.getString(_keyCustomerName);
  }

  String? getAdminId() {
    return _prefs?.getString(_adminId);
  }

  String? getBusinessId() {
    return _prefs?.getString(_keyBusinessId);
  }

  String? getBusinessName() {
    return _prefs?.getString(_keyBusinessName);
  }

  String? getAddress() {
    return _prefs?.getString(_keyAddress);
  }

  Future<void> saveFavouriteIds(List<String> ids) async {
    await _prefs?.setStringList(_keyFavouriteIds, ids);
  }

  Future<void> saveIsBusinessSession(bool isBusinessSession) async {
    await _prefs?.setBool(_keyIsBusinessSession, isBusinessSession);
  }

  bool getIsBusinessSession() {
    return _prefs?.getBool(_keyIsBusinessSession) ?? true;
  }

  List<String> getFavouriteIds() {
    final result = _prefs?.getStringList(_keyFavouriteIds) ?? [];
    return result;
  }

  Future<void> clearFavouriteIds() async {
    await _prefs?.remove(_keyFavouriteIds);
  }

  /// CLEAR METHODS

  Future<void> clearSession() async {
    await _prefs?.remove(_keySessionToken);
    await _prefs?.remove(_keyUserId);
    await _prefs?.remove(_keyRole);
    await _prefs?.remove(_keyCustomerName);
    await _prefs?.remove(_adminId);
    await _prefs?.remove(_keyBusinessId);
    await _prefs?.remove(_keyBusinessName);
    await _prefs?.remove(_keyAddress);
    await _prefs?.remove(_keyIsBusinessSession);
  }

  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
