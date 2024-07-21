import 'package:flutter/material.dart';
import 'screens/start_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: StartScreen(),
    );
  }
}
