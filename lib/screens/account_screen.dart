import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modernlogintute/screens/login_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'notification_preferences_screen.dart';
import 'privacy_settings_screen.dart';
import 'faq_screen.dart';
import 'terms_of_service_screen.dart';
import 'package:image_picker/image_picker.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController usernameController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  String username = '';
  int points = 0;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
      points = prefs.getInt('points') ?? 0;
    });

    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      setState(() {
        username = userData['username'] ?? '';
        points = userData['points'] ?? 0;
      });
      _saveUserData();
    }
  }

  void _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setInt('points', points);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _uploadImage(File(image.path));
    }
  }

  Future<void> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('profile_pictures/${user!.uid}.jpg');
      await storageRef.putFile(image);
      final downloadUrl = await storageRef.getDownloadURL();
      await user!.updatePhotoURL(downloadUrl);
      setState(() {
        // Update the UI with the new profile picture URL
      });
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _signOut(context); // Proceed with sign out
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _changeUsername() async {
    if (usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username cannot be empty.")),
      );
      return;
    }

    DocumentReference docRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);

    try {
      // Check if the document exists
      await docRef.get().then((docSnapshot) {
        if (docSnapshot.exists) {
          // Document exists, update it
          docRef.update({
            'username': usernameController.text,
          }).then((_) {
            setState(() {
              username = usernameController.text;
            });
            _saveUserData(); // Save the updated username
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Username updated successfully.")),
            );
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error updating username: $error")),
            );
          });
        } else {
          // Document doesn't exist, create it
          docRef.set({
            'username': usernameController.text,
            'points': points, // Initialize points if creating a new document
          }).then((_) {
            setState(() {
              username = usernameController.text;
            });
            _saveUserData(); // Save the updated username
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Username created successfully.")),
            );
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error creating username: $error")),
            );
          });
        }
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error getting document: $error")),
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void _inviteFriend() {
    final String inviteLink = "https://yourapp.com/invite?ref=${user?.uid}";
    Share.share("Join me on this amazing app! Use my invite link: $inviteLink");
  }

  void _changePassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset email sent.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void _confirmChangePassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Change Password'),
          content: const Text('Are you sure you want to change your password?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _changePassword(); // Proceed with change password
              },
              child: const Text('Change Password'),
            ),
          ],
        );
      },
    );
  }

  void _notificationPreferences() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationPreferencesScreen()),
    );
  }

  void _privacySettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacySettingsScreen()),
    );
  }

  void _deleteAccount() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).delete();
      await user!.delete();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete Account'),
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteAccount(); // Proceed with delete account
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _contactSupport() {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@yourapp.com',
      queryParameters: {
        'subject': 'Support Request'
      }
    );
    launch(emailLaunchUri.toString());
  }

  void _faqs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FAQScreen()),
    );
  }

  void _termsOfService() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(192, 214, 228, 232),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(192, 214, 228, 232),
        title: const Text('Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user?.photoURL ?? 'https://via.placeholder.com/150'),
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.camera_alt, size: 15, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
            const SizedBox(height: 20),
            Text('Username: $username', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Email: ${user?.email ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Points: $points', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'New Username'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _changeUsername,
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 34, 32, 32),
                  backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: const Text('Change Username',
              style: TextStyle(fontSize: 17),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _inviteFriend,
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 34, 32, 32),
                  backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: const Text('Invite a Friend',
              style: TextStyle(fontSize: 17),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _confirmSignOut(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 34, 32, 32),
                  backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: const Text('Logout',
              style: TextStyle(fontSize: 17),
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 40),
            const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => _confirmChangePassword(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 34, 32, 32),
                  backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: const Text('Change Password',
              style: TextStyle(fontSize: 17),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _notificationPreferences,
              style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 34, 32, 32),
                  backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: const Text('Notification Preferences',
              style: TextStyle(fontSize: 17),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _privacySettings,
              style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 34, 32, 32),
                  backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: const Text('Privacy Settings',
              style: TextStyle(fontSize: 17),
              ),
            ),
            const Divider(height: 40),
            const Text('Account Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => _confirmDeleteAccount(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 34, 32, 32),
                  backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: const Text('Delete Account',
              style: TextStyle(fontSize: 17),
              ),
            ),
            const Divider(height: 40),
            const Text('Additional Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('App Version: 1.0.0', style: TextStyle(fontSize: 16)),
            TextButton(
              onPressed: _termsOfService,
              style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 34, 32, 32),
                  backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: const Text('Terms of Service',
              style: TextStyle(fontSize: 17),
              ),
            ),
            const Divider(height: 40),
            const Text('Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10), // Add spacing between the text and the first button
              TextButton(
                onPressed: _contactSupport,
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 34, 32, 32),
                  backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                child: const Text('Contact Support',
                style: TextStyle(fontSize: 17),
                ),
              ),
            const SizedBox(height: 10), // Add spacing between the buttons
            TextButton(
              onPressed: _faqs,
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 34, 32, 32),
                backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: const Text('FAQs',
              style: TextStyle(fontSize: 17),
              ),
            ),
          ],
        ),
      ),
    );
  }
}