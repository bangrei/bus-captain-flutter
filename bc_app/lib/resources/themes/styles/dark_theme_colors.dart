import 'package:flutter/material.dart';
import '/resources/themes/styles/color_styles.dart';

/* Dark Theme Colors
|-------------------------------------------------------------------------- */

class DarkThemeColors implements ColorStyles {
  // general
  @override
  Color get background => Colors.black;

  @override
  Color get primaryContent => const Color(0xFFE1E1E1);
  @override
  Color get primaryAccent => const Color(0xFF9999aa);

  @override
  Color get surfaceBackground => Colors.white30;
  @override
  Color get surfaceContent => Colors.black;

  // app bar
  @override
  Color get appBarBackground => const Color(0xFF4b5e6d);
  @override
  Color get appBarPrimaryContent => Colors.white;

  // buttons
  @override
  Color get buttonBackground => Colors.white60;
  @override
  Color get buttonPrimaryContent => const Color(0xFF232c33);

  // bottom tab bar
  @override
  Color get bottomTabBarBackground => const Color(0xFF232c33);

  // bottom tab bar - icons
  @override
  Color get bottomTabBarIconSelected => Colors.white70;
  @override
  Color get bottomTabBarIconUnselected => Colors.white60;

  // bottom tab bar - label
  @override
  Color get bottomTabBarLabelUnselected => Colors.white54;
  @override
  Color get bottomTabBarLabelSelected => Colors.white;

  @override
  Color get backButtonIcon => Colors.white70;

  @override
  Color get cardBg => Colors.white12;

  @override
  Color get selected => const Color(0xFF7A7A7B);

  @override
  Color get drivingLicenseLabel => Colors.white;

  @override
  Color get sectionDivider => const Color(0xFF161616);

  @override
  Color get helpPageIcon => const Color(0xFFA39FD3);

  @override
  Color get fileContainer => const Color(0xFF636465);

  @override
  Color get fileSize => const Color(0xFFC6CDD7);

  @override
  Color get inputBoxReadOnly => const Color(0xFF333333);

  @override
  Color get inputBoxNormal => const Color(0xFF333333);

  @override
  Color get photoPickerBox => const Color(0xFF121212);

  @override
  Color get hintText => const Color(0xFF939393);

  @override
  Color get chosenLanguage => const Color(0xFF171717);

  @override
  Color get border => const Color(0xFF2F3234);

  @override
  Color get otpBoxEmpty => const Color(0xFF333333);
  
  @override
  Color get otpBoxNotEmpty => const Color(0xFF0D0D0D);

  @override
  Color get entitlementBox => const Color(0xFF172A2C);

  @override
  Color get uniformCancelButton => Colors.white;

  @override
  Color get myBoxDecorationLine => Colors.white30;

  @override
  Color get arrowEnd => Colors.black; 

  @override
  Color get arrowNotEnd => Colors.grey;

  @override
  Color get messageCategoryContainer => const Color(0xFF232323).withOpacity(0.7);
}
