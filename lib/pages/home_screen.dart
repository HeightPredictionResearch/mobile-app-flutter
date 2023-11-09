import 'package:flutter/material.dart';
import 'package:height_prediction/pages/camera_screen.dart';
import 'package:height_prediction/pages/response_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final Dio _dio = Dio();
  String responseBody = '';

  void navigateToResponseScreen(String responseBody) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResponseScreen(responseBody),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      // Create FormData and append the image file
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path),
      });

      try {
        // Make a POST request to your server to upload the image
        var response = await _dio.post(
            'https://heightprediction-hloiyts3ha-et.a.run.app/api/v2/predict',
            data: formData);

        setState(() {
          responseBody = response.data.toString();
        });

        navigateToResponseScreen(responseBody);
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera & Gallery Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CameraScreen(
                      onImageCapture: (response) {
                        setState(() {
                          responseBody = response;
                        });
                        navigateToResponseScreen(responseBody);
                      },
                    ),
                  ),
                );
              },
              child: const Text('Take Picture from Camera'),
            ),
            ElevatedButton(
              onPressed: _pickImageFromGallery,
              child: const Text('Pick Picture from Gallery'),
            ),
          ],
        ),
      ),
    );
  }
}
