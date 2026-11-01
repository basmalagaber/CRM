import 'package:flutter/material.dart';

class AppSettings {
  AppSettings._();

  static final ValueNotifier<ThemeMode> themeMode =
  ValueNotifier<ThemeMode>(ThemeMode.light);

  static final ValueNotifier<Locale> locale =
  ValueNotifier<Locale>(const Locale('ar'));

  static bool get isDark => themeMode.value == ThemeMode.dark;
  static bool get isArabic => locale.value.languageCode == 'ar';

  static void setDark(bool value) =>
      themeMode.value = value ? ThemeMode.dark : ThemeMode.light;

  static void setArabic(bool value) =>
      locale.value = Locale(value ? 'ar' : 'en');
}