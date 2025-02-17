import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pedometer/pedometer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'Carbon_Calculator/log_transport.dart';
import 'Carbon_Calculator/log_energy.dart';

class HomeFeatureScreen extends StatefulWidget {
  const HomeFeatureScreen({super.key});

  @override
  _HomeFeatureScreenState createState() => _HomeFeatureScreenState();
}

class AQIState {
  final int aqi;
  final String state;
  final Color color;

  AQIState({required this.aqi, required this.state, required this.color});

  static AQIState fromAQI(int aqi) {
    if (aqi >= 0 && aqi <= 50) {
      return AQIState(
        aqi: aqi,
        state: 'Good',
        color: const Color.fromARGB(255, 103, 161, 105),
      );
    } else if (aqi >= 51 && aqi <= 100) {
      return AQIState(
        aqi: aqi,
        state: 'Moderate',
        color: const Color.fromARGB(255, 58, 90, 59),
      );
    } else if (aqi >= 101 && aqi <= 150) {
      return AQIState(
        aqi: aqi,
        state: 'Unhealthy for Sensitive Groups',
        color: const Color.fromARGB(255, 32, 49, 32),
      );
    } else if (aqi >= 151 && aqi <= 200) {
      return AQIState(
        aqi: aqi,
        state: 'Unhealthy',
        color: const Color.fromARGB(255, 20, 31, 20),
      );
    } else if (aqi >= 201 && aqi <= 300) {
      return AQIState(
        aqi: aqi,
        state: 'Very Unhealthy',
        color: const Color.fromARGB(255, 22, 34, 22),
      );
    } else if (aqi >= 301) {
      return AQIState(
        aqi: aqi,
        state: 'Hazardous',
        color: const Color.fromARGB(255, 17, 13, 12),
      );
    } else {
      return AQIState(
        aqi: aqi,
        state: 'Unknown',
        color: Colors.grey,
      );
    }
  }
}

class _HomeFeatureScreenState extends State<HomeFeatureScreen> {
  String _stepCount = '0';
  double _totalEmissions = 0.0;
  String _aqi = 'Loading...';
  AQIState? _aqiState;
  late Stream<StepCount> _stepCountStream;
  List<FlSpot> _carbonData = [];

  @override
  void initState() {
    super.initState();
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(_onStepCount).onError(_onStepCountError);
    _fetchCarbonFootprint();
    _loadCarbonData();
    _loadAQI();
  }

  void _onStepCount(StepCount event) {
    setState(() {
      _stepCount = event.steps.toString();
    });
  }

  void _onStepCountError(error) {
    setState(() {
      _stepCount = 'Step Count not available';
    });
  }

  Future<void> _fetchCarbonFootprint() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    double totalFootprint = 0.0;

    // Check if the user document exists before querying subcollections
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      print("User document not found.");
      return;
    }

    // Fetch activities
    QuerySnapshot activitySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('activities')
        .get();

    for (var doc in activitySnapshot.docs) {
      if (doc['emissions'] != null) {
        totalFootprint += doc['emissions']; 
      }
    }

    // Fetch energy logs
    QuerySnapshot energySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('log_energy')
        .get();

    for (var doc in energySnapshot.docs) {
      if (doc['totalEmissions'] != null) {
        totalFootprint += doc['totalEmissions'];
      }
    }

    setState(() {
      _totalEmissions = totalFootprint;
    });

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'carbonFootprint': totalFootprint,
    });

    print("Fetched carbon footprint: $totalFootprint kg CO2");
  }

  Future<void> _loadCarbonData() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    QuerySnapshot activities = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('activities')
        .get();
    Map<int, double> dailyEmissions = {};

    for (var doc in activities.docs) {
      Timestamp timestamp = doc['timestamp'];
      DateTime date = timestamp.toDate();
      int day = date.day;
      double emissions = doc['emissions'];

      dailyEmissions[day] = (dailyEmissions[day] ?? 0) + emissions;
    }

    setState(() {
      _carbonData = List.generate(30, (i) => FlSpot((i + 1).toDouble(), dailyEmissions[i + 1] ?? 0.0));
    });
  }

  Future<void> _loadAQI() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final String apiKey = 'AIzaSyD3VzgeADSiZwvc8ujBjzhCVA34GRqRItM'; // Replace with your Google Cloud API Key
      final String requestUrl = 'https://airquality.googleapis.com/v1/currentConditions:lookup?key=$apiKey';

      final response = await http.post(
        Uri.parse(requestUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'location': {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final aqi = int.parse(data['indexes'][0]['aqiDisplay']);
        setState(() {
          _aqi = aqi.toString();
          _aqiState = AQIState.fromAQI(aqi);
        });
      } else {
        throw Exception('Failed to load AQI: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() {
        _aqi = 'Error loading AQI';
        _aqiState = null;
      });
      print('Error loading AQI: $e');
    }
  }

  Future<String> _getUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return userData['username'] ?? 'User';
    }
    return 'User';
  }

  void _refreshData() {
    setState(() {
      _fetchCarbonFootprint(); // Refresh total emissions
      _loadCarbonData(); // Refresh carbon data
      _loadAQI(); // Refresh AQI
    });
  }

  Future<void> addActivity(String activityName, double emissions) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
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
    } catch (e) {
      print("Error adding activity: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding activity: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 193, 202, 196),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FutureBuilder<String>(
                  future: _getUsername(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text('Error loading username');
                    } else {
                      return Row(
                        children: [
                          Icon(CupertinoIcons.person, size: 28, color: Colors.black87), 
                          const SizedBox(width: 8), 
                          Text(
                            'Hello, ${snapshot.data}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w200,
                              color: Colors.black87, 
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.refresh, size: 28, color: Colors.black87),
                  onPressed: _refreshData,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStatCard('Steps', '$_stepCount', CupertinoIcons.person_alt_circle),
            const SizedBox(height: 10),
            _buildStatCard('CO₂ Emissions', '$_totalEmissions kg', CupertinoIcons.cloud),
            const SizedBox(height: 10),
            _buildStatCard('Air Quality Index', _aqi, CupertinoIcons.wind, _aqiState),
            const SizedBox(height: 20),
            _buildGraphCard(),
            const SizedBox(height: 20),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, [AQIState? aqiState]) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0), 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6), // Adjusted spacing
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)), 
                if (aqiState != null) ...[
                  const SizedBox(height: 6),
                  Text(aqiState.state, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: aqiState.color)),
                ],
              ],
            ),
            Icon(icon, size: 45, color: Colors.blueGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Carbon History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), 
            const SizedBox(height: 10),
            SizedBox(
              height: 220, 
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _carbonData,
                      isCurved: true,
                      color: const Color.fromARGB(255, 138, 175, 140),
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 138, 175, 140).withOpacity(0.5),
                            const Color.fromARGB(255, 138, 175, 140).withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton('Log Transport', CupertinoIcons.car_detailed, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LogTransportScreen()))),
        _buildActionButton('Log Energy', CupertinoIcons.bolt, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LogEnergyScreen()))),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 24, color: Colors.white), 
      label: Text(label, style: const TextStyle(fontSize: 18)), 
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), 
      ),
    );
  }
}