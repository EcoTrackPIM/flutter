import 'package:flutter/material.dart';

class CookiesScreen extends StatelessWidget {
  final int cookieCount;

  const CookiesScreen({Key? key, required this.cookieCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

            // See Statistics Button (moved to top)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(180, 50),
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),  // Rounded corners
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.arrow_back, size: 20), // Icône de flèche
                  SizedBox(width: 8), // Espacement entre l'icône et le texte
                  Text('See Statistics'),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Card with gradient background
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFCBDDD1),
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Card(
                elevation: 0,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Congrats !',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'You Got $cookieCount Cookies',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: Image.asset(
                          'assets/cookie_image.png',
                          width: 400,
                          height: 400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Buttons with arrow icon
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  ElevatedButton(
                    onPressed: () {
                      // Share functionality
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(300, 50),  // Increase width for longer button
                      backgroundColor: const Color(0xFF4D8B6F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),  // Rounded corners
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Share',
                      style: TextStyle(
                        fontSize: 20, // Adjust the font size as per your requirement
                        //   fontWeight: FontWeight.bold, // Optional: Make the text bold
                      ),
                    ),
                  ) ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
