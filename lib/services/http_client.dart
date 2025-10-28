// lib/services/http_client.dart
import 'package:http/http.dart' as http;

class HttpClientService {
  static http.Client getClient() {
    return http.Client();
  }
}