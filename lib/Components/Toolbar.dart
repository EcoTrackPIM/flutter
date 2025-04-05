import 'package:flutter/material.dart';
import '../Screens/CameraOptionsScreen.dart';

class CustomToolbar extends StatelessWidget {
  final VoidCallback onProfilePressed;
  final VoidCallback onSettingsPressed;

  const CustomToolbar({
    Key? key,
    required this.onProfilePressed,
    required this.onSettingsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.grey[700], size: 28),
            onPressed: onProfilePressed,
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CameraOptionsScreen(
                  fabric: "cotton", // Default value
                  imagePath: "", // Empty path
                )),
              );
              if (result != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Image Path: $result")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
              elevation: 5,
            ),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.grey[700], size: 28),
            onPressed: onSettingsPressed,
          ),
        ],
      ),
    );
  }
}