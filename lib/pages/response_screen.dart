// In response_screen.dart
import 'package:flutter/material.dart';

class ResponseScreen extends StatelessWidget {
  final String responseBody;

  const ResponseScreen(this.responseBody, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Response Screen'),
      ),
      body: Center(
        child: Text(
          responseBody,
          style: const TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}
