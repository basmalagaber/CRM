import 'package:flutter/material.dart';

import '../resources/colors_manager.dart';
import '../resources/fonts_manager.dart';
import 'base_theme.dart';

class LightTheme extends BaseTheme {
  @override
  Color get background => ColorManager.backgroundColor;

  @override
  Color get primaryColor => ColorManager.primaryColor;

  @override
  Color get textColor => ColorManager.textDarkColor;

  @override
  Color get focusColor => ColorManager.primaryColor;

  @override
  Color get appbarBackgroundColor => ColorManager.appbarBackgroundColorLight;

  static const Color cardBackground = ColorManager.cardLight;
  static const Color borderColor = ColorManager.borderLight;

  @override
  ThemeData get themeData => ThemeData(
    useMaterial3: true,
    fontFamily: FontConstants.fontFamily,
    brightness: Brightness.light,
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
      unselectedItemColor: ColorManager.textMutedColor,
      selectedLabelStyle: textStyle(
        fontSize: FontSize.s12,
        fontWeight: FontWeightManager.bold,
        height: 1.3,
      ),
      unselectedLabelStyle: textStyle(
        fontSize: FontSize.s12,
        fontWeight: FontWeightManager.medium,
        color: ColorManager.textMutedColor,
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
      fillColor: ColorManager.fieldBg,
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
        borderSide: const BorderSide(width: 1, color: ColorManager.errorBorder),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          width: 1.5,
          color: ColorManager.errorBorder,
        ),
      ),
      prefixIconColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.focused)
            ? primaryColor
            : ColorManager.textMutedColor,
      ),
      suffixIconColor: ColorManager.textMutedColor,
      hintStyle: textStyle(
        fontSize: FontSize.s14,
        color: ColorManager.textMutedColor.withOpacity(0.7),
      ),
      labelStyle: textStyle(
        fontSize: FontSize.s14,
        color: ColorManager.textMutedColor,
      ),
      errorStyle: textStyle(
        fontSize: FontSize.s12,
        color: ColorManager.errorBorder,
      ),
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
        color: ColorManager.textMutedColor,
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

    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: ColorManager.secondColor,
      surface: background,
      error: ColorManager.errorBorder,
      onPrimary: Colors.white,
      onSurface: textColor,
    ),

    textTheme: buildTextTheme(mutedColor: ColorManager.textMutedColor),
  );
}