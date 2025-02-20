import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modernlogintute/screens/Login_Screen/verify_email_screen.dart';
import 'package:modernlogintute/components/my_textfield.dart';
import 'package:modernlogintute/components/my_button.dart';
import 'package:modernlogintute/services/firestore_service.dart'; // Import the Firestore service

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  bool isLoading = false;

  final MyFirestoreService _firestoreService = MyFirestoreService(); // Initialize the Firestore service

  void registerUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Store user data in Firestore
      await _firestoreService.createUser(
        userCredential.user!.uid,
        usernameController.text,
        emailController.text,
      );

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      // Handle successful registration
      print("Registered: ${userCredential.user?.email}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification email sent to ${userCredential.user?.email}")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VerifyEmailScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle registration error
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset(
                  'assets/images/logo.png',
                  width: 180,
                  height: 180,
                ),
                const SizedBox(height: 50),
                const Text(
                  'Be proud!',
                  style: TextStyle(
                    color: Color.fromARGB(1000, 102, 123, 104),
                    fontSize: 21,
                  ),
                ),
                const Text(
                  'You stepped up for a change!',
                  style: TextStyle(
                    color: Color.fromARGB(1000, 102, 123, 104),
                    fontSize: 21,
                  ),
                ),
                const SizedBox(height: 35),
                MyTextField(
                  controller: emailController,
                  hintText: 'Email address',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                const SizedBox(height: 25),
                isLoading
                    ? const CircularProgressIndicator()
                    : MyButton(
                        onTap: registerUser,
                      ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}