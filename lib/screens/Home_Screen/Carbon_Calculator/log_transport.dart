import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class LogTransportScreen extends StatefulWidget {
  const LogTransportScreen({super.key});

  @override
  _LogTransportScreenState createState() => _LogTransportScreenState();
}

class EmissionFactors {
  static const double petrolEmissionFactor = 3.172;
  static const double dieselEmissionFactor = 3.140;

  static const double carEmissionPerKm = 0.21;
  static const double busEmissionPerKm = 0.05;
  static const double truckEmissionPerKm = 0.6;
  static const double motorcycleEmissionPerKm = 0.08;
}

double calculateEmissions(String transportMode, double distance) {
  switch (transportMode.toLowerCase()) {
    case 'car':
      return distance * EmissionFactors.carEmissionPerKm;
    case 'bus':
      return distance * EmissionFactors.busEmissionPerKm;
    case 'truck':
      return distance * EmissionFactors.truckEmissionPerKm;
    case 'motorcycle':
      return distance * EmissionFactors.motorcycleEmissionPerKm;
    default:
      return 0.0; // Unknown transport mode
  }
}

class _LogTransportScreenState extends State<LogTransportScreen> {
  final TextEditingController endAddressController = TextEditingController();
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  LatLng? startLatLng;
  LatLng? endLatLng;
  String transportMode = 'Car';
  final uuid = const Uuid();
  String _sessionToken = '';
  List<dynamic> _placeList = [];
  static const String _placesApiKey = 'AIzaSyD3VzgeADSiZwvc8ujBjzhCVA34GRqRItM'; 

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      startLatLng = LatLng(position.latitude, position.longitude);
      markers.add(Marker(
        markerId: const MarkerId('start'),
        position: startLatLng!,
        infoWindow: const InfoWindow(title: 'Current Location'),
      ));
    });
    mapController.animateCamera(CameraUpdate.newLatLngZoom(startLatLng!, 15));
  }

  Future<void> _calculateRoute() async {
    try {
      if (startLatLng != null && endLatLng != null) {
        setState(() {
          markers.removeWhere((marker) => marker.markerId.value == 'end');
          polylines.clear();

          markers.add(Marker(
            markerId: const MarkerId('end'),
            position: endLatLng!,
            infoWindow: const InfoWindow(title: 'End Location'),
          ));

          _getPolyline(startLatLng!, endLatLng!);
        });

        mapController.animateCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              startLatLng!.latitude < endLatLng!.latitude ? startLatLng!.latitude : endLatLng!.latitude,
              startLatLng!.longitude < endLatLng!.longitude ? startLatLng!.longitude : endLatLng!.longitude,
            ),
            northeast: LatLng(
              startLatLng!.latitude > endLatLng!.latitude ? startLatLng!.latitude : endLatLng!.latitude,
              startLatLng!.longitude > endLatLng!.longitude ? startLatLng!.longitude : endLatLng!.longitude,
            ),
          ),
          50,
        ));
      } else {
        print('No locations found for the provided addresses.');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error calculating route: $e')),
      );
    }
  }

  Future<void> _getPolyline(LatLng start, LatLng end) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: _placesApiKey, // Use your API key
      request: PolylineRequest(
        origin: PointLatLng(start.latitude, start.longitude),
        destination: PointLatLng(end.latitude, end.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      setState(() {
        polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          points: result.points.map((point) => LatLng(point.latitude, point.longitude)).toList(),
          color: Colors.blue,
          width: 5,
        ));
      });
    } else {
      print('Error getting polyline: ${result.errorMessage}');
    }
  }

  Future<void> addActivity(String activityName, double emissions) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('activities')
        .add({
          'activityName': activityName,
          'emissions': emissions,
          'timestamp': FieldValue.serverTimestamp(),
        });

    print("Activity added successfully.");
  }

  void _logTransport(double distance) async {
    double emissions = calculateEmissions(transportMode, distance);
    try {
      await addActivity('Transport ($transportMode)', emissions);
      print("Activity added successfully!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged $emissions kg CO2 emissions for $distance km by $transportMode.'),
          duration: const Duration(seconds: 3),
        ),
      );
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pop(context);
      });
    } catch (e) {
      print("Error adding activity: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging activity: $e')),
      );
    }
  }

  void _calculateAndLogTransport() async {
    await _calculateRoute();
    if (startLatLng != null && endLatLng != null) {
      double distance = Geolocator.distanceBetween(
        startLatLng!.latitude,
        startLatLng!.longitude,
        endLatLng!.latitude,
        endLatLng!.longitude,
      ) / 1000;
      _logTransport(distance);
    }
  }

  Future<void> _getSuggestions(String input) async {
    if (input.isEmpty) {
      setState(() {
        _placeList = [];
      });
      return;
    }
    if (_sessionToken.isEmpty) {
      _sessionToken = uuid.v4();
    }
    final String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    final String requestUrl = '$baseURL?input=$input&key=$_placesApiKey&sessiontoken=$_sessionToken';
    try {
      final response = await http.get(Uri.parse(requestUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _placeList = data['predictions'];
        });
      } else {
        throw Exception('Failed to fetch suggestions');
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  // Call Google Place Details API after selecting a suggestion:
  Future<void> _getPlaceDetail(String placeId) async {
    final String detailsUrl = 'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$_placesApiKey&sessiontoken=$_sessionToken';
    try {
      final response = await http.get(Uri.parse(detailsUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final location = data['result']['geometry']['location'];
        setState(() {
          endLatLng = LatLng(location['lat'], location['lng']);
          // Update TextField with the full address
          endAddressController.text = data['result']['formatted_address'] ?? '';
        });
      } else {
        throw Exception('Failed to fetch place details');
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  void _onSearchChanged(String input) {
    _getSuggestions(input);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
      appBar: AppBar(
        title: const Text('Log Transport'),
        backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 2,
            ),
            markers: markers,
            polylines: polylines,
            onTap: (LatLng latLng) {
              setState(() {
                endLatLng = latLng;
                markers.removeWhere((marker) => marker.markerId.value == 'end');
                markers.add(Marker(
                  markerId: const MarkerId('end'),
                  position: endLatLng!,
                  infoWindow: const InfoWindow(title: 'Selected Location'),
                ));
              });
            },
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              elevation: 8,
              child: Container(
                color: Color.fromARGB(192, 214, 228, 1000), 
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      DropdownButton<String>(
                        value: transportMode,
                        onChanged: (String? newValue) {
                          setState(() {
                            transportMode = newValue!;
                          });
                        },
                        items: <String>['Car', 'Bus', 'Truck', 'Motorcycle']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        dropdownColor: Colors.grey[100], // Set dropdown background color to grey
                        iconEnabledColor: Colors.black87, // Changed icon color
                        style: const TextStyle(color: Colors.black87), // Changed text color
                        underline: Container(), // Removed underline
                      ),
                      const SizedBox(height: 10), // Added spacing between dropdown and button
                      ElevatedButton(
                        onPressed: _calculateAndLogTransport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[100], // Set button background color to grey
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Increased padding
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Adjusted border radius
                        ),
                        child: const Text(
                          'Calculate Route and Log Transport',
                          style: TextStyle(color: Colors.black87), // Changed text color to black
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}