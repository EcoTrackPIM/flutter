import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../Api/tagscanner.dart';
import 'outfit_selection_screen.dart';

class TagScannerScreen extends StatefulWidget {
  const TagScannerScreen({super.key});

  @override
  _TagScannerScreenState createState() => _TagScannerScreenState();
}

class _TagScannerScreenState extends State<TagScannerScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _scanHistory = [];
  final String userId = "test_user"; // Replace with your user management

  @override
  void initState() {
    super.initState();
    _loadScanHistory();
  }

  Future<void> _loadScanHistory() async {
    setState(() => _isLoading = true);
    try {
      final history = await TagApi.getScanHistory(userId);
      setState(() => _scanHistory = history);
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load history: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final response = await TagApi.scanTag(_selectedImage!, userId);

        if (response['success'] == true) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OutfitSelectionScreen(
                imagePath: _selectedImage!.path,
                composition: response['detected_composition'] ?? {},
              ),
            ),
          );
          await _loadScanHistory();
        } else {
          setState(() {
            _errorMessage = response['message'] ?? 'Failed to scan tag';
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteScan(String scanId) async {
    setState(() => _isLoading = true);
    try {
      await TagApi.deleteScan(scanId, userId);
      await _loadScanHistory();
    } catch (e) {
      setState(() => _errorMessage = 'Failed to delete scan: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showImageSourceDialog(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF4D8B6F),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Select Image Source",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ImageSourceButton(
                  icon: Icons.camera_alt_rounded,
                  label: "Camera",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                  color: const Color(0xFF4D8B6F),
                ),
                _ImageSourceButton(
                  icon: Icons.photo_library_rounded,
                  label: "Gallery",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _HeaderSection() {
    return Column(
      children: [
        Image.asset(
          'assets/tag.png',
          height: 100,
          width: 100,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 10),
        Text(
          "Scan clothing tags for fabric information",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4D8B6F),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Get detailed composition analysis from clothing tags",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _HowItWorksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "How it works:",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4D8B6F),
          ),
        ),
        const SizedBox(height: 16),
        _StepItem(
          number: 1,
          title: "Take a photo",
          description: "Capture the clothing tag or choose from gallery",
        ),
        _StepItem(
          number: 2,
          title: "Text extraction",
          description: "Our system extracts text from the tag",
        ),
        _StepItem(
          number: 3,
          title: "Material analysis",
          description: "We analyze the fabric composition",
        ),
        _StepItem(
          number: 4,
          title: "Carbon calculation",
          description: "Calculate environmental impact based on materials",
        ),
      ],
    );
  }

  Widget _StepItem({
    required int number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF4D8B6F),
              shape: BoxShape.circle,
            ),
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanSection(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _isLoading ? null : () => _showImageSourceDialog(context),
          child: Container(
            height: 180,
            width: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_rounded,
                  size: 48,
                  color: const Color(0xFF4D8B6F),
                ),
                const SizedBox(height: 12),
                Text(
                  "Scan Clothing Tag",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4D8B6F),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : () => _showImageSourceDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4D8B6F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              "Start Scan",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showHistoryDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan History'),
        content: SizedBox(
          width: double.maxFinite,
          child: _scanHistory.isEmpty
              ? const Center(child: Text('No scan history available'))
              : ListView.builder(
            shrinkWrap: true,
            itemCount: _scanHistory.length,
            itemBuilder: (context, index) {
              final item = _scanHistory[index];
              return ListTile(
                leading: const Icon(Icons.article),
                title: Text(
                  item['extractedText']?.toString().split('\n').first ?? 'Scan ${index + 1}',
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  item['createdAt'] != null
                      ? DateTime.parse(item['createdAt']).toLocal().toString()
                      : 'Unknown date',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteScan(context, item['_id']),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OutfitSelectionScreen(
                        imagePath: item['imagePath'] ?? '',
                        composition: item['detectedComposition'] ?? {},
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteScan(BuildContext context, String scanId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Scan?'),
        content: const Text('Are you sure you want to delete this scan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteScan(scanId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4D8B6F),
        elevation: 0,
        title: const Text(
          'Tag Scanner',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_scanHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => _showHistoryDialog(context),
            ),
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                _HeaderSection(),
                const SizedBox(height: 32),
                if (_isLoading && _scanHistory.isEmpty)
                  const Center(child: CircularProgressIndicator()),
                if (_errorMessage != null)
                  _buildErrorWidget(_errorMessage!),
                _buildScanSection(context),
                const SizedBox(height: 40),
                _HowItWorksSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}