import 'package:findar/features/create_listing/create_listing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import './features/home/home.dart';
import './features/search/screens/filtering.dart';
import 'core/theme/app_theme.dart';
import './features/landing/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/profile_picture_setup_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/reset_password_screen.dart';
import './features/listings/screens/my_listings_screen.dart';
import './features/listings/screens/edit_listing/edit_listing_screen.dart';
import './features/saved/screens/saved_listings_screen.dart';
import './features/search/screens/search_results.dart';
import './features/demoscreen.dart';
import './features/settings/settings_screen.dart';
import 'core/theme/theme_provider.dart';
import './features/profile/screens/profile_screen/profile_screen.dart';
import './features/profile/screens/edit_profile/edit_profile_screen.dart';
import './features/profile/screens/user_profile_screen/user_profile_screen.dart';
import './features/property_details/screens/property_details_screen.dart';
// import './features/demo/demo_test_screen.dart';
// Import all cubits
import 'logic/cubits/auth_cubit.dart';
import 'package:findar/logic/cubits/home/recent_listings.dart';
import 'package:findar/logic/cubits/home/sponsored_listings.dart';
import 'logic/cubits/create_listing_cubit.dart';
import 'logic/cubits/listings_cubit.dart';
// import 'logic/cubits/listing_cubit.dart'; // Disabled - has incompatible methods
import 'logic/cubits/search_cubit.dart';
import 'logic/cubits/saved_listings_cubit.dart';
import 'logic/cubits/property_details_cubit.dart';
import 'logic/cubits/my_listings_cubit.dart';
import 'logic/cubits/profile_cubit.dart';
import 'logic/cubits/profile_picture_setup_cubit.dart';
import 'logic/cubits/settings_cubit.dart';
import 'logic/cubits/boost_cubit.dart';
import 'logic/cubits/sort_cubit.dart';
import 'core/models/property_listing_model.dart';
import 'logic/cubits/language_cubit.dart';
import 'core/models/sponsorship_plan.dart';
import 'features/listings/screens/sponsorship_plans/sponsorship_plans_screen.dart';
import 'features/listings/screens/payment_confirmation/payment_confirmation_screen.dart';

//import repository
import 'core/repositories/dummy_listing_repo.dart';
import 'core/repositories/abstract_listing_repo.dart';
import 'core/repositories/database_listing_repo.dart';

late ListingRepository repo;
void main() {
  //later: repo = (online)? RemoteListingRepository(): LocalListingRepository();
  repo =
      LocalListingRepository(); //we will replace this with real repository later

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LanguageCubit()),
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => CreateListingCubit(repo)),
        BlocProvider(create: (_) => ListingsCubit(repo)),
        // BlocProvider(create: (_) => ListingCubit(repo)), // Disabled - has incompatible methods
        BlocProvider(create: (_) => SearchCubit(repo)),
        BlocProvider(create: (_) => SavedListingsCubit(repo)),
        BlocProvider(create: (_) => PropertyDetailsCubit(repo)),
        BlocProvider(create: (_) => MyListingsCubit(repo)),
        BlocProvider(create: (_) => ProfileCubit()),
        BlocProvider(create: (_) => ProfilePictureSetupCubit()),
        BlocProvider(create: (_) => SettingsCubit()),
        BlocProvider(create: (_) => SortCubit()),
        BlocProvider(create: (_) => BoostCubit()),
        BlocProvider(create: (_) => RecentCubit(repo)),
        BlocProvider(create: (_) => SponsoredCubit(repo)),
      ],
      child: ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return BlocBuilder<LanguageCubit, String>(
              builder: (context, language) {
                return MaterialApp(
                  theme: lightTheme,
                  // theme: darkTheme,
                  darkTheme: darkTheme,
                  themeMode: themeProvider.themeMode,
                  debugShowCheckedModeBanner: false,
                  locale: Locale(language),
                  localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [
                Locale('en'),
                Locale('ar'),
                Locale('fr'),
              ],
              initialRoute: '/demoscreen',
              onGenerateRoute: (settings) {
                // Handle edit listing route with arguments
                if (settings.name == '/edit-listing') {
                  final listing = settings.arguments;
                  return MaterialPageRoute(
                    builder: (context) =>
                        EditListingScreen(listing: listing as PropertyListing),
                  );
                }
                // Handle sponsorship plans route with arguments
                if (settings.name == '/sponsorship-plans') {
                  final listing = settings.arguments as PropertyListing;
                  return MaterialPageRoute(
                    builder: (context) =>
                        SponsorshipPlansScreen(listing: listing),
                  );
                }
                // Handle payment confirmation route with arguments
                if (settings.name == '/payment-confirmation') {
                  final args = settings.arguments as Map<String, dynamic>;
                  return MaterialPageRoute(
                    builder: (context) => PaymentConfirmationScreen(
                      listing: args['listing'] as PropertyListing,
                      plan: args['plan'] as SponsorshipPlan,
                    ),
                  );
                }
                // Handle user profile route with userId argument
                if (settings.name == '/user-profile') {
                  final userId = settings.arguments as String;
                  return MaterialPageRoute(
                    builder: (context) => UserProfileScreen(userId: userId),
                  );
                }
                // Default routes
                final routes = {
                  '/landing': (context) => const SplashScreen(),
                  '/login': (context) => const LoginScreen(),
                  '/register': (context) => RegisterScreen(),
                  '/profile-picture-setup': (context) => const ProfilePictureSetupScreen(),
                  '/forgot-password': (context) => const ForgotPasswordScreen(),
                  '/reset-password': (context) => const ResetPasswordScreen(),
                  '/home': (context) => const HomeScreen(),
                  '/filtering': (context) => const FilteringScreen(),
                  '/my-listings': (context) => const MyListingsScreen(),
                  '/saved-listings': (context) => const SavedListingsScreen(),
                  '/search-results': (context) => const SearchResultsScreen(),
                  '/demoscreen': (context) => const Demoscreen(),
                  // '/demo-test': (context) => const DemoTestScreen(),
                  '/settings': (context) => const SettingsScreen(),
                  '/property-details': (context) =>
                      const PropertyDetailsScreen(),
                  '/create-listing': (context) => const CreateListingScreen(),
                  '/profile': (context) => const ProfileScreen(),
                  '/edit-profile': (context) => const EditProfileScreen(),
                };

                final builder = routes[settings.name];
                if (builder != null) {
                  return MaterialPageRoute(builder: builder);
                }

                return MaterialPageRoute(
                  builder: (context) => const SplashScreen(),
                );
              },
            );
              },
            );
          },
        ),
      ),
    );
  }
}
