import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EcoProgressScreen extends StatelessWidget {
  final Map<String, dynamic> ecoData;

  const EcoProgressScreen({Key? key, required this.ecoData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final carbonHistory = (ecoData['carbonHistory'] as List<dynamic>?) ?? [];
    final timeline = (ecoData['timeline'] as List<dynamic>?) ?? [];
    final ecoScore = (ecoData['ecoScore'] as num?)?.toDouble() ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon Crusader',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderSection(ecoScore),
            const SizedBox(height: 100), // Increased further to ensure circle visibility
            _buildComparisonSection(carbonHistory),
            _buildTimelineHeader(),
            _buildTimelineList(timeline),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(double score) {
    return SizedBox(
      height: 300, // Increased height to accommodate the circle better
      child: Stack(
        clipBehavior: Clip.none, // Prevent clipping of positioned children
        children: [
          // Background curve
          ClipPath(
            clipper: _HeaderClipper(),
            child: Container(
              height: 240, // Adjusted height
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF4D8B6F),
                    const Color(0xFF4D8B6F).withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),
          // Score circle
          Positioned(
            bottom: -40, // Adjusted position
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 3,
                    )
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 12,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF4D8B6F),
                            const Color(0xFF45748E),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            score.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text('Eco Score',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  letterSpacing: 1.2)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection(List<dynamic> history) {
    final hasEnoughData = history.length >= 2;
    num improvement = 0;
    String currentVal = 'N/A';
    String previousVal = 'N/A';

    if (hasEnoughData) {
      final current = (history[0]['carbonFootprint'] as num?) ?? 0;
      final previous = (history[1]['carbonFootprint'] as num?) ?? 0;
      improvement = previous > 0 ? ((previous - current) / previous * 100).clamp(0, 100) : 0;
      currentVal = current.toStringAsFixed(1);
      previousVal = previous.toStringAsFixed(1);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.only(top: 20), // Added margin to ensure circle visibility
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildComparisonItem("Previous", previousVal, Icons.arrow_back),
                  _buildImprovementPill(improvement),
                  _buildComparisonItem("Current", currentVal, Icons.arrow_forward),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: improvement / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4D8B6F)),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasEnoughData ? "Your carbon footprint improvement" : "Need more data to compare",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 60, // Slightly larger to ensure full visibility
          height: 60,
          margin: const EdgeInsets.only(bottom: 8), // Added margin
          decoration: BoxDecoration(
            color: const Color(0xFF4D8B6F).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF4D8B6F), size: 28), // Slightly larger icon
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        const SizedBox(height: 4),
        Text("$value kg",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildImprovementPill(num improvement) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(vertical: 10), // Added margin
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4D8B6F), Color(0xFF4D8B6F)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4D8B6F).withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Text(
        "${improvement.toStringAsFixed(1)}%",
        style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16
        ),
      ),
    );
  }

  Widget _buildTimelineHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
      child: Row(
        children: [
          const Text('Recent Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4D8B6F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${ecoData['improvements'] ?? 0} Improvements',
                style: const TextStyle(
                  color: Color(0xFF4D8B6F),
                  fontWeight: FontWeight.bold,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineList(List<dynamic> timeline) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: timeline.length,
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey[200],
          height: 1,
          indent: 80, // Increased indent
          endIndent: 20,
        ),
        itemBuilder: (context, index) => _buildTimelineItem(timeline[index]),
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> entry) {
    final date = DateFormat('MMM dd, hh:mm a').format(
        DateTime.tryParse(entry['date'] as String? ?? '') ?? DateTime.now());
    final ecoScore = (entry['ecoScore'] as num?) ?? 0;
    final isImprovement = ecoScore > 0;
    final carbon = (entry['carbonFootprint'] as num?)?.toStringAsFixed(1) ?? 'N/A';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8), // Added margin
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12), // Increased padding
        leading: Container(
          width: 60, // Slightly larger
          height: 60,
          decoration: BoxDecoration(
            gradient: isImprovement
                ? const LinearGradient(
                colors: [Color(0xFF4D8B6F), Color(0xFF45748E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight)
                : LinearGradient(
                colors: [Colors.grey[400]!, Colors.grey[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Icon(
            isImprovement ? Icons.eco : Icons.history,
            color: Colors.white,
            size: 28, // Slightly larger icon
          ),
        ),
        title: Text('$carbon kg CO₂',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${entry['outfitType'] ?? 'No type'} • $date'),
        trailing: Container(
          width: 60, // Slightly larger
          height: 30,
          decoration: BoxDecoration(
            color: isImprovement
                ? const Color(0xFF4D8B6F).withOpacity(0.2)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text('${isImprovement ? '+' : ''}$ecoScore',
                style: TextStyle(
                  color: isImprovement ? const Color(0xFF4D8B6F) : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                )),
          ),
        ),
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 80); // Adjusted curve
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20, // Adjusted curve
      size.width,
      size.height - 80,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}