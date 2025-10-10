import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // For mobile device, use your computer's IP address instead of localhost
  // Your computer's IP address: 192.168.254.106
  // Backend runs HTTP on port 8080, HTTPS on port 8081
  static const String baseUrl = "http://192.168.254.106:8080/api";

  /// Login with username/email and password
  static Future<Map<String, dynamic>?> login(
      String username, String password) async {
    final url = Uri.parse("$baseUrl/account/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username.trim(),
          "password": password.trim(),
        }),
      );

      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          return data; // login success
        } else {
          return null; // login failed
        }
      } else {
        return null; // server error
      }
    } catch (e) {
      print("Error during login: $e");
      return null;
    }
  }
}