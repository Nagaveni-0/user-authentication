// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/auth';

  // Register a new user. Returns the decoded response {token, user}.
  static Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data.toString());
    }
  }

  // Log in an existing user. Returns the decoded response {token, user}.
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data.toString());
    }
  }

  // Fetch the logged-in user's profile using the token.
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  // Update the logged-in user's profile using the token.
  static Future<Map<String, dynamic>> updateProfile(
      String token, Map<String, dynamic> fields) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(fields),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update profile');
    }
  }
}