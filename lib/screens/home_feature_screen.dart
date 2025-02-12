import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pedometer/pedometer.dart';
import 'log_transport.dart'; // Import the LogTransportScreen

class HomeFeatureScreen extends StatefulWidget {
  const HomeFeatureScreen({super.key});

  @override
  _HomeFeatureScreenState createState() => _HomeFeatureScreenState();
}

class _HomeFeatureScreenState extends State<HomeFeatureScreen> {
  String _stepCount = '0';
  double _totalEmissions = 0.0;
  late Stream<StepCount> _stepCountStream;

  @override
  void initState() {
    super.initState();
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(_onStepCount).onError(_onStepCountError);
    _loadTotalEmissions();
  }

  void _onStepCount(StepCount event) {
    print('Step Count: ${event.steps}');
    setState(() {
      _stepCount = event.steps.toString();
    });
  }

  void _onStepCountError(error) {
    print('Step Count Error: $error');
    setState(() {
      _stepCount = 'Step Count not available';
    });
  }

  Future<void> _loadTotalEmissions() async {
    QuerySnapshot activities = await FirebaseFirestore.instance.collection('activities').get();
    double totalEmissions = 0.0;

    for (var doc in activities.docs) {
      totalEmissions += doc['emissions'];
    }

    setState(() {
      _totalEmissions = totalEmissions;
    });
  }

  Future<String> _getUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return userData['username'] ?? 'User';
    }
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: _getUsername(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error loading username');
                } else {
                  return Text('Hello, ${snapshot.data}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
                }
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 100, // Set a fixed height
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Steps: $_stepCount', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    Text('CO2 Emissions: $_totalEmissions kg', style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Carbon Savings Tips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Tip: Use public transport to reduce your carbon footprint.'),
            const SizedBox(height: 20),
            const Text('Carbon History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Implement history graph here'),
            const SizedBox(height: 20),
            const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LogTransportScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(192, 231, 234, 235), // Background color
                  ),
                  child: const Text('Log Transport'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(192, 231, 234, 235), // Background color
                  ),
                  child: const Text('Log Energy'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(192, 231, 234, 235), // Background color
                  ),
                  child: const Text('Log Diet'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}