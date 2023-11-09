import 'package:flutter/material.dart';
import 'package:height_prediction/pages/camera_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class HomeScreen extends StatelessWidget {
  final ImagePicker _imagePicker = ImagePicker();
  final Dio _dio = Dio();

  HomeScreen({super.key});

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
        print(response.data);
        // Handle the response as needed
        // You can show a success message or navigate to a different screen
      } catch (e) {
        // Handle errors
        print('Error uploading image: $e');
        // You can show an error message or perform error handling here
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
                    builder: (context) => const CameraScreen(),
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
