import 'background_service.dart';
import 'package:intl/intl.dart';

class DailyReportGenerator {
  static Future<Map<String, dynamic>> generateDailyReport() async {
    final activities = await BackgroundServiceManager.getActivityData();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Filter activities for today only
    final todayActivities = activities.where((activity) => 
        activity.timestamp.isAfter(today)).toList();
    
    if (todayActivities.isEmpty) {
      return {
        'date': DateFormat('yyyy-MM-dd').format(now),
        'message': 'No activities recorded today',
      };
    }
    
    // Calculate statistics
    double totalDistance = 0;
    double walkingDistance = 0;
    double runningDistance = 0;
    double vehicleDistance = 0;
    Duration walkingTime = Duration.zero;
    Duration runningTime = Duration.zero;
    Duration vehicleTime = Duration.zero;
    
    for (var i = 0; i < todayActivities.length - 1; i++) {
      final current = todayActivities[i];
      final next = todayActivities[i + 1];
      
      final duration = next.timestamp.difference(current.timestamp);
      final distance = current.distance ?? 0;
      
      totalDistance += distance;
      
      switch (current.activityType) {
        case 'walking':
          walkingDistance += distance;
          walkingTime += duration;
          break;
        case 'running':
          runningDistance += distance;
          runningTime += duration;
          break;
        case 'vehicle':
          vehicleDistance += distance;
          vehicleTime += duration;
          break;
      }
    }
    
    // Estimate CO2 emissions (simplified calculation)
    final vehicleCO2 = vehicleDistance * 0.12; // approx 120g CO2 per km
    final savedCO2 = (walkingDistance + runningDistance) * 0.12; // what would have been emitted if driven
    
    return {
      'date': DateFormat('yyyy-MM-dd').format(now),
      'total_distance_km': totalDistance / 1000,
      'walking': {
        'distance_km': walkingDistance / 1000,
        'time_minutes': walkingTime.inMinutes,
      },
      'running': {
        'distance_km': runningDistance / 1000,
        'time_minutes': runningTime.inMinutes,
      },
      'vehicle': {
        'distance_km': vehicleDistance / 1000,
        'time_minutes': vehicleTime.inMinutes,
        'co2_kg': vehicleCO2 / 1000,
      },
      'co2_saved_kg': savedCO2 / 1000,
      'activities': todayActivities.map((a) => a.toMap()).toList(),
    };
  }
}