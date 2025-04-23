import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  // Check and request location permissions
  static Future<bool> requestLocationPermissions() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, we can't request permissions
      return false;
    }

    // Check location permission status
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately
      return false;
    }

    if (permission == LocationPermission.denied) {
      // Request permissions
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return false;
      }
    }

    // On Android, request activity recognition permission
    if (await Permission.activityRecognition.request().isGranted) {
      return true;
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  // Check if all required permissions are granted
  static Future<bool> hasRequiredPermissions() async {
    final locationPermission = await Geolocator.checkPermission();
    final activityPermission = await Permission.activityRecognition.status;

    return (locationPermission == LocationPermission.whileInUse ||
            locationPermission == LocationPermission.always) &&
        activityPermission.isGranted;
  }
}