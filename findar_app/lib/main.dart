import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './features/home/home.dart';
import './features/search/screens/filtering.dart';
import 'core/theme/app_theme.dart';
import './features/landing/screens/splash_screen.dart';
import './features/auth/screens/login_screen.dart';
import './features/auth/screens/register_screen.dart';
import './features/listings/screens/my_listings_screen.dart';
import './features/saved/screens/saved_listings_screen.dart';
import './features/search/screens/search_results.dart';
import './features/demoscreen.dart';
import './features/settings/settings_screen.dart';
import 'core/theme/theme_provider.dart';
import './features/property_details/screens/property_details_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            initialRoute: '/demoscreen',
            routes: {
              '/landing': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) =>  RegisterScreen(),
              '/home': (context) => const HomeScreen(),
              '/filtering': (context) => const FilteringScreen(),
              '/my-listings': (context) => const MyListingsScreen(),
              '/saved-listings': (context) => const SavedListingsScreen(), 
              '/search-results': (context) => const SearchResultsScreen(),
              '/demoscreen': (context) => const Demoscreen(),
              '/settings': (context) => const SettingsScreen(),
              '/property-details': (context) => const PropertyDetailsScreen(),
            },
          );
        },
      ),
    );
  }
}