import 'package:flutter/material.dart';


abstract class AppDecorations {
  static BoxDecoration card(
      BuildContext context, {
        double radius = 20,
        Color? color,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BoxDecoration(
      color: color ?? theme.cardTheme.color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark ? const Color(0xFF2A2C4E) : const Color(0xFFEEF2F8),
      ),

    );
  }
}