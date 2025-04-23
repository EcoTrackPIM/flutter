import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
    FlutterLocalNotificationsPlugin();

// Data model for activity tracking
class ActivityData {
  final DateTime timestamp;
  final double? speed; // in m/s
  final double? latitude;
  final double? longitude;
  final String? activityType; // walking, running, driving, etc.
  final double? distance; // in meters

  ActivityData({
    required this.timestamp,
    this.speed,
    this.latitude,
    this.longitude,
    this.activityType,
    this.distance,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'speed': speed,
      'latitude': latitude,
      'longitude': longitude,
      'activityType': activityType,
      'distance': distance,
    };
  }

  String toJson() => json.encode(toMap());
}

class BackgroundServiceManager {
  static const String _activityDataKey = 'activity_data';
  static bool _isTracking = false;
  static bool _vehicleNotificationShown = false;
  static StreamSubscription<Position>? _positionStream;

  // Initialize the background service
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: false,
        autoStartOnBoot: false,
      ),
    );

    // Initialize notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Start the background service
  static Future<void> startService() async {
    final service = FlutterBackgroundService();
    await service.startService();
    _isTracking = true;
    _vehicleNotificationShown = false;
    await _startLocationTracking();
  }

  // Stop the background service
  static Future<void> stopService() async {
    await _positionStream?.cancel();
    final service = FlutterBackgroundService();
     service.invoke('stop');
    _isTracking = false;
  }

  // Check if service is running
  static bool isTracking() => _isTracking;

  // Background service entry point
  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();
    }
    
    await _startLocationTracking();
  }

  // Start location tracking
  static Future<void> _startLocationTracking() async {
    final LocationSettings locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // meters
      intervalDuration: const Duration(seconds: 15),
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationTitle: "EcoTrack Activity Tracking",
        notificationText: "Tracking your movement for carbon footprint analysis",
        enableWakeLock: true,
      ),
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position? position) async {
      if (position == null) return;

      // Convert speed from m/s to km/h
      final speedKmh = position.speed * 3.6;
      String? activityType;

      // Determine activity type based on speed
      if (speedKmh < 1) {
        activityType = 'stationary';
      } else if (speedKmh < 5) {
        activityType = 'walking';
      } else if (speedKmh < 15) {
        activityType = 'running';
      } else if (speedKmh >= 40) {
        activityType = 'vehicle';
      }

      // Save activity data
      final activityData = ActivityData(
        timestamp: DateTime.now(),
        speed: position.speed,
        latitude: position.latitude,
        longitude: position.longitude,
        activityType: activityType,
      );

      await _saveActivityData(activityData);

      // Show notification if user is in vehicle and notification not shown yet
      if (speedKmh > 40 && !_vehicleNotificationShown) {
        _vehicleNotificationShown = true;
        _showNotification(
          'Vehicle Detected',
          'You seem to be in a vehicle. Tap to track your trip for CO2 calculation.',
          payload: 'start_tracking',
        );
      } else if (speedKmh <= 40) {
        _vehicleNotificationShown = false;
      }
    });
  }

  // Save activity data to local storage
  static Future<void> _saveActivityData(ActivityData data) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> activityList = prefs.getStringList(_activityDataKey) ?? [];
    activityList.add(data.toJson());
    await prefs.setStringList(_activityDataKey, activityList);
  }

  // Get all stored activity data
  static Future<List<ActivityData>> getActivityData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> activityList = prefs.getStringList(_activityDataKey) ?? [];
    return activityList.map((jsonString) {
      final map = json.decode(jsonString) as Map<String, dynamic>;
      return ActivityData(
        timestamp: DateTime.parse(map['timestamp']),
        speed: map['speed']?.toDouble(),
        latitude: map['latitude']?.toDouble(),
        longitude: map['longitude']?.toDouble(),
        activityType: map['activityType'],
        distance: map['distance']?.toDouble(),
      );
    }).toList();
  }

  // Clear stored activity data
  static Future<void> clearActivityData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activityDataKey);
  }

  // Show notification
  static Future<void> _showNotification(
    String title,
    String body, {
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'ecotrack_channel',
      'EcoTrack Notifications',
      channelDescription: 'Carbon footprint tracking notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      Random().nextInt(100000),
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}