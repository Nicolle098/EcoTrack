import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:modernlogintute/screens/login_screen.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const EcoTrack());
}

class EcoTrack extends StatelessWidget {
  const EcoTrack({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

