import 'package:flutter/material.dart';

class ImageIconWidget extends StatelessWidget {
  final String imagePath; // Image path from assets
  final Color color; // Color to tint the image
  final double size; // Size of the image icon

  ImageIconWidget({
    required this.imagePath,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn), // Tint color
      child: Image.asset(
        imagePath, // Path to your image asset
        width: size, // Icon size
        height: size, // Icon size
      ),
    );
  }
}