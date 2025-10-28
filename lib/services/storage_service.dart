import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _prefs.setString('accessToken', accessToken);
    await _prefs.setString('refreshToken', refreshToken);
  }

  static Future<void> saveInstructorId(String instructorId) async {
    await _prefs.setString('instructorId', instructorId);
  }

  static Future<String?> getAccessToken() async {
    return _prefs.getString('accessToken');
  }

  // Alias for getAccessToken() - used by ApiService
  static Future<String?> getToken() async {
    return getAccessToken();
  }

  static Future<String?> getRefreshToken() async {
    return _prefs.getString('refreshToken');
  }

  static Future<String?> getInstructorId() async {
    return _prefs.getString('instructorId');
  }

  static Future<void> clearTokens() async {
    await _prefs.remove('accessToken');
    await _prefs.remove('refreshToken');
  }

  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}