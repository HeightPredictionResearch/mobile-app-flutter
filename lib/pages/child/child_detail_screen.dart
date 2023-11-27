import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class ChildDetailScreen extends StatefulWidget {
  final int childId;

  const ChildDetailScreen({Key? key, required this.childId}) : super(key: key);

  @override
  _ChildDetailScreenState createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends State<ChildDetailScreen> {
  final String baseUrl = 'https://heightprediction-hloiyts3ha-et.a.run.app';
  final Dio _dio = Dio();
  Map<String, dynamic> childDetails = {};
  List<Map<String, dynamic>> heightData = [];
  bool pageIsLoading = false;
  bool tableIsLoading = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchChildDetails();
    _fetchHeightData();
  }

  Future<void> _fetchChildDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    setState(() {
      pageIsLoading = true;
    });

    try {
      final response = await _dio.get('$baseUrl/api/v1/child/${widget.childId}',
          options: Options(headers: {'Authorization': token}));

      if (response.statusCode == 200) {
        setState(() {
          childDetails = response.data;
        });
      } else {
        // Handle failure
        print(
            'Failed to fetch child details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during child details fetch: $e');
      _showErrorDialog('Failed fetching data');
    } 
  }

  Future<void> _fetchHeightData() async {
    try {
      final response =
          await _dio.get('$baseUrl/api/v1/predict/${widget.childId}');

      if (response.statusCode == 200) {
        setState(() {
          heightData = List<Map<String, dynamic>>.from(response.data);
        });
      } else {
        // Handle failure
        print(
            'Failed to fetch height data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during height data fetch: $e');
      _showErrorDialog('Failed fetching data');
    } finally {
      setState(() {
        pageIsLoading = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() {
      tableIsLoading = true;
    });
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      // Create FormData and append the image file
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path),
        'child_id': widget.childId.toString(),
      });

      try {
        // Make a POST request to your server to upload the image
        var response = await _dio.post(
          '$baseUrl/api/v2/predict',
          data: formData,
        );

        // Handle the response as needed
        print('Image upload response: ${response.data}');

        // After uploading the image, fetch the updated height data
        await _fetchHeightData();
      } catch (e) {
        print('Error uploading image: $e');
        _showErrorDialog('Error uploading image');
      } finally {
        setState(() {
          tableIsLoading = false;
        });
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    setState(() {
      tableIsLoading = true;
    });
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path),
        'child_id': widget.childId.toString(),
      });

      try {
        var response = await _dio.post(
          '$baseUrl/api/v2/predict',
          data: formData,
        );

        // Handle the response as needed
        print('Image upload response: ${response.data}');

        // After uploading the image, fetch the updated height data
        await _fetchHeightData();
      } catch (e) {
        print('Error uploading image: $e');
        _showErrorDialog('Error uploading image');
      } finally {
        setState(() {
          tableIsLoading = false;
        });
      }
    }
  }

  // Helper method to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Something went wrong'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${childDetails['name']}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: pageIsLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Child Name: ${childDetails['name']}'),
                  Text(
                      'Birth Date: ${childDetails['birth_date'].toString().substring(0, 16)}'),
                  // Add more details as needed
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _pickImageFromGallery();
                    },
                    child: const Text('Pick Image From Gallery'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _pickImageFromCamera();
                    },
                    child: const Text('Take Image and Send'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Height Data:'),
                  tableIsLoading ? 
                  const Positioned(
                      child: Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : DataTable(
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Height')),
                      DataColumn(label: Text('Taken Date')),
                    ],
                    rows: heightData.map((data) => DataRow(
                      cells: [
                        DataCell(Text(data['id'].toString())),
                        DataCell(Text(data['height'].toString())),
                        DataCell(Text(data['taken_date'])),
                      ],
                    )).toList(),
                  ),
                ],
              ),
      ),
    );
  }
}
