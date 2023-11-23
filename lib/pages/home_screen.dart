import 'package:flutter/material.dart';
import 'package:height_prediction/pages/child/child_list_screen.dart';
import 'package:height_prediction/pages/child/child_registration_screen.dart';
import 'package:height_prediction/pages/response_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

import 'dart:io';
import 'package:dio/dio.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String baseUrl = 'https://heightprediction-hloiyts3ha-et.a.run.app';
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

  void _navigateToChildRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChildRegistrationScreen()),
    );
  }

  void _navigateToChildList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChildListScreen()),
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
          '$baseUrl/api/v2/predict',
          data: formData
        );

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

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      isLoading = true;
    });

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();

      // Call the function to upload the image or handle it as needed
      await uploadImage(imageBytes);
    }
    // Once the image is sent, set isLoading back to false
    setState(() {
      isLoading = false;
    });
  }

  Future<void> uploadImage(List<int> imageBytes) async {
    var url = '$baseUrl/api/v2/predict'; 
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Create a MultipartFile from the image bytes
    request.files.add(http.MultipartFile.fromBytes(
      'image', // Field name for the image
      imageBytes, // List of image bytes
      filename: 'image.jpg', // Specify a filename
    ));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      setState(() {
        responseBody = response.body.toString();
      });
      navigateToResponseScreen(responseBody);
    } else {
      print('Failed to upload image. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Prediksi Tinggi Anak'),
      ),
      body: Center(
        child: Container(
          // width: double.infinity,
          // decoration: const BoxDecoration(
          //   image: DecorationImage(
          //     image: AssetImage('assets/background.jpeg'), // Update the path to your image
          //     fit: BoxFit.fill, // You can use BoxFit.contain for a different scaling strategy
          //   ),
          // ),
          child: isLoading
            ? const Column (
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                SpinKitCircle(color: Colors.blue, size: 50.0),
                Text('Menunggu Hasil Prediksi'),
              ] // Display loading spinner
            )
            : Container(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2, // Number of columns
                mainAxisSpacing:
                    16.0, // Spacing between items in the main axis (vertical spacing)
                crossAxisSpacing:
                    16.0, // Spacing between items in the cross axis (horizontal spacing)
                children: [
                  // Menu item 1 - Take Image and Send
                  ElevatedButton(
                    onPressed: _pickImageFromCamera,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Take Image and Send'),
                  ),

                  // Menu item 2 - Pick Image From Gallery
                  ElevatedButton(
                    onPressed: _pickImageFromGallery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white, 
                    ),
                    child: const Text('Pick Image From Gallery'),
                  ),

                  // Menu item 3 - Register Child
                  ElevatedButton(
                    onPressed: _navigateToChildRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Pendaftaran Anak'),
                  ),

                  // Menu item 4 - List Child
                  ElevatedButton(
                    onPressed: _navigateToChildList,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Daftar Anak Anda'),
                  ),
                ],
              ),
            ),
        )
      )
    );
  }
}
