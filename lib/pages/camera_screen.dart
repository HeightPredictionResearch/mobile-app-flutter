import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  XFile? capturedImage;
  bool isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.medium);
    await _controller.initialize();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _captureImage() async {
    setState(() {
      isCapturing = true;
    });
    try {
      XFile file = await _controller.takePicture();
      setState(() {
        capturedImage = file;
      });

      // Convert the captured image to base64
      final bytes = await File(file.path).readAsBytes();
      final base64String = base64Encode(bytes);

      // Send the image to the backend for processing
      await sendImageToBackend(base64String);
    } catch (e) {
      print('Error capturing image: $e');
    } finally {
      setState(() {
        isCapturing = false;
      });
    }
  }

  Future<void> sendImageToBackend(String base64String) async {
    const baseUrl =
        'https://heightprediction-hloiyts3ha-et.a.run.app'; // Your backend URL

    final Map<String, String> body = {
      'image': base64String,
    };

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: body,
      );
      print('-----------------');
      print(body);
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
    if (_controller == null || !_controller.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Camera Loading...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Screen'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: CameraPreview(_controller),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: isCapturing ? null : _captureImage,
                child: Text(isCapturing ? 'Capturing...' : 'Capture Image'),
              ),
            ),
          ),
          if (capturedImage != null)
            Expanded(
              flex: 2,
              child: Center(
                child: Image.file(
                  File(capturedImage!.path),
                  width: 200,
                  height: 200,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
