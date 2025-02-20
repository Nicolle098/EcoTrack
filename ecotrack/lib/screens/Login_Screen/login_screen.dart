import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modernlogintute/components/my_textfield.dart';
import 'package:modernlogintute/components/my_button.dart';
import 'package:modernlogintute/screens/Home_Screen/home_screen.dart';
import 'package:modernlogintute/screens/Login_Screen/register_screen.dart';
import 'package:modernlogintute/screens/Login_Screen/verify_email_screen.dart';
import 'package:modernlogintute/screens/Login_Screen/reset_password_screen.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (userCredential.user?.emailVerified ?? false) {
        // Navigate to HomeScreen upon successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Email is not verified
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please verify your email to continue.")),
        );
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const VerifyEmailScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle sign-in error
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
      body: SafeArea(
        child: Center(
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
                'Every Action Counts',
                style: TextStyle(
                  color: Color.fromARGB(1000, 102, 123, 104),
                  fontSize: 21,
                ),
              ),
              const Text(
                'Start Tracking!',
                style: TextStyle(
                  color: Color.fromARGB(1000, 102, 123, 104),
                  fontSize: 21,
                ),
              ),
              const SizedBox(height: 35),

              // username textfield
              MyTextField(
                controller: emailController,
                hintText: 'Email adress',
                obscureText: false,
              ),

              const SizedBox(height: 10),

              // password textfield
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              const SizedBox(height: 10),

              // forgot password?
               Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ResetPasswordScreen()),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
               ),

              const SizedBox(height: 25),

              // sign in button
              MyButton(
                onTap: () => signUserIn(context),
              ),

              const SizedBox(height: 50),

              const SizedBox(height: 50),

              // not a member? register now
              // not a member? register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not a member?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      'Register now',
                      style: TextStyle(
                        color: Color.fromARGB(1000, 102, 123, 104),
                        fontWeight: FontWeight.bold,
                    ),
                  ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}