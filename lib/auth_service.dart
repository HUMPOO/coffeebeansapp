import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://localhost:8090'; // PocketBase URL

  // Sign in and retrieve role
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/auth-via-email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identity': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      var role = result['user']['role']; // Assuming PocketBase returns the user role
      return {'token': result['token'], 'role': role};
    } else {
      print('Failed to sign in: ${response.body}');
      return null;
    }
  }

  // Sign up
  Future<bool> signUp(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/collections/users/records'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return response.statusCode == 201;
  }
}
