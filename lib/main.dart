import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const GeneticsApp());
}

class GeneticsApp extends StatelessWidget {
  const GeneticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Генетика для начинающих',
      debugShowCheckedModeBanner: false, // убирает надпись "DEBUG" в углу
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const HomeScreen(),
    );
  }
}