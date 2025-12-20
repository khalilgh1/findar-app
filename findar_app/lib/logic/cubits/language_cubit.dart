import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCubit extends Cubit<String> {
  LanguageCubit() : super('en') {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('app_language') ?? 'en';
      emit(savedLanguage);
    } catch (e) {
      emit('en'); // Default to English if error
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', languageCode);
      emit(languageCode);
      // Add small delay to allow MaterialApp to rebuild before any navigation
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      // Handle error
      print('Error changing language: $e');
    }
  }
}
