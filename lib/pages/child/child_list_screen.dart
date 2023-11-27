import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:height_prediction/pages/child/child_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChildListScreen extends StatefulWidget {
  const ChildListScreen({Key? key}) : super(key: key);

  @override
  _ChildListScreenState createState() => _ChildListScreenState();
}

class _ChildListScreenState extends State<ChildListScreen> {
  final String baseUrl = 'https://heightprediction-hloiyts3ha-et.a.run.app';
  final Dio _dio = Dio();
  List<Map<String, dynamic>> childList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchChildList();
  }

  void _navigateToChildDetail(int childId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildDetailScreen(childId: childId),
      ),
    );
  }

  Future<void> _fetchChildList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _dio.get('$baseUrl/api/v1/child',
          options: Options(headers: {'Authorization': token}));

      if (response.statusCode == 200) {
        setState(() {
          childList = List<Map<String, dynamic>>.from(response.data);
        });
      } else {
        // Handle failure
        print(
            'Failed to fetch child list. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during child list fetch: $e');
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
        title: const Text('Child List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : childList.isEmpty
                ? const Center(child: Text('No children registered.'))
                : ListView.builder(
                    itemCount: childList.length,
                    itemBuilder: (context, index) {
                      final child = childList[index];
                      final birthDate = child['birth_date'].toString().substring(0, 16);

                      return Card(
                        // Make each ListTile clickable
                        child: InkWell(
                          onTap: () {
                            // Navigate to the ChildDetailScreen on card click
                            _navigateToChildDetail(child['id']);
                          },
                          child: ListTile(
                            title: Text('Name: ${child['name']}'),
                            subtitle: Text('Birth Date: $birthDate'),
                            // Add more information as needed
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
