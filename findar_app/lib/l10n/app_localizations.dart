import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Findar'**
  String get appTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @completeRegistration.
  ///
  /// In en, this message translates to:
  /// **'Complete registration'**
  String get completeRegistration;

  /// No description provided for @selectAccountType.
  ///
  /// In en, this message translates to:
  /// **'Select Account Type'**
  String get selectAccountType;

  /// No description provided for @accountIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get accountIndividual;

  /// No description provided for @accountAgency.
  ///
  /// In en, this message translates to:
  /// **'Agency'**
  String get accountAgency;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your Email Address'**
  String get enterEmail;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhone;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @ninLabel.
  ///
  /// In en, this message translates to:
  /// **'National Identification Number (NIN)'**
  String get ninLabel;

  /// No description provided for @enterNin.
  ///
  /// In en, this message translates to:
  /// **'Enter your NIN'**
  String get enterNin;

  /// No description provided for @registerNow.
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get registerNow;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @yourPropertyMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Your property marketplace'**
  String get yourPropertyMarketplace;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sell;

  /// No description provided for @rent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get rent;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @sponsoredProperties.
  ///
  /// In en, this message translates to:
  /// **'Sponsored Properties'**
  String get sponsoredProperties;

  /// No description provided for @recentListings.
  ///
  /// In en, this message translates to:
  /// **'Recent listings'**
  String get recentListings;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @exploreProperties.
  ///
  /// In en, this message translates to:
  /// **'Explore Properties'**
  String get exploreProperties;

  /// No description provided for @forSale.
  ///
  /// In en, this message translates to:
  /// **'For sale'**
  String get forSale;

  /// No description provided for @forRent.
  ///
  /// In en, this message translates to:
  /// **'For rent'**
  String get forRent;

  /// No description provided for @newConstructions.
  ///
  /// In en, this message translates to:
  /// **'New Constructions'**
  String get newConstructions;

  /// No description provided for @house.
  ///
  /// In en, this message translates to:
  /// **'House'**
  String get house;

  /// No description provided for @apartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get apartment;

  /// No description provided for @villa.
  ///
  /// In en, this message translates to:
  /// **'Villa'**
  String get villa;

  /// No description provided for @studio.
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get studio;

  /// No description provided for @office.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get office;

  /// No description provided for @any.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get any;

  /// No description provided for @propertyDetails.
  ///
  /// In en, this message translates to:
  /// **'Property Details'**
  String get propertyDetails;

  /// No description provided for @bedrooms.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get bedrooms;

  /// No description provided for @bathrooms.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get bathrooms;

  /// No description provided for @squareFootage.
  ///
  /// In en, this message translates to:
  /// **'Square Footage'**
  String get squareFootage;

  /// No description provided for @sqft.
  ///
  /// In en, this message translates to:
  /// **'sqft'**
  String get sqft;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @agentInfo.
  ///
  /// In en, this message translates to:
  /// **'Agent Information'**
  String get agentInfo;

  /// No description provided for @similarProperties.
  ///
  /// In en, this message translates to:
  /// **'Similar Properties'**
  String get similarProperties;

  /// No description provided for @contactAgent.
  ///
  /// In en, this message translates to:
  /// **'Contact Agent'**
  String get contactAgent;

  /// No description provided for @scheduleTour.
  ///
  /// In en, this message translates to:
  /// **'Schedule Tour'**
  String get scheduleTour;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @noPropertiesFound.
  ///
  /// In en, this message translates to:
  /// **'No properties found'**
  String get noPropertiesFound;

  /// No description provided for @pleaseTryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try a different place or fewer filters.'**
  String get pleaseTryAdjustingFilters;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @priceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get priceLowToHigh;

  /// No description provided for @priceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Price: high to low'**
  String get priceHighToLow;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostPopular;

  /// No description provided for @advancedSearch.
  ///
  /// In en, this message translates to:
  /// **'Advanced search'**
  String get advancedSearch;

  /// No description provided for @enterLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a city, zip code, or neighborhood'**
  String get enterLocationHint;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get priceRange;

  /// No description provided for @propertyType.
  ///
  /// In en, this message translates to:
  /// **'Property type'**
  String get propertyType;

  /// No description provided for @buildingType.
  ///
  /// In en, this message translates to:
  /// **'Building Type'**
  String get buildingType;

  /// No description provided for @bedsAndBaths.
  ///
  /// In en, this message translates to:
  /// **'Beds & Baths'**
  String get bedsAndBaths;

  /// No description provided for @minLabel.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get minLabel;

  /// No description provided for @maxLabel.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get maxLabel;

  /// No description provided for @listedBy.
  ///
  /// In en, this message translates to:
  /// **'Listed by'**
  String get listedBy;

  /// No description provided for @privateOwner.
  ///
  /// In en, this message translates to:
  /// **'Private Owner'**
  String get privateOwner;

  /// No description provided for @realEstateAgent.
  ///
  /// In en, this message translates to:
  /// **'Real Estate Agent'**
  String get realEstateAgent;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @showResults.
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get showResults;

  /// No description provided for @showingResults.
  ///
  /// In en, this message translates to:
  /// **'Showing {count} results'**
  String showingResults(int count);

  /// No description provided for @createListing.
  ///
  /// In en, this message translates to:
  /// **'Create Listing'**
  String get createListing;

  /// No description provided for @editListing.
  ///
  /// In en, this message translates to:
  /// **'Edit \"{title}\"'**
  String editListing(String title);

  /// No description provided for @propertyTitle.
  ///
  /// In en, this message translates to:
  /// **'Property Title'**
  String get propertyTitle;

  /// No description provided for @examplePropertyTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Villa with garden'**
  String get examplePropertyTitleHint;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @examplePriceHint.
  ///
  /// In en, this message translates to:
  /// **'250 000'**
  String get examplePriceHint;

  /// No description provided for @exampleLocationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 15 Rue Didouche Mourad, Algiers'**
  String get exampleLocationHint;

  /// No description provided for @propertyDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the property details here...'**
  String get propertyDescriptionHint;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verificationCode;

  /// No description provided for @getCode.
  ///
  /// In en, this message translates to:
  /// **'Get Code'**
  String get getCode;

  /// No description provided for @enterVerificationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get enterVerificationCodeHint;

  /// No description provided for @enterNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get enterNewPasswordHint;

  /// No description provided for @confirmNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPasswordHint;

  /// No description provided for @priceOnRequest.
  ///
  /// In en, this message translates to:
  /// **'Price on request'**
  String get priceOnRequest;

  /// No description provided for @boostedBadge.
  ///
  /// In en, this message translates to:
  /// **'Boosted'**
  String get boostedBadge;

  /// No description provided for @boostAction.
  ///
  /// In en, this message translates to:
  /// **'Boost'**
  String get boostAction;

  /// No description provided for @toggleStatus.
  ///
  /// In en, this message translates to:
  /// **'Toggle Status'**
  String get toggleStatus;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully!'**
  String get passwordResetSuccess;

  /// No description provided for @listingCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create listing'**
  String get listingCreateFailed;

  /// No description provided for @chooseImageSource.
  ///
  /// In en, this message translates to:
  /// **'Choose Image Source'**
  String get chooseImageSource;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String errorPickingImage(String error);

  /// No description provided for @classification.
  ///
  /// In en, this message translates to:
  /// **'Classification'**
  String get classification;

  /// No description provided for @propertyStatus.
  ///
  /// In en, this message translates to:
  /// **'Property Status'**
  String get propertyStatus;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @floors.
  ///
  /// In en, this message translates to:
  /// **'Floors'**
  String get floors;

  /// No description provided for @rooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get rooms;

  /// No description provided for @addImages.
  ///
  /// In en, this message translates to:
  /// **'Add Images'**
  String get addImages;

  /// No description provided for @publishListing.
  ///
  /// In en, this message translates to:
  /// **'Publish listing'**
  String get publishListing;

  /// No description provided for @listingCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Listing Created Successfully!'**
  String get listingCreatedSuccessfully;

  /// No description provided for @removedFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Removed from saved'**
  String get removedFromSaved;

  /// No description provided for @savedListings.
  ///
  /// In en, this message translates to:
  /// **'Saved Listings'**
  String get savedListings;

  /// No description provided for @noSavedListings.
  ///
  /// In en, this message translates to:
  /// **'No saved listings yet'**
  String get noSavedListings;

  /// No description provided for @startExploring.
  ///
  /// In en, this message translates to:
  /// **'Start exploring properties to save your favorites'**
  String get startExploring;

  /// No description provided for @myListings.
  ///
  /// In en, this message translates to:
  /// **'My listings'**
  String get myListings;

  /// No description provided for @removeListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Listing'**
  String get removeListingTitle;

  /// No description provided for @removeListingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove \"{title}\"?'**
  String removeListingConfirm(String title);

  /// No description provided for @listingRemoved.
  ///
  /// In en, this message translates to:
  /// **'Listing deleted'**
  String get listingRemoved;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @listings.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get listings;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// No description provided for @viewListing.
  ///
  /// In en, this message translates to:
  /// **'View listing'**
  String get viewListing;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @profilePictureUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated'**
  String get profilePictureUpdated;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'+1 (234) 567-890'**
  String get contactPhone;

  /// No description provided for @twitter.
  ///
  /// In en, this message translates to:
  /// **'Twitter'**
  String get twitter;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @instagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get instagram;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// No description provided for @seeLess.
  ///
  /// In en, this message translates to:
  /// **'See Less'**
  String get seeLess;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection'**
  String get networkError;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get invalidPassword;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 4 characters'**
  String get nameTooShort;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordMissingUppercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase letter'**
  String get passwordMissingUppercase;

  /// No description provided for @passwordMissingLowercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one lowercase letter'**
  String get passwordMissingLowercase;

  /// No description provided for @passwordMissingNumber.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one number'**
  String get passwordMissingNumber;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @phoneTooShort.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be at least 10 digits'**
  String get phoneTooShort;

  /// No description provided for @accountTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select account type'**
  String get accountTypeRequired;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @createNewListing.
  ///
  /// In en, this message translates to:
  /// **'Create New Listing'**
  String get createNewListing;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get addPhotos;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @noSavedProperties.
  ///
  /// In en, this message translates to:
  /// **'No saved properties'**
  String get noSavedProperties;

  /// No description provided for @savePropertiesToViewHere.
  ///
  /// In en, this message translates to:
  /// **'Save properties to view them here'**
  String get savePropertiesToViewHere;

  /// No description provided for @noListingsMessage.
  ///
  /// In en, this message translates to:
  /// **'No {tab} listings'**
  String noListingsMessage(String tab);

  /// No description provided for @addFirstPropertyListing.
  ///
  /// In en, this message translates to:
  /// **'Post your first property in a minute.'**
  String get addFirstPropertyListing;

  /// No description provided for @chooseSponsorshipPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose Sponsorship Plan'**
  String get chooseSponsorshipPlan;

  /// No description provided for @selectPlanToBoostProperty.
  ///
  /// In en, this message translates to:
  /// **'Select a plan to boost your property'**
  String get selectPlanToBoostProperty;

  /// No description provided for @continueToPayment.
  ///
  /// In en, this message translates to:
  /// **'Continue to payment'**
  String get continueToPayment;

  /// No description provided for @paymentConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Payment Confirmation'**
  String get paymentConfirmation;

  /// No description provided for @propertyBoostedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Property boosted successfully!'**
  String get propertyBoostedSuccessfully;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a city, zip code, or neighborhood'**
  String get locationHint;

  /// No description provided for @bedroomsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Bedrooms'**
  String bedroomsCount(int count);

  /// No description provided for @bathroomsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Bathrooms'**
  String bathroomsCount(int count);

  /// No description provided for @basicSponsor.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get basicSponsor;

  /// No description provided for @premiumSponsor.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumSponsor;

  /// No description provided for @agencySponsorPlan.
  ///
  /// In en, this message translates to:
  /// **'Agency'**
  String get agencySponsorPlan;

  /// No description provided for @featuredPlacement.
  ///
  /// In en, this message translates to:
  /// **'Featured placement'**
  String get featuredPlacement;

  /// No description provided for @priorityInSearch.
  ///
  /// In en, this message translates to:
  /// **'Priority in search results'**
  String get priorityInSearch;

  /// No description provided for @basicAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Basic analytics'**
  String get basicAnalytics;

  /// No description provided for @topPriority.
  ///
  /// In en, this message translates to:
  /// **'Top priority in search'**
  String get topPriority;

  /// No description provided for @advancedAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Advanced analytics'**
  String get advancedAnalytics;

  /// No description provided for @premiumAnalyticsDashboard.
  ///
  /// In en, this message translates to:
  /// **'Premium analytics dashboard'**
  String get premiumAnalyticsDashboard;

  /// No description provided for @dedicatedSupport.
  ///
  /// In en, this message translates to:
  /// **'Dedicated support'**
  String get dedicatedSupport;

  /// No description provided for @featuredBadge.
  ///
  /// In en, this message translates to:
  /// **'Featured badge'**
  String get featuredBadge;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @cardNumberHint.
  ///
  /// In en, this message translates to:
  /// **'1234 5678 9012 3456'**
  String get cardNumberHint;

  /// No description provided for @cardholderName.
  ///
  /// In en, this message translates to:
  /// **'Cardholder Name'**
  String get cardholderName;

  /// No description provided for @cardholderNameHint.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get cardholderNameHint;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @expiryDateHint.
  ///
  /// In en, this message translates to:
  /// **'MM/YY'**
  String get expiryDateHint;

  /// No description provided for @cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @cvvHint.
  ///
  /// In en, this message translates to:
  /// **'123'**
  String get cvvHint;

  /// No description provided for @validateTitleEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a property title'**
  String get validateTitleEmpty;

  /// No description provided for @validateTitleMinLength.
  ///
  /// In en, this message translates to:
  /// **'Title must be at least 5 characters'**
  String get validateTitleMinLength;

  /// No description provided for @validateDescriptionEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get validateDescriptionEmpty;

  /// No description provided for @validateDescriptionMinLength.
  ///
  /// In en, this message translates to:
  /// **'Description must be at least 20 characters'**
  String get validateDescriptionMinLength;

  /// No description provided for @validatePriceEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a price'**
  String get validatePriceEmpty;

  /// No description provided for @validatePriceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get validatePriceInvalid;

  /// No description provided for @validatePricePositive.
  ///
  /// In en, this message translates to:
  /// **'Price must be greater than 0'**
  String get validatePricePositive;

  /// No description provided for @validateLocationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a location'**
  String get validateLocationEmpty;

  /// No description provided for @validateBedroomsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter number of bedrooms'**
  String get validateBedroomsEmpty;

  /// No description provided for @reportProperty.
  ///
  /// In en, this message translates to:
  /// **'Report Property'**
  String get reportProperty;

  /// No description provided for @selectReportReason.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason for reporting this property'**
  String get selectReportReason;

  /// No description provided for @inaccurateInformation.
  ///
  /// In en, this message translates to:
  /// **'Inaccurate information'**
  String get inaccurateInformation;

  /// No description provided for @fraudulentListing.
  ///
  /// In en, this message translates to:
  /// **'Fraudulent listing'**
  String get fraudulentListing;

  /// No description provided for @inappropriateContent.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get inappropriateContent;

  /// No description provided for @propertyNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'No longer available'**
  String get propertyNotAvailable;

  /// No description provided for @propertyReportedThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thanks, we\'ll review this listing.'**
  String get propertyReportedThankYou;

  /// No description provided for @helpMaintainQuality.
  ///
  /// In en, this message translates to:
  /// **'Help us maintain quality listings by reporting issues.'**
  String get helpMaintainQuality;

  /// No description provided for @quickSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Quick suggestions:'**
  String get quickSuggestions;

  /// No description provided for @describeIssue.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue:'**
  String get describeIssue;

  /// No description provided for @provideDetails.
  ///
  /// In en, this message translates to:
  /// **'Please provide details about the issue...'**
  String get provideDetails;

  /// No description provided for @sendReport.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get sendReport;

  /// No description provided for @pleaseSelectOrDescribe.
  ///
  /// In en, this message translates to:
  /// **'Pick a reason or describe the issue.'**
  String get pleaseSelectOrDescribe;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get sessionExpired;

  /// No description provided for @listingNotFound.
  ///
  /// In en, this message translates to:
  /// **'This listing is no longer available.'**
  String get listingNotFound;

  /// No description provided for @areaSqm.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get areaSqm;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get signInWithGoogle;

  /// No description provided for @actionNeedsInternet.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Connect to the internet and try again.'**
  String get actionNeedsInternet;

  /// No description provided for @currencyDa.
  ///
  /// In en, this message translates to:
  /// **'DA'**
  String get currencyDa;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get perMonth;

  /// No description provided for @bdShort.
  ///
  /// In en, this message translates to:
  /// **'{count} bd'**
  String bdShort(int count);

  /// No description provided for @baShort.
  ///
  /// In en, this message translates to:
  /// **'{count} ba'**
  String baShort(int count);

  /// No description provided for @noPhoto.
  ///
  /// In en, this message translates to:
  /// **'No photo'**
  String get noPhoto;

  /// No description provided for @removeFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get removeFromSaved;

  /// No description provided for @savedToList.
  ///
  /// In en, this message translates to:
  /// **'Saved to your list'**
  String get savedToList;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @orLabel.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orLabel;

  /// No description provided for @increase.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increase;

  /// No description provided for @decrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get decrease;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @youreOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get youreOffline;

  /// No description provided for @offlineBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Showing saved results from your last visit.'**
  String get offlineBannerBody;

  /// No description provided for @couldntLoadListings.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load listings'**
  String get couldntLoadListings;

  /// No description provided for @couldntLoadBody.
  ///
  /// In en, this message translates to:
  /// **'The server didn\'t respond. Try again in a moment.'**
  String get couldntLoadBody;

  /// No description provided for @listingUnavailableOffline.
  ///
  /// In en, this message translates to:
  /// **'This listing isn\'t available offline'**
  String get listingUnavailableOffline;

  /// No description provided for @listingUnavailableOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Only your own listings and saved properties open offline.'**
  String get listingUnavailableOfflineBody;

  /// No description provided for @browseListings.
  ///
  /// In en, this message translates to:
  /// **'Browse listings'**
  String get browseListings;

  /// No description provided for @postTab.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postTab;

  /// No description provided for @helloName.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String helloName(String name);

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'Find your next place'**
  String get heroTitle;

  /// No description provided for @searchCityHint.
  ///
  /// In en, this message translates to:
  /// **'Search city or district'**
  String get searchCityHint;

  /// No description provided for @listYourProperty.
  ///
  /// In en, this message translates to:
  /// **'List your property'**
  String get listYourProperty;

  /// No description provided for @listYourPropertySub.
  ///
  /// In en, this message translates to:
  /// **'Sell or rent it out on Findar'**
  String get listYourPropertySub;

  /// No description provided for @browseByType.
  ///
  /// In en, this message translates to:
  /// **'Browse by type'**
  String get browseByType;

  /// No description provided for @sponsored.
  ///
  /// In en, this message translates to:
  /// **'Sponsored'**
  String get sponsored;

  /// No description provided for @noRecentListings.
  ///
  /// In en, this message translates to:
  /// **'No listings yet'**
  String get noRecentListings;

  /// No description provided for @noRecentListingsBody.
  ///
  /// In en, this message translates to:
  /// **'New properties will show up here.'**
  String get noRecentListingsBody;

  /// No description provided for @tagHydra.
  ///
  /// In en, this message translates to:
  /// **'#Hydra'**
  String get tagHydra;

  /// No description provided for @tagForRent.
  ///
  /// In en, this message translates to:
  /// **'#ForRent'**
  String get tagForRent;

  /// No description provided for @tagVilla.
  ///
  /// In en, this message translates to:
  /// **'#Villa'**
  String get tagVilla;

  /// No description provided for @tagOran.
  ///
  /// In en, this message translates to:
  /// **'#Oran'**
  String get tagOran;

  /// No description provided for @tagF3.
  ///
  /// In en, this message translates to:
  /// **'#F3'**
  String get tagF3;

  /// No description provided for @anyLabel.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get anyLabel;

  /// No description provided for @pricePerMonth.
  ///
  /// In en, this message translates to:
  /// **'Price per month'**
  String get pricePerMonth;

  /// No description provided for @minimumArea.
  ///
  /// In en, this message translates to:
  /// **'Minimum area'**
  String get minimumArea;

  /// No description provided for @anyone.
  ///
  /// In en, this message translates to:
  /// **'Anyone'**
  String get anyone;

  /// No description provided for @ownerLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get ownerLabel;

  /// No description provided for @resultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No results} =1{1 result} other{{count} results}}'**
  String resultsCount(int count);

  /// No description provided for @filtersActive.
  ///
  /// In en, this message translates to:
  /// **'Filters, {count} active'**
  String filtersActive(int count);

  /// No description provided for @removeFilter.
  ///
  /// In en, this message translates to:
  /// **'Remove {label}'**
  String removeFilter(String label);

  /// No description provided for @nearest.
  ///
  /// In en, this message translates to:
  /// **'Nearest'**
  String get nearest;

  /// No description provided for @bedsMin.
  ///
  /// In en, this message translates to:
  /// **'{count}+ bd'**
  String bedsMin(int count);

  /// No description provided for @bathsMin.
  ///
  /// In en, this message translates to:
  /// **'{count}+ ba'**
  String bathsMin(int count);

  /// No description provided for @areaMin.
  ///
  /// In en, this message translates to:
  /// **'{count}+ m²'**
  String areaMin(int count);

  /// No description provided for @aboutProperty.
  ///
  /// In en, this message translates to:
  /// **'About this property'**
  String get aboutProperty;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfile;

  /// No description provided for @reportThisListing.
  ///
  /// In en, this message translates to:
  /// **'Report this listing'**
  String get reportThisListing;

  /// No description provided for @listedDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Listed today} =1{Listed yesterday} other{Listed {count} days ago}}'**
  String listedDaysAgo(int count);

  /// No description provided for @areaLabel.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get areaLabel;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @sendSms.
  ///
  /// In en, this message translates to:
  /// **'Send SMS'**
  String get sendSms;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @individualLabel.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individualLabel;

  /// No description provided for @noPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'No phone number on this listing'**
  String get noPhoneNumber;

  /// No description provided for @photoOf.
  ///
  /// In en, this message translates to:
  /// **'Photo {index} of {total}'**
  String photoOf(int index, int total);

  /// No description provided for @reportPrivate.
  ///
  /// In en, this message translates to:
  /// **'Reports are private. They help us keep listings accurate and safe.'**
  String get reportPrivate;

  /// No description provided for @detailsOptional.
  ///
  /// In en, this message translates to:
  /// **'Details (optional)'**
  String get detailsOptional;

  /// No description provided for @tellUsWhatsWrong.
  ///
  /// In en, this message translates to:
  /// **'Tell us what\'s wrong'**
  String get tellUsWhatsWrong;

  /// No description provided for @propertiesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No properties} =1{1 property} other{{count} properties}}'**
  String propertiesCount(int count);

  /// No description provided for @noSavedYet.
  ///
  /// In en, this message translates to:
  /// **'No saved properties yet'**
  String get noSavedYet;

  /// No description provided for @noSavedBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark on any listing to keep it here.'**
  String get noSavedBody;

  /// No description provided for @onlineCount.
  ///
  /// In en, this message translates to:
  /// **'Online · {count}'**
  String onlineCount(int count);

  /// No description provided for @offlineCount.
  ///
  /// In en, this message translates to:
  /// **'Offline · {count}'**
  String offlineCount(int count);

  /// No description provided for @makeOffline.
  ///
  /// In en, this message translates to:
  /// **'Make offline'**
  String get makeOffline;

  /// No description provided for @makeOnline.
  ///
  /// In en, this message translates to:
  /// **'Make online'**
  String get makeOnline;

  /// No description provided for @newListing.
  ///
  /// In en, this message translates to:
  /// **'New listing'**
  String get newListing;

  /// No description provided for @actionsFor.
  ///
  /// In en, this message translates to:
  /// **'Actions for {title}'**
  String actionsFor(String title);

  /// No description provided for @deleteListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this listing?'**
  String get deleteListingTitle;

  /// No description provided for @deleteListingBody.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be removed for good.'**
  String deleteListingBody(String title);

  /// No description provided for @listingStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Listing status updated'**
  String get listingStatusUpdated;

  /// No description provided for @noOnlineListings.
  ///
  /// In en, this message translates to:
  /// **'No online listings'**
  String get noOnlineListings;

  /// No description provided for @noOfflineListings.
  ///
  /// In en, this message translates to:
  /// **'No offline listings'**
  String get noOfflineListings;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @listingType.
  ///
  /// In en, this message translates to:
  /// **'Listing type'**
  String get listingType;

  /// No description provided for @addLabel.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addLabel;

  /// No description provided for @coverLabel.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get coverLabel;

  /// No description provided for @photosHint.
  ///
  /// In en, this message translates to:
  /// **'The first photo is the cover.'**
  String get photosHint;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @visibleToBuyers.
  ///
  /// In en, this message translates to:
  /// **'Visible to buyers'**
  String get visibleToBuyers;

  /// No description provided for @visibleToBuyersSub.
  ///
  /// In en, this message translates to:
  /// **'Turn off to save as offline'**
  String get visibleToBuyersSub;

  /// No description provided for @searchAddress.
  ///
  /// In en, this message translates to:
  /// **'Search an address'**
  String get searchAddress;

  /// No description provided for @describeHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the property, the neighbourhood, what\'s included…'**
  String get describeHint;

  /// No description provided for @deleteListing.
  ///
  /// In en, this message translates to:
  /// **'Delete listing'**
  String get deleteListing;

  /// No description provided for @editListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit listing'**
  String get editListingTitle;

  /// No description provided for @addAtLeastOnePhoto.
  ///
  /// In en, this message translates to:
  /// **'Add at least one photo.'**
  String get addAtLeastOnePhoto;

  /// No description provided for @individualAccount.
  ///
  /// In en, this message translates to:
  /// **'Individual account'**
  String get individualAccount;

  /// No description provided for @agencyAccount.
  ///
  /// In en, this message translates to:
  /// **'Agency'**
  String get agencyAccount;

  /// No description provided for @boostAListing.
  ///
  /// In en, this message translates to:
  /// **'Boost a listing'**
  String get boostAListing;

  /// No description provided for @boostAListingSub.
  ///
  /// In en, this message translates to:
  /// **'Show up in Sponsored and higher in search.'**
  String get boostAListingSub;

  /// No description provided for @seePlans.
  ///
  /// In en, this message translates to:
  /// **'See plans'**
  String get seePlans;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @listingsCount.
  ///
  /// In en, this message translates to:
  /// **'Listings · {count}'**
  String listingsCount(int count);

  /// No description provided for @noListingsYet.
  ///
  /// In en, this message translates to:
  /// **'No listings yet'**
  String get noListingsYet;

  /// No description provided for @removePhotoAction.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhotoAction;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @darkModeSub.
  ///
  /// In en, this message translates to:
  /// **'Dark colours across the app'**
  String get darkModeSub;

  /// No description provided for @callSupport.
  ///
  /// In en, this message translates to:
  /// **'Call support'**
  String get callSupport;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email support'**
  String get emailSupport;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to log in again to see your listings.'**
  String get logoutConfirm;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to save listings and contact owners.'**
  String get loginSubtitle;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get accountType;

  /// No description provided for @individualSub.
  ///
  /// In en, this message translates to:
  /// **'Buying, renting or selling my own place'**
  String get individualSub;

  /// No description provided for @agencySub.
  ///
  /// In en, this message translates to:
  /// **'Listing properties for clients'**
  String get agencySub;

  /// No description provided for @rule8Chars.
  ///
  /// In en, this message translates to:
  /// **'8+ characters'**
  String get rule8Chars;

  /// No description provided for @ruleUppercase.
  ///
  /// In en, this message translates to:
  /// **'Uppercase'**
  String get ruleUppercase;

  /// No description provided for @ruleLowercase.
  ///
  /// In en, this message translates to:
  /// **'Lowercase'**
  String get ruleLowercase;

  /// No description provided for @ruleNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get ruleNumber;

  /// No description provided for @addProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a profile photo'**
  String get addProfilePhoto;

  /// No description provided for @addProfilePhotoBody.
  ///
  /// In en, this message translates to:
  /// **'Buyers and owners are more likely to reply when they can see who they\'re talking to.'**
  String get addProfilePhotoBody;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @resetPasswordSub.
  ///
  /// In en, this message translates to:
  /// **'We\'ll email you a verification code.'**
  String get resetPasswordSub;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @codeSent.
  ///
  /// In en, this message translates to:
  /// **'Code sent. Check your inbox.'**
  String get codeSent;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get enterCode;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get verifyCode;

  /// No description provided for @didntGetIt.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get it?'**
  String get didntGetIt;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @newPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordTitle;

  /// No description provided for @newPasswordSub.
  ///
  /// In en, this message translates to:
  /// **'Choose a password you haven\'t used before.'**
  String get newPasswordSub;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePassword;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @welcomeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Find a place\nto call home.'**
  String get welcomeHeadline;

  /// No description provided for @welcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Houses, apartments, villas, studios and offices for sale or rent across Algeria.'**
  String get welcomeBody;

  /// No description provided for @boostListing.
  ///
  /// In en, this message translates to:
  /// **'Boost listing'**
  String get boostListing;

  /// No description provided for @boostIntro.
  ///
  /// In en, this message translates to:
  /// **'Boosted listings appear in Sponsored on the Home screen and higher in search.'**
  String get boostIntro;

  /// No description provided for @mostChosen.
  ///
  /// In en, this message translates to:
  /// **'Most chosen'**
  String get mostChosen;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String daysCount(int count);

  /// No description provided for @featuredOnHome.
  ///
  /// In en, this message translates to:
  /// **'Featured placement on Home'**
  String get featuredOnHome;

  /// No description provided for @boostedBadgeFeature.
  ///
  /// In en, this message translates to:
  /// **'Boosted badge'**
  String get boostedBadgeFeature;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order summary'**
  String get orderSummary;

  /// No description provided for @planLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get planLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @payWith.
  ///
  /// In en, this message translates to:
  /// **'Card details'**
  String get payWith;

  /// No description provided for @payAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String payAmount(String amount);

  /// No description provided for @boostedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your listing is boosted'**
  String get boostedTitle;

  /// No description provided for @boostedBody.
  ///
  /// In en, this message translates to:
  /// **'{title} now appears in Sponsored.'**
  String boostedBody(String title);

  /// No description provided for @noPlansAvailable.
  ///
  /// In en, this message translates to:
  /// **'No plans available right now.'**
  String get noPlansAvailable;

  /// No description provided for @securePaymentNote.
  ///
  /// In en, this message translates to:
  /// **'Payments are processed securely.'**
  String get securePaymentNote;

  /// No description provided for @pickListingToBoost.
  ///
  /// In en, this message translates to:
  /// **'Pick a listing to boost'**
  String get pickListingToBoost;

  /// No description provided for @noListingsToBoost.
  ///
  /// In en, this message translates to:
  /// **'Post a listing first, then boost it.'**
  String get noListingsToBoost;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Try again.'**
  String get uploadFailed;

  /// No description provided for @planPriceDays.
  ///
  /// In en, this message translates to:
  /// **'{price} · {days}'**
  String planPriceDays(String price, String days);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
