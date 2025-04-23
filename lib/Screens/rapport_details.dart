import 'package:flutter/material.dart';
import 'package:flutter_eco_track/Screens/rapport.dart';

class RapportDetailScreen extends StatelessWidget {
  final Rapport rapport;

  const RapportDetailScreen({super.key, required this.rapport});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(rapport.title,
              style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF8BC34A),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Daily Data'),
              Tab(text: 'Comparison'),
              Tab(text: 'Advices'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: [
            // Daily Data Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Details for ${rapport.date}',
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 16),
                  const Text('Daily metrics and observations...'),
                  // Add your specific daily data content here
                ],
              ),
            ),
            
            // Comparison Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Comparison Data',
                      style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 16),
                  const Text('Comparison with previous periods...'),
                  // Add your comparison content here
                ],
              ),
            ),
            
            // Advices Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recommendations',
                      style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 16),
                  const Text('Expert advice and suggestions...'),
                  // Add your advice content here
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}