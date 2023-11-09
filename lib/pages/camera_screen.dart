import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  final Function(String) onImageCapture;

  const CameraScreen({super.key, required this.onImageCapture});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();

      // Call the function to upload the image or handle it as needed
      uploadImage(imageBytes);
    }
  }

  Future<void> uploadImage(List<int> imageBytes) async {
    var url =
        'https://heightprediction-hloiyts3ha-et.a.run.app/api/v2/predict'; // Replace with your server's endpoint
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
      print('Image uploaded successfully');
      widget.onImageCapture(response.body);
    } else {
      print('Failed to upload image. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickImageFromCamera,
              child: const Text('Take Picture from Camera'),
            ),
          ],
        ),
      ),
    );
  }
}
