import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  // Initialize SharedPreferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  // Keys for storage
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserData = 'user_data';
  static const String _keyAuthToken = 'auth_token';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'language';

  // User data methods
  Future<bool> saveUserId(String userId) async {
    return await prefs.setString(_keyUserId, userId);
  }

  String? getUserId() {
    return prefs.getString(_keyUserId);
  }

  Future<bool> saveUserEmail(String email) async {
    return await prefs.setString(_keyUserEmail, email);
  }

  String? getUserEmail() {
    return prefs.getString(_keyUserEmail);
  }

  Future<bool> saveUserName(String name) async {
    return await prefs.setString(_keyUserName, name);
  }

  String? getUserName() {
    return prefs.getString(_keyUserName);
  }

  Future<bool> saveUserRole(String role) async {
    return await prefs.setString(_keyUserRole, role);
  }

  String? getUserRole() {
    return prefs.getString(_keyUserRole);
  }

  // Save complete user data as JSON
  Future<bool> saveUserData(Map<String, dynamic> userData) async {
    final jsonString = json.encode(userData);
    return await prefs.setString(_keyUserData, jsonString);
  }

  Map<String, dynamic>? getUserData() {
    final jsonString = prefs.getString(_keyUserData);
    if (jsonString != null) {
      return json.decode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  // Auth token methods
  Future<bool> saveAuthToken(String token) async {
    return await prefs.setString(_keyAuthToken, token);
  }

  String? getAuthToken() {
    return prefs.getString(_keyAuthToken);
  }

  // Login state methods
  Future<bool> setLoggedIn(bool isLoggedIn) async {
    return await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
  }

  bool isLoggedIn() {
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Remember me
  Future<bool> setRememberMe(bool rememberMe) async {
    return await prefs.setBool(_keyRememberMe, rememberMe);
  }

  bool getRememberMe() {
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  // Theme mode
  Future<bool> setThemeMode(String mode) async {
    return await prefs.setString(_keyThemeMode, mode);
  }

  String? getThemeMode() {
    return prefs.getString(_keyThemeMode);
  }

  // Language
  Future<bool> setLanguage(String language) async {
    return await prefs.setString(_keyLanguage, language);
  }

  String? getLanguage() {
    return prefs.getString(_keyLanguage);
  }

  // Clear all user data (for logout)
  Future<bool> clearUserData() async {
    final keys = [
      _keyUserId,
      _keyUserEmail,
      _keyUserName,
      _keyUserRole,
      _keyUserData,
      _keyAuthToken,
      _keyIsLoggedIn,
    ];

    bool success = true;
    for (final key in keys) {
      final result = await prefs.remove(key);
      if (!result) success = false;
    }
    return success;
  }

  // Clear all data
  Future<bool> clearAll() async {
    return await prefs.clear();
  }

  // Check if key exists
  bool containsKey(String key) {
    return prefs.containsKey(key);
  }

  // Generic methods for any key-value
  Future<bool> setString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  String? getString(String key) {
    return prefs.getString(key);
  }

  Future<bool> setInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return prefs.getInt(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return prefs.getBool(key);
  }

  Future<bool> setDouble(String key, double value) async {
    return await prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    return prefs.getDouble(key);
  }

  Future<bool> setStringList(String key, List<String> value) async {
    return await prefs.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return prefs.getStringList(key);
  }

  Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }
}
