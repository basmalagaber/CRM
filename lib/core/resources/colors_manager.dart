import 'dart:ui';

abstract class ColorManager {
  // Main colors
  static const Color primaryColor = Color(0xFF2F6BFF);
  static const Color secondColor = Color(0xFFD3E2FF);
  static const Color backgroundColor = Color(0xFFF0F4F8);

  static const Color appbarBackgroundColorLight =
  Color(0xFFF8F9FA);
  static const Color appbarBackgroundColorDark =
  Color(0xFF2A2C4E);

  // Text colors
  static const Color textDarkColor = Color(0xFF0F1B3D);
  static const Color textMutedColor = Color(0xFF5B6B8C);

  // Fields
  static const Color fieldBg = Color(0xFFF4F7FD);

  // Error colors
  static const Color errorBg = Color(0xFFFDF4F5);
  static const Color errorBorder = Color(0xFFD1224B);
  static const Color errorTitle = Color(0xFFD1224B);
  static const Color errorText = Color(0xFFB0405E);

  // Icons and status
  static const Color iconColor = Color(0xFFFFFFFF);
  static const Color statusColor1 = Color(0xFF2ED47A);
  static const Color statusColor2 = Color(0xFF5B6B8C);
  static const Color statusColor3 = Color(0xFF2F6BFF);

  // Employee performance colors
  static const Color performanceBlue = Color(0xFF2864F0);
  static const Color performanceNavy = Color(0xFF172238);
  static const Color performanceMuted = Color(0xFF7E899B);
  static const Color performanceBgBlue = Color(0xFFEEF4FF);

  static const Color performanceGreen = Color(0xFF10B981);
  static const Color performanceRed = Color(0xFFF0444F);
  static const Color performanceOrange = Color(0xFFF59E0B);

  static const Color performancePaleGreen = Color(0xFFEAFBF2);
  static const Color performancePaleRed = Color(0xFFFFF0F1);
  static const Color performancePaleYellow = Color(0xFFFFFAE9);

  // Additional performance colors
  static const Color performanceLabel = Color(0xFF68758A);
  static const Color performancePaleOrange = Color(0xFFFFE8B3);
  static const Color performanceChartBlue = Color(0xFFA8D0FF);
  static const Color performanceSuccessBg = Color(0xFFD2FAE7);
  static const Color performanceBorder = Color(0xFFE5EAF1);



  static const Color primaryLightShade = Color(0xFF5B8CFF);
  static const Color primaryDarkShade = Color(0xFF1B4FD8);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE8EEF7);
  static const Color pageGradientLightTop = Color(0xFFE3ECFF);
  static const Color pageGradientDarkTop = Color(0xFF101127);
  static const Color pageGradientDarkBottom = Color(0xFF1A1C3A);


  static const Color approvalScaffoldLight = Color(0xFFF0F4F8);
  static const Color approvalSurfaceLight = Color(0xFFFFFFFF);
  static const Color approvalSurfaceAltLight = Color(0xFFF4F7FD);
  static const Color approvalPillLight = Color(0xFFFFFFFF);
  static const Color approvalNoteBgLight = Color(0xFFEEF4FF);

  static const Color approvalBorderLight = Color(0xFFE5EAF1);
  static const Color approvalLineLight = Color(0xFFE1E7F0);
  static const Color approvalDotLight = Color(0xFFB0B7C3);

  static const Color approvalTextLight = Color(0xFF0F1B3D);
  static const Color approvalTextStrongLight = Color(0xFF0F1B3D);
  static const Color approvalMutedLight = Color(0xFF5B6B8C);
  static const Color approvalPrimaryLight = Color(0xFF2F6BFF);

  static const Color approvalNeutralChipBgLight = Color(0xFFEFF2F7);
  static const Color approvalNeutralChipFgLight = Color(0xFF0F1B3D);

  static const Color approvalChatBgLight = Color(0xFFEEF4FF);
  static const Color approvalIncomingBubbleLight = Color(0xFFFFFFFF);
  static const Color approvalInputBgLight = Color(0xFFF4F7FD);
  static const Color approvalInputBorderLight = Color(0xFFE5EAF3);
  static const Color approvalHintLight = Color(0xFF78909C);
  static const Color approvalChatDividerLight = Color(0xFFE5EAF1);

  static const Color approvalApprovedBgLight = Color(0xFFD2FAE7);
  static const Color approvalApprovedFgLight = Color(0xFF15803D);
  static const Color approvalRejectedBgLight = Color(0xFFFFF0F1);
  static const Color approvalRejectedFgLight = Color(0xFFB91C1C);
  static const Color approvalPendingBgLight = Color(0xFFFFFAE9);
  static const Color approvalPendingFgLight = Color(0xFFC2410C);


  static const Color approvalScaffoldDark = Color(0xFF0B1220);
  static const Color approvalSurfaceDark = Color(0xFF151E2E);
  static const Color approvalSurfaceAltDark = Color(0xFF1A2438);
  static const Color approvalPillDark = Color(0xFF0B1220);
  static const Color approvalNoteBgDark = Color(0xFF0F1828);

  static const Color approvalBorderDark = Color(0xFF2A3548);
  static const Color approvalLineDark = Color(0xFF334155);
  static const Color approvalDotDark = Color(0xFF64748B);

  static const Color approvalTextDark = Color(0xFFF1F5F9);
  static const Color approvalTextStrongDark = Color(0xFFE2E8F0);
  static const Color approvalMutedDark = Color(0xFF94A3B8);
  static const Color approvalPrimaryDark = Color(0xFF6B9BFF);

  static const Color approvalNeutralChipBgDark = Color(0xFF334155);
  static const Color approvalNeutralChipFgDark = Color(0xFFE2E8F0);

  static const Color approvalChatBgDark = Color(0xFF0B1220);
  static const Color approvalIncomingBubbleDark = Color(0xFF1E293B);
  static const Color approvalInputBgDark = Color(0xFF1E293B);
  static const Color approvalInputBorderDark = Color(0xFF334155);
  static const Color approvalHintDark = Color(0xFF64748B);
  static const Color approvalChatDividerDark = Color(0xFF2A3548);

  static const Color approvalApprovedBgDark = Color(0xFF14532D);
  static const Color approvalApprovedFgDark = Color(0xFF86EFAC);
  static const Color approvalRejectedBgDark = Color(0xFF7F1D1D);
  static const Color approvalRejectedFgDark = Color(0xFFFCA5A5);
  static const Color approvalPendingBgDark = Color(0xFF7C2D12);
  static const Color approvalPendingFgDark = Color(0xFFFDBA74);
}