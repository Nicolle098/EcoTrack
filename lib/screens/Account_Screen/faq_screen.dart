import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
        title: const Text('FAQs'),
      ),
      body: const Center(
        child: Text('FAQs Screen'),
      ),
    );
  }
}