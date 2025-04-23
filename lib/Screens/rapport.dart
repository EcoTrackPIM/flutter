import 'package:flutter_eco_track/Components/rapport_item.dart';
import 'package:flutter_eco_track/Screens/distance_map.dart';
import 'package:flutter_eco_track/Screens/rapport_details.dart';
import 'package:flutter/material.dart';


class DailyRapportScreen extends StatefulWidget {
  const DailyRapportScreen({super.key});

  @override
  State<DailyRapportScreen> createState() => _DailyRapportScreenState();
}

class _DailyRapportScreenState extends State<DailyRapportScreen> {
  // Sample data - replace with your actual data
  final List<Rapport> rapports = [
    Rapport(
      id: '1',
      title: 'Field Inspection - North Region',
      date: '2023-06-15',
      summary: 'Checked crops growth and soil conditions',
    ),
    Rapport(
      id: '2',
      title: 'Weekly Yield Report',
      date: '2023-06-10',
      summary: 'Analyzed weekly production metrics',
    ),
    Rapport(
      id: '3',
      title: 'Equipment Maintenance',
      date: '2023-06-05',
      summary: 'Serviced tractors and irrigation systems',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Rapports',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF8BC34A),
      ),
      body: Column(
        children: [
          // Go to Map button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  LocationTrackerScreen2(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Go to Map',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ),
          
          // Rapports list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: rapports.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final rapport = rapports[index];
                return RapportItem(
                  rapport: rapport,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RapportDetailScreen(rapport: rapport),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}




// Data model
class Rapport {
  final String id;
  final String title;
  final String date;
  final String summary;

  Rapport({
    required this.id,
    required this.title,
    required this.date,
    required this.summary,
  });
}