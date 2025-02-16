import 'package:flutter/material.dart';

class ImproveFeatureScreen extends StatelessWidget {
  const ImproveFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Here are some ways to improve',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}