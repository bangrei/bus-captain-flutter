import 'dart:io';
import 'dart:ui';

import 'package:bc_app/resources/pages/choose_language_page.dart';
import 'package:bc_app/resources/pages/login_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:root_jailbreak_sniffer/rjsniffer.dart';
import 'package:upgrader/upgrader.dart';

class StartingPage extends NyStatefulWidget {
  static const path = '/starting';

  StartingPage({super.key}) : super(path, child: _StartingPageState());
}

class _StartingPageState extends NyState<StartingPage> {
  bool _isFirstAccess = true;
  bool compromised = false;
  bool emulator = false;
  bool debugged = false;

  Upgrader? upgrader;

  @override
  boot() async {
    String langPref = await NyStorage.read<String>('languagePref') ?? 'en';
    upgrader = initializedUpgrader(langPref);
    bool _isFirstAccess = await NyStorage.read<bool>('isFirstAccess') ?? true;

    if (!getEnv('APP_DEBUG')) {
      // Implemented Binary Protection
      compromised = await Rjsniffer.amICompromised() ?? false;
      emulator = await Rjsniffer.amIEmulator() ?? false;
      debugged = await Rjsniffer.amIDebugged() ?? false;
    }
    // print("Is update available = ${upgrader.isUpdateAvailable()}");

    if (!mounted) return;

    if (!_isFirstAccess) {
      Navigator.pushReplacementNamed(context, LoginPage.path);
    }

    if (compromised || emulator || debugged) {
      // print("App compromised! Close app now");
      // SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      // exit(0);
      _showMyDialog();
    }
  }

  /*
  Detect if locale language is detected and the defaul language is either
  English or Simplified Chinese
  */
  bool isDefaultLanguageDetected() {
    Locale deviceLocale = PlatformDispatcher.instance.locale;

    if (deviceLocale.languageCode == 'en') {
      NyStorage.store('languagePref', 'en');
      changeLanguage('en');
      return true;
    } else if (deviceLocale.languageCode == 'zh' &&
        deviceLocale.scriptCode == 'Hans') {
      NyStorage.store('languagePref', 'zh');
      changeLanguage('zh');
      return true;
    }
    return false;
  }

  _onPressed() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setBool('isFirstAccess', false);

    await NyStorage.store('isFirstAccess', false);

    if (!mounted) return;

    if (isDefaultLanguageDetected()) {
      Navigator.pushReplacementNamed(context, LoginPage.path);
    } else {
      Navigator.pushReplacementNamed(context, ChooseLanguagePage.path);
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Security Alert",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
              "We have detected this device is Jailbroken. Please remove Jailbreak to use this app.",
              textScaler: TextScaler.noScaling,
            ),
          actions: [
            TextButton(
              child:
                  const Text('Dismiss', textScaler: TextScaler.noScaling, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              onPressed: () {
                Platform.isIOS
                    ? exit(0)
                    : SystemChannels.platform
                        .invokeMethod('SystemNavigator.pop');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget view(BuildContext context) {
    return UpgradeAlert(
          upgrader: upgrader,
          showReleaseNotes: false,
          showIgnore: false,
          showLater: false,
          child: _isFirstAccess
            ? Scaffold(
              body: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            'public/assets/images/get_started_background.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(30.0),
                          child: Text(
                            'A Journey that Matters.\nMoving People,\nEnhancing\nLifestyles',
                            textScaler: TextScaler.noScaling,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 36.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins-Bold'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: GeneralButton(
                        // Use the GeneralButton widget here
                        text: 'Get Started',
                        onPressed: _onPressed,
                        borderRadius: 10.0, // Set the border radius
                        color: Colors.blue, // Set the button color
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
        );
  }
}
