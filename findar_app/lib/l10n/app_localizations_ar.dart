// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'FinDar';

  @override
  String get welcomeBack => 'مرحبًا بعودتك!';

  @override
  String get completeRegistration => 'أكمل تسجيلك';

  @override
  String get selectAccountType => 'اختر نوع الحساب';

  @override
  String get accountIndividual => 'فرد';

  @override
  String get accountAgency => 'وكالة';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get enterFullName => 'أدخل اسمك الكامل';

  @override
  String get emailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get enterEmail => 'أدخل عنوان بريدك الإلكتروني';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get enterPhone => 'أدخل رقم هاتفك';

  @override
  String get password => 'كلمة المرور';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور';

  @override
  String get ninLabel => 'رقم الهوية الوطنية';

  @override
  String get enterNin => 'أدخل رقم الهوية الوطنية';

  @override
  String get registerNow => 'سجل الآن';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get register => 'التسجيل';

  @override
  String get welcome => 'مرحبًا';

  @override
  String get yourPropertyMarketplace => 'سوق العقارات الخاص بك';

  @override
  String get buy => 'شراء';

  @override
  String get sell => 'بيع';

  @override
  String get rent => 'إيجار';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get sponsoredProperties => 'عقارات مُمولة';

  @override
  String get recentListings => 'القوائم الأخيرة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get exploreProperties => 'استكشف العقارات';

  @override
  String get forSale => 'للبيع';

  @override
  String get forRent => 'للإيجار';

  @override
  String get newConstructions => 'مباني جديدة';

  @override
  String get house => 'منزل';

  @override
  String get apartment => 'شقة';

  @override
  String get villa => 'فيلا';

  @override
  String get studio => 'استوديو';

  @override
  String get office => 'مكتب';

  @override
  String get any => 'الكل';

  @override
  String get propertyDetails => 'تفاصيل العقار';

  @override
  String get bedrooms => 'غرف النوم';

  @override
  String get bathrooms => 'الحمامات';

  @override
  String get squareFootage => 'المساحة بالقدم المربع';

  @override
  String get sqft => 'قدم²';

  @override
  String get description => 'الوصف';

  @override
  String get features => 'المميزات';

  @override
  String get location => 'الموقع';

  @override
  String get agentInfo => 'معلومات الوكيل';

  @override
  String get similarProperties => 'عقارات مشابهة';

  @override
  String get contactAgent => 'اتصل بالوكيل';

  @override
  String get scheduleTour => 'جدولة جولة';

  @override
  String get share => 'مشاركة';

  @override
  String get save => 'حفظ';

  @override
  String get searchResults => 'نتائج البحث';

  @override
  String get sort => 'ترتيب';

  @override
  String get filter => 'تصفية';

  @override
  String get filters => 'الفلاتر';

  @override
  String get noPropertiesFound => 'لم يتم العثور على عقارات';

  @override
  String get pleaseTryAdjustingFilters => 'يرجى محاولة تعديل معايير البحث';

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get priceLowToHigh => 'السعر: من الأقل إلى الأعلى';

  @override
  String get priceHighToLow => 'السعر: من الأعلى إلى الأقل';

  @override
  String get newest => 'الأحدث';

  @override
  String get mostPopular => 'الأكثر شعبية';

  @override
  String get advancedSearch => 'بحث متقدم';

  @override
  String get enterLocationHint => 'أدخل مدينة أو رمز بريدي أو حي';

  @override
  String get priceRange => 'نطاق السعر';

  @override
  String get propertyType => 'نوع العقار';

  @override
  String get buildingType => 'نوع المبنى';

  @override
  String get bedsAndBaths => 'غرف النوم والحمامات';

  @override
  String get minLabel => 'الحد الأدنى';

  @override
  String get maxLabel => 'الحد الأقصى';

  @override
  String get listedBy => 'مدرج بواسطة';

  @override
  String get privateOwner => 'صاحب خاص';

  @override
  String get realEstateAgent => 'وكيل عقاري';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get showResults => 'عرض النتائج';

  @override
  String showingResults(int count) {
    return 'عرض $count نتيجة';
  }

  @override
  String get createListing => 'إنشاء إعلان';

  @override
  String editListing(String title) {
    return 'تعديل \"$title\"';
  }

  @override
  String get propertyTitle => 'عنوان العقار';

  @override
  String get examplePropertyTitleHint => 'مثال: شقة واسعة بـ 3 غرف نوم';

  @override
  String get price => 'السعر';

  @override
  String get examplePriceHint => '250 000';

  @override
  String get exampleLocationHint => 'مثال: 15 شارع ديدوش مراد، الجزائر';

  @override
  String get propertyDescriptionHint => 'اكتب تفاصيل العقار هنا...';

  @override
  String get verificationCode => 'رمز التحقق';

  @override
  String get getCode => 'الحصول على الرمز';

  @override
  String get enterVerificationCodeHint => 'أدخل رمز التحقق';

  @override
  String get enterNewPasswordHint => 'أدخل كلمة المرور الجديدة';

  @override
  String get confirmNewPasswordHint => 'تأكيد كلمة المرور الجديدة';

  @override
  String get priceOnRequest => 'السعر عند الطلب';

  @override
  String get boostedBadge => 'مُعزَّز';

  @override
  String get boostAction => 'تعزيز';

  @override
  String get toggleStatus => 'تبديل الحالة';

  @override
  String get passwordResetSuccess => 'تمت إعادة تعيين كلمة المرور بنجاح!';

  @override
  String get listingCreateFailed => 'فشل إنشاء الإعلان';

  @override
  String get chooseImageSource => 'اختر مصدر الصورة';

  @override
  String get gallery => 'المعرض';

  @override
  String get camera => 'الكاميرا';

  @override
  String errorPickingImage(String error) {
    return 'خطأ أثناء اختيار الصورة: $error';
  }

  @override
  String get classification => 'التصنيف';

  @override
  String get propertyStatus => 'حالة العقار';

  @override
  String get online => 'متصل';

  @override
  String get offline => 'غير متصل';

  @override
  String get floors => 'الطوابق';

  @override
  String get rooms => 'الغرف';

  @override
  String get addImages => 'إضافة صور';

  @override
  String get publishListing => 'نشر الإعلان';

  @override
  String get listingCreatedSuccessfully => 'تم إنشاء الإعلان بنجاح!';

  @override
  String get removedFromSaved => 'تم الحذف من المفضلة';

  @override
  String get savedListings => 'الإعلانات المحفوظة';

  @override
  String get noSavedListings => 'لا توجد قوائم محفوظة بعد';

  @override
  String get startExploring => 'ابدأ في استكشاف العقارات لحفظ المفضلة لديك';

  @override
  String get myListings => 'إعلاناتي';

  @override
  String get removeListingTitle => 'حذف الإعلان';

  @override
  String removeListingConfirm(String title) {
    return 'هل أنت متأكد من رغبتك في حذف \"$title\"؟';
  }

  @override
  String get listingRemoved => 'تم حذف الإعلان';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get listings => 'الإعلانات';

  @override
  String get addNew => 'إضافة جديد';

  @override
  String get viewListing => 'عرض الإعلان';

  @override
  String get editProfile => 'تحرير الملف الشخصي';

  @override
  String get accountSettings => 'إعدادات الحساب';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get profilePictureUpdated => 'تم تحديث صورة الملف الشخصي بنجاح';

  @override
  String get upload => 'رفع';

  @override
  String get skip => 'تخطي';

  @override
  String get settings => 'الإعدادات';

  @override
  String get appearance => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get french => 'الفرنسية';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String get contactPhone => '+1 (234) 567-890';

  @override
  String get twitter => 'تويتر';

  @override
  String get facebook => 'فيسبوك';

  @override
  String get instagram => 'إنستغرام';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get about => 'حول';

  @override
  String get version => 'الإصدار';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get apply => 'تطبيق';

  @override
  String get close => 'إغلاق';

  @override
  String get next => 'التالي';

  @override
  String get previous => 'السابق';

  @override
  String get done => 'تم';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get ok => 'حسنًا';

  @override
  String get error => 'خطأ';

  @override
  String get success => 'نجاح';

  @override
  String get loading => 'جار التحميل...';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get seeMore => 'عرض المزيد';

  @override
  String get seeLess => 'عرض أقل';

  @override
  String get errorOccurred => 'حدث خطأ';

  @override
  String get networkError => 'خطأ في الشبكة. يرجى التحقق من اتصالك';

  @override
  String get invalidEmail => 'يرجى إدخال بريد إلكتروني صالح';

  @override
  String get invalidPassword => 'كلمة المرور مطلوبة';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get nameRequired => 'الاسم مطلوب';

  @override
  String get nameTooShort => 'يجب أن يكون الاسم 3 أحرف على الأقل';

  @override
  String get passwordTooShort => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get passwordMissingUppercase =>
      'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل';

  @override
  String get passwordMissingNumber =>
      'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل';

  @override
  String get phoneRequired => 'رقم الهاتف مطلوب';

  @override
  String get phoneTooShort => 'يجب أن يكون رقم الهاتف 10 أرقام على الأقل';

  @override
  String get accountTypeRequired => 'يرجى تحديد نوع الحساب';

  @override
  String get home => 'الرئيسية';

  @override
  String get saved => 'محفوظ';

  @override
  String get search => 'بحث';

  @override
  String get searchHint => 'البحث عن العقارات...';

  @override
  String get noResults => 'لم يتم العثور على نتائج';

  @override
  String get createNewListing => 'إنشاء إعلان جديد';

  @override
  String get photos => 'الصور';

  @override
  String get addPhotos => 'إضافة صور';

  @override
  String get status => 'الحالة';

  @override
  String get undo => 'تراجع';

  @override
  String get noSavedProperties => 'لا توجد عقارات محفوظة';

  @override
  String get savePropertiesToViewHere => 'احفظ العقارات لعرضها هنا';

  @override
  String noListingsMessage(String tab) {
    return 'لا توجد إعلانات $tab';
  }

  @override
  String get addFirstPropertyListing => 'أضف قائمة العقارات الأولى الخاصة بك';

  @override
  String get chooseSponsorshipPlan => 'اختر خطة رعاية';

  @override
  String get selectPlanToBoostProperty => 'حدد خطة لتعزيز العقار الخاص بك';

  @override
  String get continueToPayment => 'متابعة إلى الدفع';

  @override
  String get paymentConfirmation => 'تأكيد الدفع';

  @override
  String get propertyBoostedSuccessfully => 'تم تعزيز العقار بنجاح!';

  @override
  String get payNow => 'ادفع الآن';

  @override
  String get locationHint => 'أدخل مدينة أو رمز بريدي أو حي';

  @override
  String bedroomsCount(int count) {
    return '$count غرف نوم';
  }

  @override
  String bathroomsCount(int count) {
    return '$count حمامات';
  }

  @override
  String get basicSponsor => 'راعي أساسي';

  @override
  String get premiumSponsor => 'راعي بريميوم';

  @override
  String get agencySponsorPlan => 'خطة رعاية الوكالة';

  @override
  String get featuredPlacement => 'موضع مميز';

  @override
  String get priorityInSearch => 'الأولوية في نتائج البحث';

  @override
  String get basicAnalytics => 'تحليلات أساسية';

  @override
  String get topPriority => 'أولوية عليا في نتائج البحث';

  @override
  String get advancedAnalytics => 'تحليلات متقدمة';

  @override
  String get premiumAnalyticsDashboard => 'لوحة تحليلات premium';

  @override
  String get dedicatedSupport => 'دعم مخصص';

  @override
  String get featuredBadge => 'شارة مميزة';

  @override
  String get cardNumber => 'رقم البطاقة';

  @override
  String get cardNumberHint => '1234 5678 9012 3456';

  @override
  String get cardholderName => 'اسم حامل البطاقة';

  @override
  String get cardholderNameHint => 'أحمد محمد';

  @override
  String get expiryDate => 'تاريخ الانتهاء';

  @override
  String get expiryDateHint => 'MM/YY';

  @override
  String get cvv => 'CVV';

  @override
  String get cvvHint => '123';

  @override
  String get validateTitleEmpty => 'يرجى إدخال عنوان العقار';

  @override
  String get validateTitleMinLength =>
      'يجب أن يكون العنوان بطول 5 أحرف على الأقل';

  @override
  String get validateDescriptionEmpty => 'يرجى إدخال وصف';

  @override
  String get validateDescriptionMinLength =>
      'يجب أن يكون الوصف بطول 20 حرفًا على الأقل';

  @override
  String get validatePriceEmpty => 'يرجى إدخال السعر';

  @override
  String get validatePriceInvalid => 'يرجى إدخال سعر صحيح';

  @override
  String get validatePricePositive => 'يجب أن يكون السعر أكبر من 0';

  @override
  String get validateLocationEmpty => 'يرجى إدخال الموقع';

  @override
  String get validateBedroomsEmpty => 'يرجى إدخال عدد غرف النوم';

  @override
  String get reportProperty => 'الإبلاغ عن العقار';

  @override
  String get selectReportReason => 'يرجى اختيار سبب الإبلاغ عن هذا العقار';

  @override
  String get inaccurateInformation => 'معلومات غير دقيقة';

  @override
  String get fraudulentListing => 'إعلان احتيالي';

  @override
  String get inappropriateContent => 'محتوى غير لائق';

  @override
  String get propertyNotAvailable => 'العقار غير متوفر';

  @override
  String get propertyReportedThankYou => 'تم الإبلاغ عن العقار، شكراً لك!';
}
