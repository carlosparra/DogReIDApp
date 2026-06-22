import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const DogReIDApp());
}

class DogReIDApp extends StatelessWidget {
  const DogReIDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DogReID',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3A6EA5)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
