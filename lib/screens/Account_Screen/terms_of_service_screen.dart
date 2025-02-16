import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  _TermsOfServiceScreenState createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  String _termsOfService = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadTermsOfService();
  }

  void _loadTermsOfService() async {
    try {
      String terms = await rootBundle.loadString('assets/terms_of_service.txt');
      setState(() {
        _termsOfService = terms;
      });
    } catch (e) {
      print('Error loading terms of service: $e');
      setState(() {
        _termsOfService = 'Failed to load terms of service.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(192, 214, 228, 232),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
        title: const Text('Terms of Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(_termsOfService),
        ),
      ),
    );
  }
}