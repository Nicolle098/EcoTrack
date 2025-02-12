import 'package:cloud_firestore/cloud_firestore.dart';

class MyFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(String userId, String username, String email) async {
    try {
      // Create a reference to the document
      DocumentReference userRef = _firestore.collection('users').doc(userId);

      // Create the document with initial data
      await userRef.set({
        'username': username,
        'email': email,
        'points': 0,
        'usernameChangeCount': 0,
      });

      print('User document created successfully!');
    } catch (e) {
      print('Error creating user document: $e');
    }
  }

  Future<void> updateUsername(String userId, String newUsername, int usernameChangeCount) async {
    try {
      // Create a reference to the document
      DocumentReference userRef = _firestore.collection('users').doc(userId);

      // Update the username field
      await userRef.update({
        'username': newUsername,
        'usernameChangeCount': usernameChangeCount,
      });

      print('Username updated successfully!');
    } catch (e) {
      print('Error updating username: $e');
    }
  }
}