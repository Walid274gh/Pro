import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocale {
  static final ValueNotifier<Locale> locale = ValueNotifier<Locale>(const Locale('fr'));

  static const List<Locale> supportedLocales = [
    Locale('fr'),
    Locale('en'),
    Locale('ar'),
  ];

  static Future<void> loadInitial() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language') ?? 'fr';
    locale.value = Locale(code);
  }

  static Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', code);
    locale.value = Locale(code);
  }
}