import 'package:flutter/material.dart';
import '../constants/colors.dart';

class BtnPrimary extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  BtnPrimary({required this.text, required this.onTap});

  Future<void> loginrequest() async {
    
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // This triggers the onTap callback when the container is clicked
      child: Container(
        //margin: EdgeInsets.all(20), // Margin around the container
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10), // Padding inside the container
        decoration: BoxDecoration(
          color: AppColors.lightMainColor, // Background color
          borderRadius: BorderRadius.circular(15), // Rounded corners
        //   border: Border.all(
        //     color: Colors.white, // Border color
        //     width: 2, // Border width
        //   ),
        ),
        child: Text(
          text, // Text inside the container
          style: TextStyle(
            color: AppColors.darkMainColor, // Text color
            fontSize: 16, // Font size
          ),
        ),
      ),
    );
  }
}