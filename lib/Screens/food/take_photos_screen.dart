import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'basic_info_screen.dart'; // 👉 Pour naviguer après upload

class PhotoItem {
  final File file;
  final String type;

  PhotoItem({required this.file, required this.type});
}

class TakePhotosScreen extends StatefulWidget {
  const TakePhotosScreen({Key? key}) : super(key: key);

  @override
  _TakePhotosScreenState createState() => _TakePhotosScreenState();
}

class _TakePhotosScreenState extends State<TakePhotosScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<PhotoItem> _photos = [];

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (pickedFile != null) {
      String? selectedType = await _selectPhotoType();
      if (selectedType != null) {
        setState(() {
          _photos.add(PhotoItem(file: File(pickedFile.path), type: selectedType));
        });
      }
    }
  }

  Future<String?> _selectPhotoType() async {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.fastfood),
            title: const Text('Photo du produit'),
            onTap: () => Navigator.pop(context, 'Produit'),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Ingrédients'),
            onTap: () => Navigator.pop(context, 'Ingrédients'),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Informations nutritionnelles'),
            onTap: () => Navigator.pop(context, 'Nutrition'),
          ),
          ListTile(
            leading: const Icon(Icons.recycling),
            title: const Text('Recyclage'),
            onTap: () => Navigator.pop(context, 'Recyclage'),
          ),
          ListTile(
            leading: const Icon(Icons.add_photo_alternate),
            title: const Text('Autre'),
            onTap: () => Navigator.pop(context, 'Autre'),
          ),
        ],
      ),
    );
  }

  void _deletePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  Future<void> _uploadPhotos() async {
    // 🟰 Première chose : avancer vers BasicInfoScreen SANS ATTENDRE
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const BasicInfoScreen()),
    );

    // 🟰 Ensuite essayer d'envoyer en arrière-plan
    if (_photos.isEmpty) {
      print('❌ Aucune photo à envoyer.');
      return;
    }

    final url = Uri.parse('http://192.168.1.13:3000/products/upload-photos');

    try {
      var request = http.MultipartRequest('POST', url);

      for (var photo in _photos) {
        final mimeType = lookupMimeType(photo.file.path) ?? 'image/jpeg';
        final multipartFile = await http.MultipartFile.fromPath(
          'files',
          photo.file.path,
          contentType: MediaType.parse(mimeType),
          filename: path.basename(photo.file.path),
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Photos envoyées avec succès !');
      } else {
        print('❌ Échec envoi photos (${response.statusCode})');
      }
    } catch (e) {
      print('🚨 Erreur envoi photos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4D996F)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: 0.8,
                color: const Color(0xFF4D996F),
                backgroundColor: Colors.grey.shade300,
                minHeight: 5,
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Prenons quelques photos !",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4D996F),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.photo_camera),
                label: const Text("Prendre une photo"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF43A047),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _photos.isEmpty
                    ? const Center(child: Text("Aucune photo pour l'instant 📷"))
                    : GridView.builder(
                        itemCount: _photos.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onLongPress: () => _deletePhoto(index),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _photos[index].file,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _photos[index].type,
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4D996F)),
                        foregroundColor: const Color(0xFF4D996F),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Fermer'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _uploadPhotos,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF43A047),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Suivant'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
