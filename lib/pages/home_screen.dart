import 'package:flutter/material.dart';
import 'package:height_prediction/pages/camera_screen.dart';
import 'package:height_prediction/pages/response_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
  bool isLoading = false;

  void navigateToResponseScreen(String responseBody) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResponseScreen(responseBody),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    setState(() {
      isLoading = true; // Set isLoading to true
    });
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
          isLoading = false;
          responseBody = response.data.toString();
        });

        navigateToResponseScreen(responseBody);
      } catch (e) {
        print('Error uploading image: $e');
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera & Gallery Example'),
      ),
      body: Center(
          child: isLoading
              ? SpinKitCircle(
                  color: Colors.blue, size: 50.0) // Display loading spinner
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
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
                      child: Text('Take Image and Send'),
                    ),
                    ElevatedButton(
                      onPressed: _pickImageFromGallery,
                      child: Text('Pick Image and Send'),
                    ),
                  ],
                ),
        )
    );
  }
}
