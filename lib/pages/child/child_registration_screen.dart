// child_registration_screen.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ChildRegistrationScreen extends StatefulWidget {
  const ChildRegistrationScreen({Key? key}) : super(key: key);

  @override
  _ChildRegistrationScreenState createState() =>
      _ChildRegistrationScreenState();
}

class _ChildRegistrationScreenState extends State<ChildRegistrationScreen> {
  final String baseUrl = 'https://heightprediction-hloiyts3ha-et.a.run.app';
  final Dio _dio = Dio();
  final TextEditingController nameController = TextEditingController();
  DateTime? selectedDate;
  bool isLoading = false;

  Future<void> _registerChild() async {
    setState(() {
      isLoading = true;
    });

    final String name = nameController.text;
    final String? birthDate = selectedDate?.toIso8601String().substring(0, 10);

    try {
      final response = await _dio.post(
        '$baseUrl/api/v1/child',
        data: {'name': name, 'birth_date': birthDate},
      );

      if (response.statusCode == 200) {
        // Handle successful registration, e.g., show a success message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Child Registration Successful'),
            content: const Text(
                'Child information has been registered successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Handle registration failure
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Child Registration Failed'),
            content: const Text('Failed to register child. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error during child registration: $e');
      // Handle other registration errors if necessary
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Child'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Child Name'),
            ),
            const SizedBox(height: 16),
            // TextFormField for date picker
            TextFormField(
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: const InputDecoration(
                labelText: 'Birth Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              validator: (value) {
                if (selectedDate == null) {
                  return 'Please select a date';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _registerChild,
              child: Text(isLoading ? 'Registering...' : 'Register Child'),
            ),
            if (isLoading)
              const SizedBox(height: 16, child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
