import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  _NotificationPreferencesScreenState createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;
  String _notificationFrequency = 'Daily';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _emailNotifications = prefs.getBool('emailNotifications') ?? true;
      _pushNotifications = prefs.getBool('pushNotifications') ?? true;
      _smsNotifications = prefs.getBool('smsNotifications') ?? false;
      _notificationFrequency = prefs.getString('notificationFrequency') ?? 'Daily';
    });
  }

  void _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('emailNotifications', _emailNotifications);
    await prefs.setBool('pushNotifications', _pushNotifications);
    await prefs.setBool('smsNotifications', _smsNotifications);
    await prefs.setString('notificationFrequency', _notificationFrequency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 215, 219, 216),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 215, 219, 216),
        title: const Text('Notification Preferences'),
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
                  title: Text('Enable Notifications', style: GoogleFonts.lato(fontSize: 18)),
                  value: _notificationsEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    _savePreferences();
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Notification Types', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              color: const Color.fromARGB(255, 237, 240, 238),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text('Email Notifications', style: GoogleFonts.lato(fontSize: 18)),
                      value: _emailNotifications,
                      onChanged: (bool value) {
                        setState(() {
                          _emailNotifications = value;
                        });
                        _savePreferences();
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: Text('Push Notifications', style: GoogleFonts.lato(fontSize: 18)),
                      value: _pushNotifications,
                      onChanged: (bool value) {
                        setState(() {
                          _pushNotifications = value;
                        });
                        _savePreferences();
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: Text('SMS Notifications', style: GoogleFonts.lato(fontSize: 18)),
                      value: _smsNotifications,
                      onChanged: (bool value) {
                        setState(() {
                          _smsNotifications = value;
                        });
                        _savePreferences();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Notification Frequency', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              color: const Color.fromARGB(255, 237, 240, 238),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButton<String>(
                  value: _notificationFrequency,
                  onChanged: (String? newValue) {
                    setState(() {
                      _notificationFrequency = newValue!;
                    });
                    _savePreferences();
                  },
                  items: <String>['Immediately', 'Daily', 'Weekly']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: GoogleFonts.lato(fontSize: 18)),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}