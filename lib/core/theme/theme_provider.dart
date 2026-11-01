
import 'package:flutter/material.dart';

import 'dark_theme.dart';
import 'light_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeData get lightTheme => LightTheme().themeData;
  ThemeData get darkTheme => DarkTheme().themeData;

  void toggleTheme() {
    _themeMode =
    isDarkMode ? ThemeMode.light : ThemeMode.dark;

    notifyListeners();
  }

  void setDarkMode(bool value) {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
