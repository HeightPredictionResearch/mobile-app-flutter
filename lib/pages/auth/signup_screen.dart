import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:height_prediction/pages/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:height_prediction/pages/home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final String baseUrl = 'https://heightprediction-hloiyts3ha-et.a.run.app';
  final Dio _dio = Dio();
  
  bool isLoading = false;
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
      } else {
        // Show error message for registration failure
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registration Failed'),
            content: const Text('Failed to register. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error during registration: $e');
      // Handle other registration errors if necessary
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
        title: const Text('Register'),
      ),
      body: isLoading
        ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                  SpinKitCircle(color: Colors.blue, size: 50.0),
                  Text('Loading'),
                ] // Display loading spinner
              )
        : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
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
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
