
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'is_dark_mode';

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode =>
      _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> loadTheme() async {
    final preferences = await SharedPreferences.getInstance();

    _isDarkMode = preferences.getBool(_themeKey) ?? false;

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;

    notifyListeners();

    final preferences = await SharedPreferences.getInstance();

    await preferences.setBool(_themeKey, _isDarkMode);
  }
}
