import 'package:flutter/material.dart';

import '../resources/colors_manager.dart';
import '../resources/fonts_manager.dart';
import 'base_theme.dart';

class DarkTheme extends BaseTheme {
  @override
  Color get background => const Color(0xFF101127);

  @override
  Color get primaryColor => const Color(0xFF5669FF);

  @override
  Color get textColor => const Color(0xFFF4EBDC);

  @override
  Color get focusColor => primaryColor;

  @override
  Color get appbarBackgroundColor => ColorManager.appbarBackgroundColorDark;

  static const Color cardBackground = Color(0xFF1A1C3A);
  static const Color mutedTextColor = Color(0xFF9195B5);
  static const Color borderColor = Color(0xFF2A2C4E);
  static const Color successColor = Color(0xFF2ED47A);
  static const Color dangerColor = Color(0xFFE84C6D);

  @override
  ThemeData get themeData => ThemeData(
    useMaterial3: true,
    fontFamily: FontConstants.fontFamily,
    brightness: Brightness.dark,
    focusColor: focusColor,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: background,
    dividerColor: borderColor,

    dividerTheme: const DividerThemeData(color: borderColor, thickness: 1),

    appBarTheme: AppBarTheme(
      backgroundColor: background,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textColor),
      titleTextStyle: textStyle(
        fontSize: FontSize.s18,
        fontWeight: FontWeightManager.bold,
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: cardBackground,
      selectedItemColor: primaryColor,
      unselectedItemColor: mutedTextColor,
      selectedLabelStyle: textStyle(
        fontSize: FontSize.s12,
        fontWeight: FontWeightManager.bold,
        height: 1.3,
      ),
      unselectedLabelStyle: textStyle(
        fontSize: FontSize.s12,
        fontWeight: FontWeightManager.medium,
        color: mutedTextColor,
        height: 1.3,
      ),
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      showSelectedLabels: true,
      elevation: 0,
    ),

    cardTheme: CardThemeData(
      color: cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: borderColor, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(width: 1, color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(width: 1, color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(width: 1.5, color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(width: 1, color: dangerColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(width: 1.5, color: dangerColor),
      ),
      prefixIconColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.focused)
            ? primaryColor
            : mutedTextColor,
      ),
      suffixIconColor: mutedTextColor,
      hintStyle: textStyle(
        fontSize: FontSize.s14,
        color: mutedTextColor.withOpacity(0.7),
      ),
      labelStyle: textStyle(fontSize: FontSize.s14, color: mutedTextColor),
      errorStyle: textStyle(fontSize: FontSize.s12, color: dangerColor),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: cardBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      titleTextStyle: textStyle(
        fontSize: FontSize.s18,
        fontWeight: FontWeightManager.bold,
      ),
      contentTextStyle: textStyle(
        fontSize: FontSize.s14,
        color: mutedTextColor,
        height: 1.6,
      ),
    ),

    popupMenuTheme: PopupMenuThemeData(
      color: cardBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: borderColor),
      ),
      textStyle: textStyle(fontSize: FontSize.s14),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: cardBackground,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(0, 46),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: textStyle(
          fontSize: FontSize.s14,
          fontWeight: FontWeightManager.bold,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        minimumSize: const Size(0, 46),
        side: BorderSide(color: primaryColor.withOpacity(0.4)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: textStyle(
          fontSize: FontSize.s14,
          fontWeight: FontWeightManager.bold,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: textStyle(
          fontSize: FontSize.s14,
          fontWeight: FontWeightManager.bold,
        ),
      ),
    ),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF5669FF),
      secondary: Color(0xFF5669FF),
      surface: Color(0xFF1A1C3A),
      error: Color(0xFFE84C6D),
      onPrimary: Colors.white,
      onSurface: Color(0xFFF4EBDC),
    ),

    textTheme: buildTextTheme(mutedColor: mutedTextColor),
  );
}