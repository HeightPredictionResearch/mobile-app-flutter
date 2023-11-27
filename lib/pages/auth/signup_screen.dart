import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:height_prediction/pages/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:height_prediction/pages/home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final String baseUrl = 'https://heightprediction-hloiyts3ha-et.a.run.app';
  final Dio _dio = Dio();

  bool isLoading = false;
  bool obscureText = true; 
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _register() async {
    setState(() {
      isLoading = true;
    });

    final String name = nameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;

    try {
      final response = await _dio.post(
        '$baseUrl/api/v1/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        // Store the token in SharedPreferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', response.data);

        // Navigate to HomeScreen on successful registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (e is DioError && e.response != null) {
        // DioError with a response
        print(
            'Failed registration response: ${e.response!.statusCode} - ${e.response!.data}');
        _showErrorDialog('Invalid email or password. Please try again.');
      } else {
        // DioError without a response
        print('Error during registration: $e');
        _showErrorDialog('System Error');
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Helper method to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register Failed'),
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
        title: const Text('Register'),
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SpinKitCircle(color: Colors.blue, size: 50.0),
                  Text('Loading'),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Aplikasi Pengukuran Tinggi Badan Anak',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20.0),

                    // Display image above the form
                    Image.asset(
                      'assets/image1.png',
                      height: 250.0,
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                        ),
                      ),
                      obscureText: obscureText,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _register,
                      child: const Text('Register'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        // Navigate to the LoginScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text('Already have an account? Login'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
