import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

// API Service class
class ApiService {
  final String baseUrl = "http://192.168.100.17:3000"; // Replace with your API base URL

  String? _token; // Store your bearer token

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> _buildHeaders({Map<String, String>? extraHeaders}) {
    final headers = {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  //ApiService({required this.baseUrl});

  Future<dynamic> getRequest(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(),
      );
    return _handleResponse(response);
  }

  Future<dynamic> postRequest(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> putRequest(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> deleteRequest(String endpoint) async {
    final response = await http.delete(Uri.parse('$baseUrl$endpoint'));
    return _handleResponse(response);
  }

    // 🔥 New method for file upload
  Future<dynamic> postMultipartRequest(String endpoint, File file) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      http.MultipartFile(
        'file',
        file.readAsBytes().asStream(),
        file.lengthSync(),
        filename: file.path.split('/').last,
        contentType: MediaType('audio', 'wav'),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error: ${response.statusCode}, ${response.body}');
    }
  }
}

// Example model class
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}


class MessageAi{
  final String message;

  MessageAi({required this.message});


  factory MessageAi.fromJson(Map<String, dynamic> json) {
    return MessageAi(
      message: json['message'],
    );
  }


}

class Media{
  final String filename;
  final num size;

  Media({required this.filename, required this.size});


  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      filename: json['filename'],
      size: json['size'],
    );
  }


}

// Object containing all API requests
class ApiRequests {
  final ApiService apiService;

  ApiRequests({required this.apiService});

  Future<List<User>> fetchUsers() async {
    final response = await apiService.getRequest('/users');
    return (response as List).map((json) => User.fromJson(json)).toList();
  }

  Future<User> createUser(String name, String email) async {
    final response = await apiService.postRequest('/users', {
      'name': name,
      'email': email,
    });
    return User.fromJson(response);
  }

  Future<MessageAi> TalkToAI(String message) async {
    final response = await apiService.postRequest('/chat', {
      'message': message,
    });
    // Handle the AI response as needed
    return MessageAi.fromJson(response);
  }

  Future<Media> uploadFile(String filePath) async {
  final file = File(filePath);
  if (!file.existsSync()) {
    throw Exception('File does not exist: $filePath');
  }

  final response = await apiService.postMultipartRequest('/media/upload', file);
  return Media.fromJson(response);
}

Future<void> transcribe(String audio_url) async {
  final response = await apiService.postRequest('/transcribe', {
    'audio_url': audio_url,
  });
  // Handle the transcription response as needed
  //return 'Transcription successful';
}

Future<void> sendMessage(
  String text,
  int createdAt,
  String id,
  String type, {
  String? uri,
  String? name,
  num? size,
  Duration? duration,
}) async {
  final Map<String, dynamic> data = {
    'text': text,
    'createdAt': createdAt,
    'id': id,
    'type': type,
  };

  if (uri != null) data['uri'] = uri;
  if (name != null) data['name'] = name;
  if (size != null) data['size'] = size;
  if (duration != null) data['duration'] = duration.inMilliseconds;

  final response = await apiService.postRequest('/chat', data);

  // You can return or handle response here if needed
}

  Future<List<types.Message>> getAllMessages() async {
  final response = await apiService.getRequest('/chat');

  // Make sure the response is a List
  if (response is List) {
    debugPrint('Messages loaded: $response');

    final messages = response
        .map((json) => types.Message.fromJson(json as Map<String, dynamic>))
        .toList();

    debugPrint('First Message transformed: ${messages.isNotEmpty ? messages[0] : 'No messages'}');

    return messages;
  } else {
    throw Exception('Unexpected response format: $response');
  }
}



Future<void> getFeedback(String conversation) async {
  final response = await apiService.postRequest('/ai/feedback', {
    'conversation': conversation,
  });



  
  // Handle the feedback response as needed
  //return 'Feedback sent successfully';
}

Future<String> saveTrip(Map<String, dynamic> tripData) async {
  final response = await apiService.postRequest('/ai/roadtrip', tripData);
  return response['analysis'];
  }
}