import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = "http://192.168.100.17:3000"; // Ensure this is the correct backend URL
  final storage = FlutterSecureStorage();

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
    String? address,
    int? age,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final Map<String, dynamic> requestBody = {
      "name": name,
      "email": email,
      "password": password,
      "Phone_number": phoneNumber,
      "Address": address,
      "Age": age,
    };

    print("🔹 Registering user: $requestBody");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print("🔹 Register Response Code: ${response.statusCode}");
      print("🔹 Register Response Body: ${response.body}");

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('❌ Failed to register user: ${response.body}');
      }
    } catch (e) {
      print("❌ Register Error: $e");
      throw Exception('Error during registration: $e');
    }
  }

  Future<Map<String, dynamic>> sendResetPasswordEmail(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forget-password'),
      body: jsonEncode({'email': email}),
      headers: {'Content-Type': 'application/json'},
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final Map<String, dynamic> requestBody = {
      "email": email,
      "password": password,
    };

    print("🔹 Attempting login with: $requestBody");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print("🔹 Login Response Code: ${response.statusCode}");
      print("🔹 Login Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('accessToken')) {
          print("✅ Login Successful. Token received.");

          // Save access token securely
          await storage.write(key: "token", value: responseData['accessToken']);
          return responseData;
        } else {
          print("❌ Login response missing accessToken");
          throw Exception('Login response does not contain accessToken');
        }
      } else {
        print("❌ Failed to login: ${response.body}");
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      print("❌ Login Error: $e");
      throw Exception('Error during login: $e');
    }
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/auth/reset-password');

    final Map<String, dynamic> requestBody = {
      "email": email,
      "code": code,
      "newPassword": newPassword,
    };

    print("🔹 Sending Reset Password Request: $requestBody");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print("🔹 Reset Password Response Code: ${response.statusCode}");
      print("🔹 Reset Password Response Body: ${response.body}");

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        print("✅ Password reset successfully!");
      } else {
        print("❌ Failed to reset password: ${responseData['message']}");
        throw Exception('Failed to reset password: ${responseData['message']}');
      }
    } catch (e) {
      print("❌ Reset Password Error: $e");
      throw Exception('Error during password reset: $e');
    }
  }

  Future<void> logout() async {
    await storage.delete(key: "token");
  }

  Future<String?> getToken() async {
    return await storage.read(key: "token");
  }
}
