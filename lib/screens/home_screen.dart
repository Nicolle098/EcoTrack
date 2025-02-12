import 'package:flutter/material.dart';
import 'package:modernlogintute/screens/home_feature_screen.dart';
import 'package:modernlogintute/screens/help_feature_screen.dart';
import 'package:modernlogintute/screens/improve_feature_screen.dart';
import 'package:modernlogintute/screens/board_feature_screen.dart';
import 'package:modernlogintute/screens/account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeFeatureScreen(),
    HelpFeatureScreen(),
    ImproveFeatureScreen(),
    BoardFeatureScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
      appBar: AppBar(
        title: const Text('EcoTrack'),
        backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
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
            label: 'Improve',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.spa),
            label: 'Board',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}