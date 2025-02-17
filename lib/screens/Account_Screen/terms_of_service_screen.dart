import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';

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
      String terms = await rootBundle.loadString('assets/terms_of_service_1.txt');
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
        backgroundColor: const Color.fromARGB(192, 214, 228, 232),
        title: const Text('Terms of Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            color: const Color.fromARGB(255, 237, 240, 238),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _termsOfService,
                style: GoogleFonts.lato(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}