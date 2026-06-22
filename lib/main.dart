import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const DogReIDApp());
}

class DogReIDApp extends StatelessWidget {
  const DogReIDApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetNavID',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
