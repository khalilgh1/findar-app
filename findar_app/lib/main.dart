import 'package:findar/features/create_listing/create_listing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import './features/profile/profile.dart';
import './features/property_details/screens/property_details_screen.dart';
import './features/demo/demo_test_screen.dart';
// Import all cubits
import 'logic/cubits/auth_cubit.dart';
import 'logic/cubits/create_listing_cubit.dart';
import 'logic/cubits/listings_cubit.dart';
import 'logic/cubits/search_cubit.dart';
import 'logic/cubits/saved_listings_cubit.dart';
import 'logic/cubits/property_details_cubit.dart';
import 'logic/cubits/my_listings_cubit.dart';
import 'logic/cubits/profile_cubit.dart';
import 'logic/cubits/settings_cubit.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => CreateListingCubit()),
        BlocProvider(create: (_) => ListingsCubit()),
        BlocProvider(create: (_) => SearchCubit()),
        BlocProvider(create: (_) => SavedListingsCubit()),
        BlocProvider(create: (_) => PropertyDetailsCubit()),
        BlocProvider(create: (_) => MyListingsCubit()),
        BlocProvider(create: (_) => ProfileCubit()),
        BlocProvider(create: (_) => SettingsCubit()),
      ],
      child: ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp(
              theme: lightTheme,
              // theme: darkTheme,
              darkTheme: darkTheme,
              themeMode: themeProvider.themeMode,
              debugShowCheckedModeBanner: false,
              initialRoute: '/demoscreen',
              routes: {
                '/landing': (context) => const SplashScreen(),
                '/login': (context) => const LoginScreen(),
                '/register': (context) => RegisterScreen(),
                '/home': (context) => const HomeScreen(),
                '/filtering': (context) => const FilteringScreen(),
                '/my-listings': (context) => const MyListingsScreen(),
                '/saved-listings': (context) => const SavedListingsScreen(),
                '/search-results': (context) => const SearchResultsScreen(),
                '/demoscreen': (context) => const Demoscreen(),
                '/demo-test': (context) => const DemoTestScreen(),
                '/settings': (context) => const SettingsScreen(),
                '/property-details': (context) => const PropertyDetailsScreen(),
                '/create-listing': (context) => const CreateListingScreen(),
                '/profile': (context) => const ProfileScreen(),
              },
            );
          },
        ),
      ),
    );
  }
}
