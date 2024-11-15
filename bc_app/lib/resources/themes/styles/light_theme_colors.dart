import 'package:flutter/material.dart';
import '/resources/themes/styles/color_styles.dart';

/* Light Theme Colors
|-------------------------------------------------------------------------- */

class LightThemeColors implements ColorStyles {
  // general
  @override
  Color get background => const Color(0xFFFFFFFF);

  @override
  Color get primaryContent => const Color(0xFF000000);
  @override
  Color get primaryAccent => const Color(0xFF0045a0);

  @override
  Color get surfaceBackground => Colors.white;
  @override
  Color get surfaceContent => Colors.black;

  // app bar
  @override
  Color get appBarBackground => Colors.blue;
  @override
  Color get appBarPrimaryContent => Colors.white;

  // buttons
  @override
  Color get buttonBackground => Colors.blueAccent;
  @override
  Color get buttonPrimaryContent => Colors.white;

  // bottom tab bar
  @override
  Color get bottomTabBarBackground => Colors.white;

  // bottom tab bar - icons
  @override
  Color get bottomTabBarIconSelected => Colors.blue;
  @override
  Color get bottomTabBarIconUnselected => Colors.black54;

  // bottom tab bar - label
  @override
  Color get bottomTabBarLabelUnselected => Colors.black45;
  @override
  Color get bottomTabBarLabelSelected => Colors.black;

  @override
  Color get backButtonIcon => Colors.blue;

  @override
  Color get cardBg => const Color(0xFFF6F6F5);

  @override
  Color get selected => const Color(0xFFE4F0F1);

  @override
  Color get drivingLicenseLabel => const Color(0xFF423C3C);

  @override
  Color get sectionDivider => const Color(0xFFF6F6F6);

  @override
  Color get helpPageIcon => const Color(0xFF1A0F91);

  @override
  Color get fileContainer => const Color(0xFFF8FAFE);

  @override
  Color get fileSize => const Color(0xFF71839B);

  @override
  Color get inputBoxReadOnly => const Color(0xFFF4F5F6);

  @override
  Color get inputBoxNormal => Colors.white;

  @override
  Color get photoPickerBox => const Color(0xFFFAFAFA);

  @override
  Color get hintText => const Color(0xFF666666);

  @override
  Color get chosenLanguage => const Color(0xFFF4F5F6);

  @override
  Color get border => const Color(0xFFD8DADC);

  @override
  Color get otpBoxEmpty => const Color(0xFFF7F7F7);
  
  @override
  Color get otpBoxNotEmpty => Colors.white;

  @override
  Color get entitlementBox => const Color(0xFFE4F0F1);

  @override
  Color get uniformCancelButton => const Color(0xFF566789);

  @override
  Color get myBoxDecorationLine => Colors.black26;

  @override
  Color get arrowEnd => Colors.grey;

  @override
  Color get arrowNotEnd => Colors.black;

  @override
  Color get messageCategoryContainer => const Color(0xFF232323).withOpacity(0.1);
}
