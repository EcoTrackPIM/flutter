import 'package:flutter/material.dart';
import './SignUpScreen.dart'; // Import the SignUpScreen
import './LoginScreen.dart'; // Import the LoginScreen

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity, // ✅ S'assure que tout l'écran est utilisé
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                "assets/background.jpg", // Ensure the path is correct
                fit: BoxFit.cover,
              ),
            ),

            // Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center, // ✅ Centre verticalement
              children: [
                const SizedBox(height: 100), // Adjust spacing

                // Logo
                Center(
                  child: Text(
                    "ECO",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20), // Replace Spacer() with fixed spacing

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Border Wrapper with Background Color
                        Container(
                          width: double.infinity,
                          height: 360, // Adjust height to fit border
                          margin: EdgeInsets.symmetric(horizontal: 20), // ✅ Ajout de marge pour éviter les bords
                          decoration: BoxDecoration(
                            color: const Color(0xFFAEC8B0), // ✅ Background color AEC8B0
                            border: Border.all(
                              color: Colors.green, // ✅ Solid green border
                              width: 4, // ✅ 4px border width
                            ),
                            borderRadius: BorderRadius.circular(20), // ✅ Rounded edges
                          ),
                          child: ClipPath(
                            clipper: CustomClipPath(),
                            child: Container(
                              width: double.infinity,
                              height: 350,
                              color: const Color(0xFFAEC8B0), // ✅ Background inside ClipPath
                              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Small Logo
                                  Text(
                                    "ECO",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // Welcome Text
                                  Text(
                                    "Welcome !!!",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                  ),

                                  const SizedBox(height: 30),

                                  // Sign Up Button
                                  SizedBox(
                                    width: 200, // ✅ Fixed width for both buttons
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Navigate to the SignUpScreen
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => SignUpScreen()),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white, // ✅ White background
                                        foregroundColor: Colors.green, // ✅ Green text
                                        side: const BorderSide(
                                          color: Colors.green, // ✅ Green border
                                          width: 2, // ✅ Border width
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20), // ✅ Rounded corners
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 15),
                                      ),
                                      child: const Text("SIGN UP"),
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  // Log In Button
                                  SizedBox(
                                    width: 200, // ✅ Fixed width for both buttons
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Navigate to the LoginScreen
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white, // ✅ White background
                                        foregroundColor: Colors.green, // ✅ Green text
                                        side: const BorderSide(
                                          color: Colors.green, // ✅ Green border
                                          width: 2, // ✅ Border width
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20), // ✅ Rounded corners
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 15),
                                      ),
                                      child: const Text("LOG IN"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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
}

// Custom ClipPath for Curved Design
class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, 50); // Start from the top-left corner
    path.quadraticBezierTo(size.width / 2, 0, size.width, 50); // Create a curve
    path.lineTo(size.width, size.height); // Go to the bottom-right corner
    path.lineTo(0, size.height); // Go to the bottom-left corner
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
