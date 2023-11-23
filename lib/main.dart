import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:height_prediction/pages/auth/login_screen.dart';
import 'package:height_prediction/pages/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  runApp(MaterialApp(
    title: 'Camera & Gallery Example',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: token != null ? const HomeScreen() : const LoginScreen(),
  ));
}

