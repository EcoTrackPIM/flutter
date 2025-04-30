import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class TagApi {
  static const String _baseUrl = 'http://192.168.1.122:3000';
  static const Duration _timeoutDuration = Duration(seconds: 15);

  // OCR Scanning Endpoint
  static Future<Map<String, dynamic>> scanTag(File imageFile, String userId) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/ocr/scan'),
      )..fields['userId'] = userId;

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final response = await request.send().timeout(_timeoutDuration);
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'extracted_text': jsonResponse['data']['extracted_text'],
          'detected_composition': jsonResponse['data']['detected_composition'] ?? {},
          'scanId': jsonResponse['data']['scanId'],
          'createdAt': jsonResponse['data']['createdAt'],
          'imagePath': jsonResponse['data']['imagePath'],
          'warnings': jsonResponse['warnings'] ?? [],
        };
      } else {
        throw HttpException(
          jsonResponse['message'] ?? 'Failed to scan tag (${response.statusCode})',
        );
      }
    } on TimeoutException {
      throw TimeoutException('Scan request timed out');
    } catch (e) {
      throw HttpException('Scan failed: ${e.toString()}');
    }
  }

  // Carbon Calculation - Frontend Version
  static Future<double> calculateCarbonFootprint(
      Map<String, dynamic> composition,
      String outfitType,
      ) async {
    try {
      // Convert all composition values to numbers
      final sanitizedComposition = composition.map<String, double>(
            (key, value) => MapEntry(
          key,
          value is double ? value : double.tryParse(value.toString()) ?? 0.0,
        ),
      );

      return _calculateCarbonLocally(sanitizedComposition, outfitType);
    } catch (e) {
      throw Exception('Calculation error: ${e.toString()}');
    }
  }

  static double _calculateCarbonLocally(
      Map<String, double> composition,
      String outfitType
      ) {
    // Carbon footprint factors (kg CO2 per kg of material)
    const materialFactors = {
      'cotton': 8.0,       // Conventional cotton
      'organic cotton': 4.0,
      'polyester': 5.5,
      'recycled polyester': 3.0,
      'wool': 12.0,
      'nylon': 7.2,
      'acrylic': 6.5,
      'elastane': 4.8,
      'viscose': 3.0,
      'lyocell': 2.0,
      'linen': 2.5,
      'silk': 15.0,
      'hemp': 2.0,
      'rayon': 3.5,
      'modal': 3.0,
    };

    // Average weights for different outfit types (in kg)
    const outfitWeights = {
      't-shirt': 0.2,
      'shirt': 0.3,
      'pullover': 0.4,
      'dress': 0.5,
      'skirt': 0.3,
      'jacket': 0.8,
      'jeans': 0.6,
      'sweater': 0.5,
      'shorts': 0.3,
      'hoodie': 0.7,
      'coat': 1.2,
      'blouse': 0.25,
      'pants': 0.5,
    };

    // Default values if not found
    const defaultMaterialFactor = 6.0;
    const defaultOutfitWeight = 0.4;

    double totalFootprint = 0.0;

    // Calculate material contributions
    composition.forEach((material, percentage) {
      // Find the best matching material factor
      final materialKey = materialFactors.keys.firstWhere(
            (key) => material.toLowerCase().contains(key),
        orElse: () => '',
      );

      final factor = materialKey.isNotEmpty
          ? materialFactors[materialKey]!
          : defaultMaterialFactor;

      totalFootprint += (percentage / 100) * factor;
    });

    // Apply outfit weight
    final outfitKey = outfitWeights.keys.firstWhere(
          (key) => outfitType.toLowerCase().contains(key),
      orElse: () => '',
    );

    final weight = outfitKey.isNotEmpty
        ? outfitWeights[outfitKey]!
        : defaultOutfitWeight;

    totalFootprint *= weight;

    // Apply reasonable bounds (0.1kg to 50kg)
    totalFootprint = totalFootprint.clamp(0.1, 50.0);

    // Round to 1 decimal place
    return double.parse(totalFootprint.toStringAsFixed(1));
  }

  // History Management
  static Future<List<dynamic>> getScanHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/ocr/history/$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeoutDuration);

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        return jsonResponse['data'];
      } else {
        throw HttpException(
          jsonResponse['message'] ?? 'Failed to get history (${response.statusCode})',
        );
      }
    } on TimeoutException {
      throw TimeoutException('History request timed out');
    } catch (e) {
      throw HttpException('Failed to load history: ${e.toString()}');
    }
  }

  static Future<bool> deleteScan(String scanId, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/ocr/delete/$scanId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      ).timeout(_timeoutDuration);

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return jsonResponse['success'] == true;
      } else {
        throw HttpException(
          jsonResponse['message'] ?? 'Failed to delete scan (${response.statusCode})',
        );
      }
    } on TimeoutException {
      throw TimeoutException('Delete request timed out');
    } catch (e) {
      throw HttpException('Delete failed: ${e.toString()}');
    }
  }

  // Helper to get main material name
  static String getMainMaterialName(Map<String, dynamic> composition) {
    if (composition.isEmpty) return "Mixed Materials";

    final converted = composition.map<String, double>(
          (key, value) => MapEntry(
        key,
        value is double ? value : double.tryParse(value.toString()) ?? 0.0,
      ),
    );

    final mainMaterial = converted.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
    );
    return "${mainMaterial.key} (${mainMaterial.value.toStringAsFixed(1)}%)";
  }
}