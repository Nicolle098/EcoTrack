import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  _PrivacySettingsScreenState createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _profileVisibility = true;
  bool _dataSharing = false;
  bool _activityStatus = true;
  bool _personalizedAds = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileVisibility = prefs.getBool('profileVisibility') ?? true;
      _dataSharing = prefs.getBool('dataSharing') ?? false;
      _activityStatus = prefs.getBool('activityStatus') ?? true;
      _personalizedAds = prefs.getBool('personalizedAds') ?? true;
    });
  }

  void _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profileVisibility', _profileVisibility);
    await prefs.setBool('dataSharing', _dataSharing);
    await prefs.setBool('activityStatus', _activityStatus);
    await prefs.setBool('personalizedAds', _personalizedAds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
        title: const Text('Privacy Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Profile Visibility'),
              subtitle: const Text('Control who can see your profile'),
              value: _profileVisibility,
              onChanged: (bool value) {
                setState(() {
                  _profileVisibility = value;
                });
                _savePreferences();
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Data Sharing'),
              subtitle: const Text('Allow sharing of your data with third parties'),
              value: _dataSharing,
              onChanged: (bool value) {
                setState(() {
                  _dataSharing = value;
                });
                _savePreferences();
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Activity Status'),
              subtitle: const Text('Show your online status to others'),
              value: _activityStatus,
              onChanged: (bool value) {
                setState(() {
                  _activityStatus = value;
                });
                _savePreferences();
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Personalized Ads'),
              subtitle: const Text('Receive personalized ads based on your activity'),
              value: _personalizedAds,
              onChanged: (bool value) {
                setState(() {
                  _personalizedAds = value;
                });
                _savePreferences();
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Blocked Users'),
              subtitle: const Text('Manage your blocked users list'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Delete Account'),
              subtitle: const Text('Permanently delete your account'),
              trailing: const Icon(Icons.delete, color: Color.fromARGB(255, 133, 211, 211)),
              onTap: () {
              },
            ),
          ],
        ),
      ),
    );
  }
}