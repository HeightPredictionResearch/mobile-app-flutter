import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final TextEditingController dateController = TextEditingController();

  String selectedDate = "";
  bool isLoading = false;
  String? nameErrorText;
  String? dateErrorText;

  Future<void> _registerChild() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    setState(() {
      isLoading = true;
    });

    final String name = nameController.text;
    final String birthDate = selectedDate;

    // Validate fields
    String? nameError = _validateNotEmpty(name, 'Nama Anak');
    String? dateError = _validateNotEmpty(selectedDate, 'Tanggal Lahir');

    if (nameError != null || dateError != null) {
      // Display validation errors below the respective fields
      setState(() {
        nameErrorText = nameError;
        dateErrorText = dateError;
        isLoading = false;
      });
      return;
    }

    try {
      final response = await _dio.post('$baseUrl/api/v1/child',
          data: {'name': name, 'birth_date': birthDate},
          options: Options(headers: {'Authorization': token}));
      if (response.statusCode == 200) {
        _showSuccessDialog('Sistem berhasil mendaftarkan anak Anda!');
      }
    } catch (e) {
      // Handle registration failure
      print('Error during child registration: $e');
      _showErrorDialog('Gagal mendaftarkan anak Anda');
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
        selectedDate =
            "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
        dateController.text = selectedDate;
      });
    }
  }

  // Validation function to check if a field is not empty
  String? _validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName cannot be empty';
    }

    return null;
  }

  // Helper method to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register Child Failed'),
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

  // Helper method to show success dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register Child Success'),
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
        title: const Text('Register Child'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Masukkan Data Anak Anda',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
              Image.asset(
                'assets/image2.png',
                height: 200.0,
              ),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Anak',
                  border: OutlineInputBorder(),
                ),
              ),
              if (nameErrorText != null)
                Text(
                  nameErrorText!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              // TextFormField for date picker
              TextFormField(
                readOnly: true,
                controller: dateController,
                onTap: () => _selectDate(context),
                decoration: const InputDecoration(
                  labelText: 'Tanggal Lahir',
                  suffixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (selectedDate == null) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              if (dateErrorText != null)
                Text(
                  dateErrorText!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _registerChild,
                child: Text(isLoading ? 'Mendaftarkan...' : 'Daftarkan'),
              ),
              if (isLoading)
                const SizedBox(height: 16, child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
