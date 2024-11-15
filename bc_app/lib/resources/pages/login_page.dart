import 'dart:convert';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/config/constants.dart';
import 'package:bc_app/resources/pages/forgot_password_page.dart';
import 'package:bc_app/resources/pages/otp_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:bc_app/resources/widgets/components/input_text_widget.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:upgrader/upgrader.dart';

class LoginPage extends NyStatefulWidget {
  static const path = '/login';

  LoginPage({super.key}) : super(path, child: _LoginPageState());
}

class _LoginPageState extends NyState<LoginPage> {
  bool? _rememberMe = false; // Track the state of the "Remember Me" checkbox
  final bool _enableFaceId =
      false; // Track the state of the "Enable Face ID" switch
  bool processing = false;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  ApiController apiController = ApiController();

  Upgrader? upgrader;

  @override
  init() async {
    // Add initialization logic here
  }

  @override
  boot() async {
    // Initialize pref language, in case user start from this page.
    String langPref = await NyStorage.read<String>('languagePref') ??
        Constants.defaultLanguage;
    changeLanguage(langPref);

    upgrader = initializedUpgrader(langPref);

    //Set Remember me result
    bool isRememberMe = await NyStorage.read<bool>('rememberMe') ?? false;
    setState(() {
      _rememberMe = isRememberMe;
    });

    if (_rememberMe!) {
      String savedUsername =
          await NyStorage.read<String>('savedUsername') ?? '';
      setState(() {
        usernameController.text = savedUsername;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    usernameController.dispose();
    passwordController.dispose();
  }

  void doLogin(BuildContext context) async {
    if (processing) return;
    setState(() => processing = true);
    final res = await apiController.onLoginOTP(
      usernameController.text,
      passwordController.text,
    );
    setState(() => processing = false);
    final json = jsonDecode(res);
    final message = json['message'];
    if (!json['success']) {
      return showSnackBar(
        context,
        "Something went wrong! $message",
        isSuccess: false,
      );
    }
    final data = {
      "username": usernameController.text,
      "password": passwordController.text,
      "maskedMobile": json['maskedMobile'],
      "auth": json['auth'],
    } as Map;

    // Saved info
    if (_rememberMe!) {
      _saveInfo();
    } else {
      _removeInfo();
    }

    routeTo(
      OtpPage.path,
      data: data,
    );
  }

  _saveInfo() {
    NyStorage.store('rememberMe', true);
    NyStorage.store('savedUsername', usernameController.text);
  }

  _removeInfo() {
    NyStorage.delete('rememberMe');
    NyStorage.delete('savedUsername');
  }

  void goToForgotPasswordPage() {
    if (processing) return;
    routeTo(ForgotPasswordPage.path);
  }

  @override
  Widget view(BuildContext context) {
    return UpgradeAlert(
      upgrader: upgrader,
      showReleaseNotes: false,
      showIgnore: false,
      showLater: false,
      child: Scaffold(
        resizeToAvoidBottomInset:
            true, // Set to true to avoid the keyboard covering the UI
        body: SafeArea(
          child: SingleChildScrollView(
            child: MasterLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('public/assets/images/SMRT_logo.png', height: 60.0),
                  const SizedBox(height: 20.0),
                  const Text(
                    "BUS CAPTAIN MANAGEMENT SYSTEM",
                    textScaler: TextScaler.noScaling,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins-Bold",
                      color: Color(0xFFA08D47),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    "login_screen.welcome".tr(),
                    textScaler: TextScaler.noScaling,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins-Bold",
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  InputText(
                    label: 'login_screen.username'.tr(),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    placeholder: "login_screen.enter your employee ID".tr(),
                    type: TextInputType.number,
                    controller: usernameController,
                    value: usernameController.text ?? '',
                  ),
                  const SizedBox(height: 20.0),
                  InputText(
                    label: 'login_screen.password'.tr(),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    placeholder: "login_screen.enter your password".tr(),
                    type: TextInputType.visiblePassword,
                    controller: passwordController,
                  ),
                  const SizedBox(
                      height:
                          20.0), // Add some space between the password field and the checkbox
                  Row(
                    children: [
                      SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value;
                            });
                          },
                          activeColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ), // Add a small amount of space between the checkbox and the text
                      Text('login_screen.remember me'.tr(), textScaler: TextScaler.noScaling,),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: MasterLayout(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row(
              //   children: [
              //     Expanded(
              //       child: Text('Enable Face ID'),
              //     ),
              //     Transform.scale(
              //       scale: 0.8, // Adjust the scale factor as needed
              //       child: Switch(
              //         value: _enableFaceId,
              //         onChanged: (value) {
              //           setState(() {
              //             _enableFaceId = value;
              //           });
              //         },
              //         activeTrackColor: Colors.blue,
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(
                width: double.infinity, // Make the container take full width
                child: GeneralButton(
                  text: 'login_screen.button'.tr(),
                  disabled: processing == true,
                  showLoading: processing == true,
                  onPressed: () {
                    doLogin(context);
                  },
                  borderRadius: 10.0,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 10.0),
              GestureDetector(
                onTap: () {
                  goToForgotPasswordPage();
                },
                child: Text(
                  "login_screen.forgot password".tr(),
                  textScaler: TextScaler.noScaling,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              const Text(
                "© 2024 - SMRT Corporation Ltd.",
                textScaler: TextScaler.noScaling,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
