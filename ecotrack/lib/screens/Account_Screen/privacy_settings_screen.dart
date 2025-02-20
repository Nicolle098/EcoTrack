import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: const Color.fromARGB(255, 215, 219, 216),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 193, 197, 194),
        title: const Text('Privacy Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: const Color.fromARGB(255, 237, 240, 238),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SwitchListTile(
                  title: Text('Profile Visibility', style: GoogleFonts.lato(fontSize: 18)),
                  subtitle: Text('Control who can see your profile', style: GoogleFonts.lato(fontSize: 16)),
                  value: _profileVisibility,
                  onChanged: (bool value) {
                    setState(() {
                      _profileVisibility = value;
                    });
                    _savePreferences();
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: const Color.fromARGB(255, 237, 240, 238),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SwitchListTile(
                  title: Text('Data Sharing', style: GoogleFonts.lato(fontSize: 18)),
                  subtitle: Text('Allow sharing of your data with third parties', style: GoogleFonts.lato(fontSize: 16)),
                  value: _dataSharing,
                  onChanged: (bool value) {
                    setState(() {
                      _dataSharing = value;
                    });
                    _savePreferences();
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: const Color.fromARGB(255, 237, 240, 238),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SwitchListTile(
                  title: Text('Activity Status', style: GoogleFonts.lato(fontSize: 18)),
                  subtitle: Text('Show your online status to others', style: GoogleFonts.lato(fontSize: 16)),
                  value: _activityStatus,
                  onChanged: (bool value) {
                    setState(() {
                      _activityStatus = value;
                    });
                    _savePreferences();
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: const Color.fromARGB(255, 237, 240, 238),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SwitchListTile(
                  title: Text('Personalized Ads', style: GoogleFonts.lato(fontSize: 18)),
                  subtitle: Text('Receive personalized ads based on your activity', style: GoogleFonts.lato(fontSize: 16)),
                  value: _personalizedAds,
                  onChanged: (bool value) {
                    setState(() {
                      _personalizedAds = value;
                    });
                    _savePreferences();
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              color: const Color.fromARGB(255, 237, 240, 238),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                title: Text('Delete Account', style: GoogleFonts.lato(fontSize: 18)),
                subtitle: Text('Permanently delete your account', style: GoogleFonts.lato(fontSize: 16)),
                trailing: const Icon(Icons.delete, color: Color.fromARGB(255, 112, 131, 123)),
                onTap: () {
                  // Add delete account functionality here
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}