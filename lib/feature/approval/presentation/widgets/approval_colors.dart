import 'package:erp_system/core/resources/colors_manager.dart';
import 'package:flutter/material.dart';


class AC {
  final bool dark;

  const AC._(this.dark);

  factory AC.of(BuildContext context) =>
      AC._(Theme.of(context).brightness == Brightness.dark);

  Color _p(Color light, Color darkColor) => dark ? darkColor : light;

  Color get scaffold =>
      _p(ColorManager.approvalScaffoldLight, ColorManager.approvalScaffoldDark);
  Color get surface =>
      _p(ColorManager.approvalSurfaceLight, ColorManager.approvalSurfaceDark);
  Color get surfaceAlt => _p(
      ColorManager.approvalSurfaceAltLight, ColorManager.approvalSurfaceAltDark);
  Color get pill =>
      _p(ColorManager.approvalPillLight, ColorManager.approvalPillDark);
  Color get noteBg =>
      _p(ColorManager.approvalNoteBgLight, ColorManager.approvalNoteBgDark);

  Color get border =>
      _p(ColorManager.approvalBorderLight, ColorManager.approvalBorderDark);
  Color get line =>
      _p(ColorManager.approvalLineLight, ColorManager.approvalLineDark);
  Color get dot =>
      _p(ColorManager.approvalDotLight, ColorManager.approvalDotDark);

  Color get text =>
      _p(ColorManager.approvalTextLight, ColorManager.approvalTextDark);
  Color get textStrong => _p(
      ColorManager.approvalTextStrongLight, ColorManager.approvalTextStrongDark);
  Color get muted =>
      _p(ColorManager.approvalMutedLight, ColorManager.approvalMutedDark);
  Color get primary =>
      _p(ColorManager.approvalPrimaryLight, ColorManager.approvalPrimaryDark);

  Color get neutralChipBg => _p(ColorManager.approvalNeutralChipBgLight,
      ColorManager.approvalNeutralChipBgDark);
  Color get neutralChipFg => _p(ColorManager.approvalNeutralChipFgLight,
      ColorManager.approvalNeutralChipFgDark);

  Color get chatBg =>
      _p(ColorManager.approvalChatBgLight, ColorManager.approvalChatBgDark);
  Color get incomingBubble => _p(ColorManager.approvalIncomingBubbleLight,
      ColorManager.approvalIncomingBubbleDark);
  Color get inputBg =>
      _p(ColorManager.approvalInputBgLight, ColorManager.approvalInputBgDark);
  Color get inputBorder => _p(
      ColorManager.approvalInputBorderLight, ColorManager.approvalInputBorderDark);
  Color get inputText => text;
  Color get hint =>
      _p(ColorManager.approvalHintLight, ColorManager.approvalHintDark);
  Color get chatDivider => _p(ColorManager.approvalChatDividerLight,
      ColorManager.approvalChatDividerDark);

  (Color, Color) status(String s) {
    switch (s) {
      case 'معتمد':
        return dark
            ? (ColorManager.approvalApprovedBgDark,
        ColorManager.approvalApprovedFgDark)
            : (ColorManager.approvalApprovedBgLight,
        ColorManager.approvalApprovedFgLight);
      case 'مرفوض':
        return dark
            ? (ColorManager.approvalRejectedBgDark,
        ColorManager.approvalRejectedFgDark)
            : (ColorManager.approvalRejectedBgLight,
        ColorManager.approvalRejectedFgLight);
      default:
        return dark
            ? (ColorManager.approvalPendingBgDark,
        ColorManager.approvalPendingFgDark)
            : (ColorManager.approvalPendingBgLight,
        ColorManager.approvalPendingFgLight);
    }
  }
}