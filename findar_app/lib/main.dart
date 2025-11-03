import 'package:flutter/material.dart';
import './features/home/home.dart';
import './features/search/screens/filtering.dart';
import 'core/theme/app_theme.dart';
import './features/landing/screens/splash_screen.dart';
import './features/auth/screens/login_screen.dart';
import './features/auth/screens/register_screen.dart';
import './features/property_details/screens/property_details_screen.dart';

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
      initialRoute: '/landing',
      routes: {
        '/landing': (context) =>  SplashScreen(),
        '/login': (context) =>  LoginScreen(),
        '/register': (context) =>  RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/filtering': (context) => FilteringScreen(),
        '/property_details': (context) => PropertyDetailsScreen(),
      },
    );
  }
}
