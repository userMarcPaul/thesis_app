import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/";

  static Future<void> syncUser({
    required String uid,
    required String email,
    required String role,
  }) async {
    final url = Uri.parse("${baseUrl}api/users/sync/");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "uid": uid,
        "email": email,
        "role": role,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to sync user: ${response.body}");
    }
  }

  
}
