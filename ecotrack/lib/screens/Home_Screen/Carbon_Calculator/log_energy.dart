import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmissionFactors {
  static const double electricityEmissionFactor = 0.2254;
  static const double naturalGasEmissionFactor = 0.490;
  static const double heatingOilEmissionFactor = 2.52;
  static const double coalEmissionFactor = 3.96;
  static const double lpgEmissionFactor = 1.55;
  static const double woodEmissionFactor = 0.43;
}

class LogEnergyScreen extends StatefulWidget {
  const LogEnergyScreen({super.key});

  @override
  _LogEnergyScreenState createState() => _LogEnergyScreenState();
}

class _LogEnergyScreenState extends State<LogEnergyScreen> {
  final TextEditingController electricityController = TextEditingController();
  final TextEditingController gasController = TextEditingController();
  final TextEditingController heatingOilController = TextEditingController();
  final TextEditingController coalController = TextEditingController();
  final TextEditingController lpgController = TextEditingController();
  final TextEditingController woodController = TextEditingController();

  Future<void> addActivity(String activityName, double emissions) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('log_energy')
        .add({
          'activityName': activityName,
          'totalEmissions': emissions,
          'timestamp': FieldValue.serverTimestamp(),
        });

    print("Energy log added successfully.");
  }

  void _calculateAndLogEnergy() async {
    double electricityConsumption = double.tryParse(electricityController.text) ?? 0.0;
    double gasConsumption = double.tryParse(gasController.text) ?? 0.0;
    double heatingOilConsumption = double.tryParse(heatingOilController.text) ?? 0.0;
    double coalConsumption = double.tryParse(coalController.text) ?? 0.0;
    double lpgConsumption = double.tryParse(lpgController.text) ?? 0.0;
    double woodConsumption = double.tryParse(woodController.text) ?? 0.0;

    double electricityEmissions = electricityConsumption * EmissionFactors.electricityEmissionFactor;
    double gasEmissions = gasConsumption * EmissionFactors.naturalGasEmissionFactor;
    double heatingOilEmissions = heatingOilConsumption * EmissionFactors.heatingOilEmissionFactor;
    double coalEmissions = coalConsumption * EmissionFactors.coalEmissionFactor;
    double lpgEmissions = lpgConsumption * EmissionFactors.lpgEmissionFactor;
    double woodEmissions = woodConsumption * EmissionFactors.woodEmissionFactor;

    double totalEmissions = electricityEmissions + gasEmissions + heatingOilEmissions + coalEmissions + lpgEmissions + woodEmissions;

    try {
      await addActivity('Energy Consumption', totalEmissions);
      print("Energy log added successfully!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged $totalEmissions kg CO2 emissions.'),
          duration: const Duration(seconds: 3),
        ),
      );
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pop(context);
      });
    } catch (e) {
      print("Error adding energy log: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging energy: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Energy Consumption'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(electricityController, 'Electricity Consumption (kWh)'),
              _buildTextField(gasController, 'Natural Gas Consumption (kWh)'),
              _buildTextField(heatingOilController, 'Heating Oil Consumption (liters)'),
              _buildTextField(coalController, 'Coal Consumption (kg)'),
              _buildTextField(lpgController, 'LPG Consumption (liters)'),
              _buildTextField(woodController, 'Wood Consumption (kg)'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculateAndLogEnergy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(171, 214, 255, 217), 
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), 
                ),
                child: const Text(
                  'Calculate and Log Energy Consumption',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          filled: true,
          fillColor: Colors.grey[100], 
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}