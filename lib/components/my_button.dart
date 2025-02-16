import 'package:flutter/material.dart';

class MyButton extends StatefulWidget {
  final VoidCallback onTap;

  const MyButton({super.key, required this.onTap});

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  Color _buttonColor = Color.fromARGB(192, 146, 155, 158);

  void _changeColor() {
    setState(() {
      _buttonColor = Color.fromARGB(192, 146, 155, 158);
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _buttonColor = Color.fromARGB(192, 146, 155, 158);
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
