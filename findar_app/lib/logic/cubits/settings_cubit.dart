import 'package:flutter_bloc/flutter_bloc.dart';

/// SettingsCubit handles app settings (theme, language, notifications, etc.)
/// State: {darkMode: bool, language: 'en'|'fr'|'ar', notifications: bool, ...}
class SettingsCubit extends Cubit<Map<String, dynamic>> {
  SettingsCubit()
      : super({
          'darkMode': false,
          'language': 'en', // 'en', 'fr', 'ar'
          'notifications': true,
          'emailNotifications': true,
          'pushNotifications': true,
          'locationServices': false,
          'autoPlay': true,
        });

  /// Toggle dark mode
  void toggleDarkMode() {
    final currentMode = state['darkMode'] as bool;
    emit({...state, 'darkMode': !currentMode});
  }

  /// Change language
  void changeLanguage(String language) {
    // Validate language
    if (['en', 'fr', 'ar'].contains(language)) {
      emit({...state, 'language': language});
    }
  }

  /// Toggle notifications
  void toggleNotifications() {
    final current = state['notifications'] as bool;
    emit({
      ...state,
      'notifications': !current,
      'emailNotifications': !current,
      'pushNotifications': !current,
    });
  }

  /// Toggle email notifications
  void toggleEmailNotifications() {
    final current = state['emailNotifications'] as bool;
    emit({...state, 'emailNotifications': !current});
  }

  /// Toggle push notifications
  void togglePushNotifications() {
    final current = state['pushNotifications'] as bool;
    emit({...state, 'pushNotifications': !current});
  }

  /// Toggle location services
  void toggleLocationServices() {
    final current = state['locationServices'] as bool;
    emit({...state, 'locationServices': !current});
  }

  /// Toggle auto play
  void toggleAutoPlay() {
    final current = state['autoPlay'] as bool;
    emit({...state, 'autoPlay': !current});
  }

  /// Get current theme mode
  bool get darkMode => state['darkMode'] as bool;

  /// Get current language
  String get language => state['language'] as String;

  /// Get notifications status
  bool get notificationsEnabled => state['notifications'] as bool;
}
