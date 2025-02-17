import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modernlogintute/screens/Home_Screen/home_feature_screen.dart';
import 'package:modernlogintute/screens/Help_Screen/chatbot_screen.dart';
import 'package:modernlogintute/screens/News/improve_feature_screen.dart';
import 'package:modernlogintute/screens/Account_Screen/account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  double _carbonFootprint = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchCarbonFootprint();
    _listenToCarbonFootprint();
  }

  Future<void> _fetchCarbonFootprint() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    double totalFootprint = 0.0;

    // Fetch activities
    QuerySnapshot activitySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('activities')
        .get();

    for (var doc in activitySnapshot.docs) {
      print("Activity doc: ${doc.data()}");
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
      print("Energy log doc: ${doc.data()}");
      if (doc['totalEmissions'] != null) {
        totalFootprint += doc['totalEmissions'];
      }
    }

    setState(() {
      _carbonFootprint = totalFootprint;
    });

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'carbonFootprint': totalFootprint,
    });

    print("Fetched carbon footprint: $totalFootprint kg CO2");
  }

  void _listenToCarbonFootprint() {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('activities')
        .snapshots()
        .listen((_) => _fetchCarbonFootprint());

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('log_energy')
        .snapshots()
        .listen((_) => _fetchCarbonFootprint());
  }

  List<Widget> _widgetOptions() {
    return [
      HomeFeatureScreen(),
      ChatbotScreen(),
      ImproveFeatureScreen(carbonFootprint: _carbonFootprint), // Use dynamic value
      AccountScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 150, 163, 153), 
      body: Center(
        child: _widgetOptions().elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: 'Help',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.priority_high),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: const Color.fromARGB(255, 158, 158, 158),
        onTap: _onItemTapped,
      ),
    );
  }
}