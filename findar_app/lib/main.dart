import 'package:flutter/material.dart';
import './features/home/home.dart';
import './features/search/screens/filtering.dart';
import 'core/theme/app_theme.dart';
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {

  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomeScreen(),
        '/filtering': (context) => FilteringScreen(),
      },
    );
  }
}
