import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:modernlogintute/screens/Login_Screen/login_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
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
    });

    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      setState(() {
        username = userData['username'] ?? '';
      });
      _saveUserData();
    }
  }

  void _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File image = File(pickedFile.path);
      await _uploadImage(image);
    }
  }

  Future<void> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('profile_pictures/${user!.uid}.jpg');
      await storageRef.putFile(image);
      final downloadUrl = await storageRef.getDownloadURL();
      await user!.updatePhotoURL(downloadUrl);
      setState(() {
        user = FirebaseAuth.instance.currentUser;
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
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _signOut(context);
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
      await docRef.get().then((docSnapshot) {
        if (docSnapshot.exists) {
          docRef.update({
            'username': usernameController.text,
          }).then((_) {
            setState(() {
              username = usernameController.text;
            });
            _saveUserData();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Username updated successfully.")),
            );
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error updating username: $error")),
            );
          });
        } else {
          docRef.set({
            'username': usernameController.text,
          }).then((_) {
            setState(() {
              username = usernameController.text;
            });
            _saveUserData();
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
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _changePassword();
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
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
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
      path: 'ecotrack@gmail.com',
      queryParameters: {
        'subject': 'Support Request'
      }
    );
    launchUrl(emailLaunchUri);
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
      backgroundColor: const Color.fromARGB(255, 210, 214, 211), // Lighter background color
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 216, 219, 217), // Lighter background color
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
            Text('Username: $username', style: GoogleFonts.lato(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Email: ${user?.email ?? 'N/A'}', style: GoogleFonts.lato(fontSize: 18)),
            const SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'New Username',
                labelStyle: GoogleFonts.lato(),
                filled: true,
                fillColor: const Color.fromARGB(255, 237, 240, 238),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _changeUsername,
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
                backgroundColor: const Color.fromARGB(255, 237, 240, 238),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: Text('Change Username', style: GoogleFonts.lato(fontSize: 17)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _inviteFriend,
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
                backgroundColor: const Color.fromARGB(255, 237, 240, 238),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: Text('Invite a Friend', style: GoogleFonts.lato(fontSize: 17)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _confirmSignOut(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
                backgroundColor: const Color.fromARGB(255, 237, 240, 238),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: Text('Logout', style: GoogleFonts.lato(fontSize: 17)),
            ),
            const SizedBox(height: 10),
            const Divider(height: 40),
            Text('Settings', style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => _confirmChangePassword(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
                backgroundColor: const Color.fromARGB(255, 237, 240, 238),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: Text('Change Password', style: GoogleFonts.lato(fontSize: 17)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _notificationPreferences,
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
                backgroundColor: const Color.fromARGB(255, 237, 240, 238),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: Text('Notification Preferences', style: GoogleFonts.lato(fontSize: 17)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _privacySettings,
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
                backgroundColor: const Color.fromARGB(255, 237, 240, 238),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: Text('Privacy Settings', style: GoogleFonts.lato(fontSize: 17)),
            ),
            const Divider(height: 40),
            Text('Account Actions', style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => _confirmDeleteAccount(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
                backgroundColor: const Color.fromARGB(255, 237, 240, 238),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: Text('Delete Account', style: GoogleFonts.lato(fontSize: 17)),
            ),
            const Divider(height: 40),
            Text('Additional Information', style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('App Version: 1.0.0', style: GoogleFonts.lato(fontSize: 16)),
            TextButton(
              onPressed: _termsOfService,
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
                backgroundColor: const Color.fromARGB(255, 237, 240, 238),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: Text('Terms of Service', style: GoogleFonts.lato(fontSize: 17)),
            ),
            const Divider(height: 40),
            Text('Support', style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _contactSupport,
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
                backgroundColor: const Color.fromARGB(255, 237, 240, 238),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: Text('Contact Support', style: GoogleFonts.lato(fontSize: 17)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _faqs,
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
                backgroundColor: const Color.fromARGB(255, 237, 240, 238),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              child: Text('FAQs', style: GoogleFonts.lato(fontSize: 17)),
            ),
          ],
        ),
      ),
    );
  }
}