import 'package:flutter/material.dart';

class BoardFeatureScreen extends StatelessWidget {
  const BoardFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Comparisons',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}