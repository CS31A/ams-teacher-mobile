// lib/utils/constants.dart
class ApiConstants {
  // For Flutter Web and Physical Device
  static const String baseUrl = 'http://192.168.254.106:8080';
  
  
  // Auth endpoints
  static const String loginEndpoint = '/api/account/login';
  static const String registerEndpoint = '/api/account/register';
  static const String refreshEndpoint = '/api/account/refresh';
  static const String logoutEndpoint = '/api/account/logout';
  
  // Section endpoints
  static const String sectionsEndpoint = '/api/sections';
  static String sectionDetailsEndpoint(int id) => '/api/sections/$id';
  static String sectionStudentsEndpoint(int id) => '/api/sections/$id/active-students';
  
  // ... rest of your endpoints
  
  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}