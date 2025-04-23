import 'dart:async';
import '../apis/api_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../components/btnWithIcon.dart';
import '../components/carType.dart';
import '../constants/colors.dart';

class LocationTrackerScreen2 extends StatefulWidget {
  @override
  _LocationTrackerScreenState createState() => _LocationTrackerScreenState();
}

class _LocationTrackerScreenState extends State<LocationTrackerScreen2> {
  String TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2N2NlMGFhODE1ZTUxYjZkZTcwOWNlNDIiLCJpYXQiOjE3NDUwOTkyMjAsImV4cCI6MTc0NTI3OTIyMH0.lupuCZF4a6M5dqiWIas0Z8-M2wrb3jUialvSTFnTpQo';
  double _totalDistance = 0.0;
  double _speed = 0.0;
  Position? _startPosition;
  Position? _endPosition;
  bool _isTracking = false;
  StreamSubscription<Position>? _positionStreamSubscription;
  String carType = "diesel";
  double _totalCO2 = 0.00;
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  LatLng? _userLocation;
  List<LatLng> _routeCoordinates = [];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.locationWhenInUse.request();
    if (!status.isGranted) {
      await Permission.locationAlways.request();
    }
  }

  Future<void> _startTracking() async {
    if (await Permission.location.isDenied) {
      await _checkPermissions();
      return;
    }

    setState(() {
      _isTracking = true;
      _totalDistance = 0.0;
      _totalCO2 = 0.0;
      _routeCoordinates.clear();
    });

    // Get initial position
    Position position = await Geolocator.getCurrentPosition();
    _startPosition = position;
    _updateUserLocation(position);
    _routeCoordinates.add(LatLng(position.latitude, position.longitude));

    // Listen to position updates
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1, // meters
      ),
    ).listen((Position position) {
      _updateUserLocation(position);
      _handleNewPosition(position);
    });
  }

  void _updateUserLocation(Position position) {
    final newLocation = LatLng(position.latitude, position.longitude);
    
    setState(() {
      _userLocation = newLocation;
      _speed = position.speed;
      _markers = {
        Marker(
          markerId: MarkerId('user_location'),
          position: newLocation,
          infoWindow: InfoWindow(title: 'Your Location'),
        ),
      };
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(newLocation, 16),
    );
  }

  Future<void> _handleNewPosition(Position newPosition) async {
    if (_routeCoordinates.isEmpty) {
      _routeCoordinates.add(LatLng(newPosition.latitude, newPosition.longitude));
      return;
    }

    // Calculate distance between previous and new position
    double distanceInMeters = Geolocator.distanceBetween(
      _routeCoordinates.last.latitude,
      _routeCoordinates.last.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );

    setState(() {
      _totalDistance += distanceInMeters;
      _routeCoordinates.add(LatLng(newPosition.latitude, newPosition.longitude));
    });

    // Calculate CO2 emissions
    double co2Emission = await _calculateCO2(distanceInMeters / 1000); // Convert to km
    setState(() {
      _totalCO2 += co2Emission;
    });
  }

  Future<void> _stopTracking() async {
    // Get the final position
    Position? finalPosition = await Geolocator.getCurrentPosition().catchError((e) => null);
    _endPosition = finalPosition;
    
    if (finalPosition != null) {
      _routeCoordinates.add(LatLng(finalPosition.latitude, finalPosition.longitude));
    }

    await _positionStreamSubscription?.cancel();
    setState(() {
      _isTracking = false;
    });

    // Show the data collection popup
    _showDataCollectionPopup();
  }

  void _showDataCollectionPopup() async {
  // Prepare the data to display
  Map<String, dynamic> tripData = {
    'startPoint': _startPosition != null 
        ? {'lat': _startPosition!.latitude, 'lng': _startPosition!.longitude}
        : null,
    'endPoint': _endPosition != null
        ? {'lat': _endPosition!.latitude, 'lng': _endPosition!.longitude}
        : null,
    'distance': _totalDistance,
    'co2Emissions': _totalCO2,
    'routeCoordinates': _routeCoordinates.map((coord) => [coord.latitude, coord.longitude]).toList(),
    'vehicleType': carType,
  };

  bool isLoading = true;
  bool isSuccess = false;
  String? errorMessage;
  String? aiAnalysis; // To store the AI analysis message

  // Show the dialog immediately
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Send data to backend when dialog appears
          if (isLoading) {
            _sendTripData(tripData).then((response) {
              setState(() {
                isLoading = false;
                isSuccess = response['success'] ?? false;
                aiAnalysis = response['analysis'];
                errorMessage = isSuccess ? null : 'Failed to save trip data';
              });
            }).catchError((error) {
              setState(() {
                isLoading = false;
                isSuccess = false;
                errorMessage = 'Error: ${error.toString()}';
              });
            });
          }

          return AlertDialog(
            title: Text(isLoading ? "Saving and Analyzing" : 
                      isSuccess ? "Trip Analysis" : "Error"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoading) ...[
                  Center(child: CircularProgressIndicator()),
                  SizedBox(height: 20),
                  Text("Your trip data is being saved and analyzed by AI..."),
                ] else if (isSuccess) ...[
                  Text(aiAnalysis ?? "Your trip has been analyzed!"), // Show AI analysis
                  SizedBox(height: 20),
                  Text("Details:", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      _formatDataForDisplay(tripData),
                      style: TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ] else ...[
                  Text(errorMessage ?? 'Unknown error occurred'),
                  SizedBox(height: 20),
                  Text("Please try again later."),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<Map<String, dynamic>> _sendTripData(Map<String, dynamic> tripData) async {
  try {
    final apiService = ApiService();
    apiService.setToken(TOKEN);
    
    final response = await ApiRequests(apiService: apiService).saveTrip(tripData);
    
     if (response is String) {
      // Handle case where the backend just returns the analysis string
      return {
        'success': true,
        'analysis': response
      };
    } else {
      return {
        'success': false,
        'analysis': "Received unexpected response format"
      };
    }
  } catch (e) {
    print("Error saving trip data: $e");
    return {
      'success': false,
      'analysis': "Error occurred while saving trip data"
    };
  }
}



  String _formatDataForDisplay(Map<String, dynamic> data) {
    String formatted = "";
    data.forEach((key, value) {
      if (value is List) {
        formatted += "$key: [${value.length} points]\n";
      } else {
        formatted += "$key: $value\n";
      }
    });
    return formatted;
  }

  Future<double> _calculateCO2(double distance) async {
    const String apiUrl = "https://api.klimapi.com/v2/calculate";
    const String apiKey = "sk_test_xEVikGnLSYar71zrorX7cFJ36i1Gp9ZeSsMX423lLwFY1VwIGaYuqr4G0MLAcA5xaLaOM7881F4no8Ok76SCG";

    Map<String, dynamic> data = {
      "calculation_options": [
        {
          "type": "travel-land",
          "activity": "cars_by_size",
          "specification": "medium_car",
          "detail": carType,
          "value": distance,
          "unit": "kilometers"
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': apiKey,
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['kgCO2e'] ?? 0.0;
      } else {
        print("Error in calculation: ${response.body}");
        return 0.0;
      }
    } catch (error) {
      print("Error in calculation: $error");
      return 0.0;
    }
  }

  void changeCarType(String newCarType) {
    setState(() {
      carType = newCarType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full screen map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _userLocation ?? LatLng(37.7749, -122.4194),
              zoom: 16.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            polylines: {
              Polyline(
                polylineId: PolylineId('route'),
                points: _routeCoordinates,
                color: Colors.blue,
                width: 5,
              ),
            },
          ),

          // Top left - CO2 emissions
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CO2 Emissions',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_totalCO2.toStringAsFixed(2)} kg',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),

          // Top right - Speed
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Speed',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${(_speed * 3.6).toStringAsFixed(1)} km/h',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),

          // Below CO2 - Distance
          Positioned(
            top: 120,
            left: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distance',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_totalDistance.toStringAsFixed(2)} m',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),

          // Car type selection (centered near bottom)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CarTypeItem(
                    carType: "diesel",
                    carTitle: "Diesel",
                    isSelected: carType == "diesel",
                    onTap: changeCarType,
                  ),
                  SizedBox(width: 10),
                  CarTypeItem(
                    carType: "petrol",
                    carTitle: "Petrol",
                    isSelected: carType == "petrol",
                    onTap: changeCarType,
                  ),
                  SizedBox(width: 10),
                  CarTypeItem(
                    carType: "battery_electric_vehicle",
                    carTitle: "Electric",
                    isSelected: carType == "battery_electric_vehicle",
                    onTap: changeCarType,
                  ),
                ],
              ),
            ),
          ),

          // Start/Stop button (bottom center)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: _isTracking
                  ? ElevatedButton(
                      onPressed: _stopTracking,
                      child: Text('Stop Tracking'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                    )
                  : BtnPrimaryWithImageIcon(
                      text: 'Start Tracking',
                      onTap: _startTracking,
                      iconPath: 'assets/start.png',
                      iconColor: AppColors.darkMainColor,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}