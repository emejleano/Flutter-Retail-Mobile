import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { indonesian, english }

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  
  AppLanguage _currentLanguage = AppLanguage.indonesian;
  Locale _locale = const Locale('id', 'ID');
  
  AppLanguage get currentLanguage => _currentLanguage;
  Locale get locale => _locale;
  bool get isIndonesian => _currentLanguage == AppLanguage.indonesian;
  bool get isEnglish => _currentLanguage == AppLanguage.english;
  
  LanguageProvider() {
    _loadLanguage();
  }
  
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_languageKey) ?? 'id';
    _setLanguageFromCode(langCode);
    notifyListeners();
  }
  
  void _setLanguageFromCode(String code) {
    if (code == 'en') {
      _currentLanguage = AppLanguage.english;
      _locale = const Locale('en', 'US');
    } else {
      _currentLanguage = AppLanguage.indonesian;
      _locale = const Locale('id', 'ID');
    }
  }
  
  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;
    
    _currentLanguage = language;
    
    final prefs = await SharedPreferences.getInstance();
    
    if (language == AppLanguage.english) {
      _locale = const Locale('en', 'US');
      await prefs.setString(_languageKey, 'en');
    } else {
      _locale = const Locale('id', 'ID');
      await prefs.setString(_languageKey, 'id');
    }
    
    notifyListeners();
  }
  
  void toggleLanguage() {
    if (_currentLanguage == AppLanguage.indonesian) {
      setLanguage(AppLanguage.english);
    } else {
      setLanguage(AppLanguage.indonesian);
    }
  }
  
  String get languageCode => _currentLanguage == AppLanguage.english ? 'en' : 'id';
  String get languageName => _currentLanguage == AppLanguage.english ? 'English' : 'Bahasa Indonesia';
}
