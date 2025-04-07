import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../Api/tagscanner.dart';

class TagScannerScreen extends StatefulWidget {
  @override
  _TagScannerScreenState createState() => _TagScannerScreenState();
}

class _TagScannerScreenState extends State<TagScannerScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  Map<String, dynamic>? _results;
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isLoading = true;
        _errorMessage = null;
        _results = null;
      });

      try {
        final response = await tagApi.scanTag(_selectedImage!);

        // Check for success in the response body rather than status code
        if (response['success'] == true) {
          setState(() {
            _results = response['data']['data']; // Access nested data structure
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = response['message'] ?? 'Failed to scan tag';
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tag Scanner'),
        backgroundColor: Color(0xFFDAF7DE),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: Color(0xFFDAF7DE),
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            if (_errorMessage != null)
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[800]),
                      ),
                    ),
                  ],
                ),
              ),
            if (_selectedImage == null) ...[
              _buildScanOptions(),
            ] else if (_isLoading) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text(
                        'Analyzing clothing tag...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              _buildResultsView(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScanOptions() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.tag,
            size: 60,
            color: Color(0xFF2196F3),
          ),
          SizedBox(height: 20),
          Text(
            'Scan Clothing Tag',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Get detailed information about fabric composition',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          _buildOptionButton(
            icon: Icons.camera_alt,
            label: 'Take Photo',
            onPressed: () => _pickImage(ImageSource.camera),
          ),
          SizedBox(height: 20),
          _buildOptionButton(
            icon: Icons.photo_library,
            label: 'Choose from Gallery',
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Color(0xFF2196F3)),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    if (_results == null || _selectedImage == null) {
      return Expanded(
        child: Center(
          child: Text('No results available'),
        ),
      );
    }

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analysis Results',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  if (_results!['brands'] != null && (_results!['brands'] as List).isNotEmpty) ...[
                    _buildResultItem('Matched Brands:', Icons.sell),
                    SizedBox(height: 8),
                    Column(
                      children: (_results!['brands'] as List)
                          .map<Widget>((brand) => Padding(
                        padding: const EdgeInsets.only(left: 32.0, bottom: 8),
                        child: Text(
                          '- $brand',
                          style: TextStyle(fontSize: 16),
                        ),
                      ))
                          .toList(),
                    ),
                    SizedBox(height: 16),
                  ],
                  if (_results!['percentages'] != null && (_results!['percentages'] as Map).isNotEmpty) ...[
                    _buildResultItem('Material Composition:', Icons.percent),
                    SizedBox(height: 8),
                    Column(
                      children: (_results!['percentages'] as Map<String, dynamic>)
                          .entries
                          .map<Widget>((entry) => Padding(
                        padding: const EdgeInsets.only(left: 32.0, bottom: 8),
                        child: Row(
                          children: [
                            Text(
                              '${entry.key}: ',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${entry.value}%',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedImage = null;
                        _results = null;
                        _errorMessage = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2196F3),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Scan Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF2196F3), size: 24),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}