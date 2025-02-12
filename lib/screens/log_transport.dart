import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogTransportScreen extends StatefulWidget {
  const LogTransportScreen({super.key});

  @override
  _LogTransportScreenState createState() => _LogTransportScreenState();
}

class EmissionFactors {
  static const double petrolEmissionFactor = 3.172; // kg CO2 per kg of fuel
  static const double dieselEmissionFactor = 3.140; // kg CO2 per kg of fuel

  static const double carEmissionPerKm = 0.21; // kg CO2 per km
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
  final TextEditingController distanceController = TextEditingController();
  String transportMode = 'Car';

  void _logTransport() async {
    double distance = double.parse(distanceController.text);
    double emissions = calculateEmissions(transportMode, distance);

    // Store the logged activity and calculated emissions in Firestore
    await FirebaseFirestore.instance.collection('activities').add({
      'type': 'Transport',
      'mode': transportMode,
      'distance': distance,
      'emissions': emissions,
      'timestamp': Timestamp.now(),
    });

    // Show a Snackbar with the CO2 emissions information
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged $emissions kg CO2 emissions for $distance km by $transportMode.'),
        duration: const Duration(seconds: 3),
      ),
    );

    // Navigate back after a delay to allow the user to see the Snackbar
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Transport')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: distanceController,
              decoration: const InputDecoration(labelText: 'Distance (km)'),
              keyboardType: TextInputType.number,
            ),
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
            ),
            ElevatedButton(
              onPressed: _logTransport,
              child: const Text('Log Transport'),
            ),
          ],
        ),
      ),
    );
  }
}