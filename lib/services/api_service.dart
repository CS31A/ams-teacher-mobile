import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Updated to the correct port!
  static const String baseUrl = "https://localhost:8081/api";

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