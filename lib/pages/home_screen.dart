import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:height_prediction/pages/camera_screen.dart';
import 'package:image_picker/image_picker.dart'; // Import the image_picker package
import 'package:http/http.dart' as http; // Import the http package

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final picker = ImagePicker();
  XFile? pickedImage; // To store the picked image file

  Future<void> pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        pickedImage = pickedFile;
      });

      // Convert the picked image to a base64 string
      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);

      // Implement your logic with the base64 string (e.g., send it to the backend)
      sendImageToBackend(base64String);
    }
  }

  // Send the image to the Flask backend
  Future<void> sendImageToBackend(String base64String) async {
    const baseUrl =
        'https://heightprediction-hloiyts3ha-et.a.run.app'; // Your backend URL

    // Define the request body
    final Map<String, String> body = {
      'image': base64String,
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        body: body,
      );
      print('-----------------');
      print(base64String);
      print(response);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        // Handle the response from the backend as needed
        print('Received response from backend: $responseBody');
      } else {
        // Handle the error
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle the HTTP request error
      print('HTTP Request Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to Your App!',
              style: TextStyle(fontSize: 24),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CameraScreen()),
                );
              },
              child: const Text('Turn On Camera'),
            ),
            ElevatedButton(
              onPressed: () {
                pickImageFromGallery(); // Call the function to pick an image
              },
              child: const Text('Pick Image from Gallery'),
            ),
            if (pickedImage != null)
              Image.file(
                File(pickedImage!.path),
                width: 200,
                height: 200,
              ),
          ],
        ),
      ),
    );
  }
}
