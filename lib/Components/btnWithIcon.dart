import '../components/iconImage.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class BtnPrimaryWithImageIcon extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final String iconPath; // Path to the image asset
  final Color iconColor; // Color to tint the image
  final double iconSize; // Size of the image icon

  BtnPrimaryWithImageIcon({
    required this.text,
    required this.onTap,
    required this.iconPath,
    required this.iconColor,
    this.iconSize = 20.0, // Default icon size
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Trigger the onTap callback
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10), // Padding inside the container
        decoration: BoxDecoration(
          color: AppColors.lightMainColor, // Background color
          borderRadius: BorderRadius.circular(15), // Rounded corners
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageIconWidget(
              imagePath: iconPath, // The path to the image asset
              color: iconColor, // The color to tint the image
              size: iconSize, // Icon size
            ),
            SizedBox(width: 10), // Space between icon and text
            Text(
              text, // The button text
              style: TextStyle(
                color: AppColors.darkMainColor, // Text color
                fontSize: 16, // Font size
              ),
            ),
          ],
        ),
      ),
    );
  }
}