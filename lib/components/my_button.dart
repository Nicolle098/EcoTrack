import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final VoidCallback onTap;

  const MyButton({super.key, required this.onTap});

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  Color _buttonColor = Colors.blue;

  void _changeColor() {
    setState(() {
      _buttonColor = const Color.fromARGB(255, 18, 111, 187);
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _buttonColor = const Color.fromRGBO(33, 150, 243, 1);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _changeColor();
        widget.onTap();
      },
      child: Container(
        color: _buttonColor,
        padding: const EdgeInsets.all(16.0), // Modify padding to change size
        width: 200.0, // Modify width to change size
        height: 50.0, // Modify height to change size
        child: const Center(
          child: Text(
            'Sign In',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
