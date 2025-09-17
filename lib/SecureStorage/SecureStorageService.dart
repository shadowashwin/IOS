import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Save entire response map as JSON string
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final jsonString = jsonEncode(userData);
    await _storage.write(key: 'user_data', value: jsonString);
  }

  // Retrieve the saved user data
  Future<Map<String, dynamic>?> getUserData() async {
    final jsonString = await _storage.read(key: 'user_data');
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // Delete user data
  Future<void> clearUserData() async {
    await _storage.delete(key: 'user_data');
  }
}
