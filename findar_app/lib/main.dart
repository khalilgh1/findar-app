import 'package:flutter/material.dart';
import './features/home/home.dart';
import './features/search/screens/filtering.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomeScreen(),
        '/filtering': (context) => FilteringScreen(),
      },
    );
  }
}
