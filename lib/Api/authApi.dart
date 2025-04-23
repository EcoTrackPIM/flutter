import 'dart:convert';

import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';


class ApiService {
  final String baseUrl = "http://192.168.1.23:3000";
  final FlutterSecureStorage storage = const FlutterSecureStorage();

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


  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    final token = await storage.read(key: "token");
    if (token == null) throw Exception('No authentication token found');

    final url = Uri.parse('$baseUrl/auth/upload-profile-image');
    final request = http.MultipartRequest('POST', url);

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';

    // Add image file
    final fileStream = http.ByteStream(imageFile.openRead());
    final length = await imageFile.length();
    final multipartFile = http.MultipartFile(
      'image',
      fileStream,
      length,
      filename: imageFile.path.split('/').last,
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFile);

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody);
        return responseData;
      } else {
        throw Exception('Failed to upload image: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Image upload error: $e');
    }
  }


  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phoneNumber,
    String? address,
    String? age,
    String? bio,
    String? profileImage,
  }) async {
    final token = await storage.read(key: "token");
    if (token == null) throw Exception('No authentication token found');

    final url = Uri.parse('$baseUrl/auth/update');
    final Map<String, dynamic> requestBody = {
      if (name != null) 'name': name,
      if (phoneNumber != null) 'Phone_number': phoneNumber,
      if (address != null) 'Address': address,
      if (age != null) 'Age': int.tryParse(age),
      if (bio != null) 'bio': bio,
      if (profileImage != null) 'profileImage': profileImage,
    };

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Update stored user data for any non-null values
        if (name != null) await storage.write(key: "userName", value: name);
        if (phoneNumber != null) await storage.write(key: "userPhone", value: phoneNumber);
        if (address != null) await storage.write(key: "userAddress", value: address);
        if (age != null) await storage.write(key: "userAge", value: age);
        if (profileImage != null) await storage.write(key: "userProfileImage", value: profileImage);

        return responseData;
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Profile update error: $e');
    }
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
          await storage.write(key: "token", value: responseData['accessToken']);
          await storage.write(key: "userId", value: responseData['user']['_id']);
          await storage.write(key: "userName", value: responseData['user']['name']);

          // Store additional user data for easy access
          if (responseData['user']['Phone_number'] != null) {
            await storage.write(key: "userPhone", value: responseData['user']['Phone_number']);
          }
          if (responseData['user']['Address'] != null) {
            await storage.write(key: "userAddress", value: responseData['user']['Address']);
          }
          if (responseData['user']['Age'] != null) {
            await storage.write(key: "userAge", value: responseData['user']['Age'].toString());
          }

          if (responseData.containsKey('refreshToken')) {
            await storage.write(key: "refreshToken", value: responseData['refreshToken']);
          }

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

  Future<Map<String, dynamic>> getUserProfile() async {
    final token = await storage.read(key: "token");
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final url = Uri.parse('$baseUrl/auth/profile');

    print("🔹 Fetching user profile...");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      print("🔹 Profile Response Code: ${response.statusCode}");
      print("🔹 Profile Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("✅ Profile fetched successfully");

        // Store all user data in secure storage
        await _storeUserData(responseData);

        return responseData;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to fetch profile: ${response.body}');
      }
    } catch (e) {
      print("❌ Profile Error: $e");
      throw Exception('Error fetching profile: $e');
    }
  }

  Future<void> _storeUserData(Map<String, dynamic> userData) async {
    if (userData.containsKey('name')) {
      await storage.write(key: "userName", value: userData['name']);
    }
    if (userData.containsKey('Phone_number')) {
      await storage.write(key: "userPhone", value: userData['Phone_number']);
    }
    if (userData.containsKey('Address')) {
      await storage.write(key: "userAddress", value: userData['Address']);
    }
    if (userData.containsKey('Age')) {
      await storage.write(key: "userAge", value: userData['Age'].toString());
    }
    if (userData.containsKey('email')) {
      await storage.write(key: "userEmail", value: userData['email']);
    }
  }



  Future<Map<String, String>> getStoredUserData() async {
    return {
      'name': await storage.read(key: "userName") ?? '',
      'phone': await storage.read(key: "userPhone") ?? '',
      'address': await storage.read(key: "userAddress") ?? '',
      'age': await storage.read(key: "userAge") ?? '',
      'email': await storage.read(key: "userEmail") ?? '',
    };
  }

  Future<void> logout() async {
    await storage.delete(key: "token");
    await storage.delete(key: "refreshToken");
    await storage.delete(key: "userId");
    await storage.delete(key: "userName");
    await storage.delete(key: "userPhone");
    await storage.delete(key: "userAddress");
    await storage.delete(key: "userAge");
    await storage.delete(key: "userEmail");
    print("✅ User logged out successfully");
  }

  Future<String?> getToken() async {
    return await storage.read(key: "token");
  }

  Future<String?> getUserId() async {
    return await storage.read(key: "userId");
  }

  Future<String?> getUserName() async {
    return await storage.read(key: "userName") ?? 'User';
  }

  // Existing methods below remain unchanged...
  Future<Map<String, dynamic>> sendResetPasswordEmail(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forget-password'),
      body: jsonEncode({'email': email}),
      headers: {'Content-Type': 'application/json'},
    );

    return jsonDecode(response.body);
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
}