// child_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchChildDetails();
  }

  Future<void> _fetchChildDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await _dio.get('$baseUrl/api/v1/child/${widget.childId}');

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
      // Handle other errors if necessary
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Child Detail - ${childDetails['name']}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Child Name: ${childDetails['name']}'),
                  Text('Birth Date: ${childDetails['birth_date']}'),
                  // Add more details as needed
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate back to the ChildListScreen
                      Navigator.pop(context);
                    },
                    child: const Text('Back to Child List'),
                  ),
                ],
              ),
      ),
    );
  }
}
