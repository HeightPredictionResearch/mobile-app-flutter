import 'package:flutter/material.dart';
import 'package:height_prediction/pages/auth/login_screen.dart';
import 'package:height_prediction/pages/child/child_list_screen.dart';
import 'package:height_prediction/pages/child/child_registration_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName; // Added to store the user's name

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      // Decode the token to get user information
      Map<String, dynamic> decodedToken = json.decode(
        utf8.decode(base64.decode(token.split('.')[1])),
      );

      // Extract the user's name
      String? name = decodedToken['user_name'];

      // Update the state to trigger a rebuild
      setState(() {
        userName = name;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              SharedPreferences.getInstance().then((prefs) {
                prefs.remove('token');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              });
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display welcome message if the user's name is available
              if (userName != null)
                Text(
                  'Welcome $userName!',
                  style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              const SizedBox(height: 20.0),

              // Display image above the form
              Image.asset(
                'assets/image1.png',
                height: 250.0, // Adjust the height as needed
              ),
              const SizedBox(height: 20.0),

              // Menu item 1 - Register Child
              ElevatedButton(
                onPressed: _navigateToChildRegistration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.all(20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.child_care, size: 40.0),
                    SizedBox(height: 10.0),
                    Text(
                      'Pendaftaran Anak',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20.0),

              // Menu item 2 - List Child
              ElevatedButton(
                onPressed: _navigateToChildList,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.all(20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.list, size: 40.0),
                    SizedBox(height: 10.0),
                    Text(
                      'Daftar Anak Anda',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
