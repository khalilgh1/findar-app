// LOCALIZATION USAGE GUIDE FOR FINDAR APP
//
// The app now supports three languages: English (en), Arabic (ar), and French (fr)
// 
// HOW TO USE LOCALIZED STRINGS IN YOUR WIDGETS:
// 
// 1. Import AppLocalizations in your screen:
//    import 'package:findar/l10n/app_localizations.dart';
//
// 2. Get the localization object and use it:
//    final l10n = AppLocalizations.of(context)!;
//    
//    Text(l10n.welcomeBack)          // "Welcome Back!"
//    Text(l10n.login)                // "Login"
//    Text(l10n.enterEmail)           // "Enter your Email Address"
//
// EXAMPLE IMPLEMENTATION:
//
// ```dart
// import 'package:flutter/material.dart';
// import 'package:findar/l10n/app_localizations.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _obscurePassword = true;
//
//   @override
//   Widget build(BuildContext context) {
//     final l10n = AppLocalizations.of(context)!;
//     
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 180),
//               Text(
//                 'FinDAR',
//                 style: TextStyle(
//                   color: Colors.blue,
//                   fontSize: 60,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 l10n.welcomeBack,  // Uses localized string
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 25,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 40),
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   l10n.emailAddress,  // Uses localized string
//                   style: TextStyle(
//                     color: Colors.grey[800],
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 6),
//               TextField(
//                 controller: _emailController,
//                 decoration: InputDecoration(
//                   hintText: l10n.enterEmail,  // Uses localized string
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   l10n.password,  // Uses localized string
//                   style: TextStyle(
//                     color: Colors.grey[800],
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 6),
//               TextField(
//                 controller: _passwordController,
//                 obscureText: _obscurePassword,
//                 decoration: InputDecoration(
//                   hintText: l10n.enterPassword,  // Uses localized string
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                       _obscurePassword ? Icons.visibility_off : Icons.visibility,
//                       color: Colors.grey,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _obscurePassword = !_obscurePassword;
//                       });
//                     },
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/home');
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: Text(
//                     l10n.login,  // Uses localized string
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     l10n.dontHaveAccount,  // Uses localized string
//                     style: TextStyle(color: Colors.black87, fontSize: 14),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pushNamed(context, '/register');
//                     },
//                     child: Text(
//                       l10n.register,  // Uses localized string
//                       style: TextStyle(
//                         color: Colors.blue,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
// }
// ```
//
// CHANGING LANGUAGE AT RUNTIME:
//
// You can change the app language by using a language cubit/provider.
// Example implementation in settings:
//
// ```dart
// // In settings_screen.dart
// class LanguageTile extends StatelessWidget {
//   const LanguageTile({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final l10n = AppLocalizations.of(context)!;
//     
//     return ListTile(
//       title: Text(l10n.language),
//       subtitle: Text(l10n.english), // Show current language
//       onTap: () => _showLanguageDialog(context),
//     );
//   }
//
//   void _showLanguageDialog(BuildContext context) {
//     final l10n = AppLocalizations.of(context)!;
//     
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(l10n.language),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _languageOption(context, 'en', l10n.english),
//             _languageOption(context, 'ar', l10n.arabic),
//             _languageOption(context, 'fr', l10n.french),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _languageOption(BuildContext context, String code, String name) {
//     return ListTile(
//       title: Text(name),
//       onTap: () {
//         // Update language - requires language cubit implementation
//         Navigator.pop(context);
//       },
//     );
//   }
// }
// ```
//
// AVAILABLE STRINGS BY CATEGORY:
//
// AUTH STRINGS: welcomeBack, completeRegistration, selectAccountType, accountIndividual,
//               accountAgency, fullName, enterFullName, emailAddress, enterEmail,
//               phoneNumber, enterPhone, password, enterPassword, ninLabel, enterNin,
//               registerNow, alreadyHaveAccount, login, dontHaveAccount, register
//
// LANDING STRINGS: welcome, yourPropertyMarketplace, buy, sell, rent, getStarted
//
// HOME STRINGS: sponsoredProperties, recentListings, viewAll, exploreProperties
//
// PROPERTY TYPE STRINGS: forSale, forRent, commercial, newConstructions, house, apartment,
//                        condo, townhouse, villa, studio, any
//
// PROPERTY DETAILS STRINGS: propertyDetails, bedrooms, bathrooms, squareFootage, sqft,
//                          description, features, location, agentInfo, similarProperties,
//                          contactAgent, scheduleTour, share, save
//
// SEARCH & FILTER STRINGS: searchResults, sort, filter, filters, noPropertiesFound,
//                         pleaseTryAdjustingFilters, sortBy, priceLowToHigh, priceHighToLow,
//                         newest, mostPopular, advancedSearch, enterLocationHint, priceRange,
//                         propertyType, buildingType, bedsAndBaths, minLabel, maxLabel,
//                         listedBy, privateOwner, realEstateAgent, reset, showResults,
//                         showingResults
//
// CREATE LISTING STRINGS: createListing, editListing, propertyTitle, examplePropertyTitleHint,
//                        price, examplePriceHint, exampleLocationHint, propertyDescriptionHint,
//                        classification, propertyStatus, online, offline, floors, rooms,
//                        addImages, publishListing, listingCreatedSuccessfully
//
// SAVED STRINGS: removedFromSaved, savedListings, noSavedListings, startExploring
//
// MY LISTINGS STRINGS: myListings, removeListingTitle, removeListingConfirm, listingRemoved,
//                      edit, delete
//
// PROFILE STRINGS: profile, listings, addNew, viewListing, editProfile, accountSettings,
//                  logout, profilePictureUpdated, upload, skip
//
// SETTINGS STRINGS: settings, appearance, language, english, arabic, french, contactUs,
//                   contactPhone, twitter, facebook, instagram, darkMode, notifications,
//                   privacy, termsOfService, about, version
//
// COMMON STRINGS: email, cancel, confirm, saveChanges, apply, close, next, previous,
//                done, yes, no, ok, error, success, loading, retry, seeMore, seeLess
//
// ERROR STRINGS: errorOccurred, networkError, invalidEmail, invalidPassword, fieldRequired
