import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
class tagApi {
  static const String _baseUrl = 'http://192.168.100.17:3000';

  static Future<Map<String, dynamic>> scanTag(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/ocr/scan'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      // Accept both 200 and 201 status codes
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(json.decode(responseData));
      } else {
        throw Exception('Failed to scan tag: ${response.statusCode} - $responseData');
      }
    } catch (e) {
      throw Exception('Error scanning tag: $e');
    }
  }
}