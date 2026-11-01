import 'package:flutter/material.dart';

import '../resources/fonts_manager.dart';

abstract class BaseTheme {
  Color get primaryColor;
  Color get textColor;
  Color get background;
  Color get focusColor;
  Color get appbarBackgroundColor;
  ThemeData get themeData;

  TextStyle textStyle({
    double fontSize = FontSize.s14,
    FontWeight fontWeight = FontWeightManager.regular,
    Color? color,
    double height = 1.5,
  }) {
    return TextStyle(
      fontFamily: FontConstants.fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textColor,
      height: height,
    );
  }

  TextTheme buildTextTheme({required Color mutedColor}) {
    return TextTheme(
      displayLarge: textStyle(
        fontSize: FontSize.s45,
        fontWeight: FontWeightManager.bold,
        height: 1.2,
      ),
      displayMedium: textStyle(
        fontSize: FontSize.s40,
        fontWeight: FontWeightManager.bold,
        height: 1.25,
      ),
      headlineLarge: textStyle(
        fontSize: FontSize.s28,
        fontWeight: FontWeightManager.bold,
        height: 1.35,
      ),
      headlineMedium: textStyle(
        fontSize: FontSize.s26,
        fontWeight: FontWeightManager.bold,
        height: 1.35,
      ),
      headlineSmall: textStyle(
        fontSize: FontSize.s24,
        fontWeight: FontWeightManager.bold,
        height: 1.4,
      ),
      titleLarge: textStyle(
        fontSize: FontSize.s22,
        fontWeight: FontWeightManager.bold,
        height: 1.4,
      ),
      titleMedium: textStyle(
        fontSize: FontSize.s18,
        fontWeight: FontWeightManager.semiBold,
        height: 1.45,
      ),
      titleSmall: textStyle(
        fontSize: FontSize.s16,
        fontWeight: FontWeightManager.semiBold,
        height: 1.45,
      ),
      bodyLarge: textStyle(
        fontSize: FontSize.s16,
        fontWeight: FontWeightManager.regular,
        height: 1.7,
      ),
      bodyMedium: textStyle(
        fontSize: FontSize.s14,
        fontWeight: FontWeightManager.regular,
        color: mutedColor,
        height: 1.6,
      ),
      bodySmall: textStyle(
        fontSize: FontSize.s12,
        fontWeight: FontWeightManager.regular,
        color: mutedColor,
        height: 1.5,
      ),
      labelLarge: textStyle(
        fontSize: FontSize.s14,
        fontWeight: FontWeightManager.semiBold,
        height: 1.4,
      ),
      labelMedium: textStyle(
        fontSize: FontSize.s12,
        fontWeight: FontWeightManager.medium,
        height: 1.4,
      ),
      labelSmall: textStyle(
        fontSize: FontSize.s12,
        fontWeight: FontWeightManager.medium,
        color: mutedColor,
        height: 1.4,
      ),
    );
  }
}