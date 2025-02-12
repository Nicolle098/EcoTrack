import 'package:flutter/material.dart';

class HelpFeatureScreen extends StatelessWidget {
  const HelpFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'AI Chatbot',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}