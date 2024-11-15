import 'dart:async';
import 'dart:convert';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/user.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/reset_password_page.dart';
import 'package:bc_app/resources/pages/welcome_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';
import 'package:bc_app/resources/widgets/components/otp_text_field_widget.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class OtpPage extends NyStatefulWidget {
  static const path = '/otp';

  OtpPage({super.key}) : super(path, child: _OtpPageState());
}

class _OtpPageState extends NyState<OtpPage> {
  List<TextEditingController?> _controllers =
      List.generate(6, (_) => TextEditingController(text: ""));
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String username = '';
  String password = '';
  String maskedMobile = '';
  String auth = '';
  int isFirstSuccessfulLogin = 0; // Boolean Flag
  bool forgotPassword = false;
  bool processing = false;

  ApiController apiController = ApiController();

  Timer? _timer;
  int _countdown = 30;
  bool _canResend = true;

  @override
  init() async {
    final data = widget.data();
    if (data.isNotEmpty) {
      setState(() {
        username = data['username'];
        password = data['password'];
        maskedMobile = data['maskedMobile'];
        auth = data['auth'];
        if (data['forgotPassword'] ?? false) forgotPassword = true;
      });
    }
  }

  void startCountdown() {
    setState(() {
      _canResend = false;
      _countdown = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        setState(() {
          _canResend = true;
          _timer?.cancel();
        });
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  void resendOTP(BuildContext context) async {
    if (processing) return;
    setState(() => processing = true);
    if (forgotPassword) {
      final res = await apiController.onForgotPasswordOTP(
        username,
        password,
      );
      setState(() => processing = false);
      final json = jsonDecode(res);
      final msg = json['message'];
      setState(() {
        maskedMobile = json['maskedMobile'];
        auth = json['auth'];
      });
      showSnackBar(
        context,
        "Resent! $msg",
      );
    } else {
      final res = await apiController.onLoginOTP(
        username,
        password,
      );
      setState(() => processing = false);
      final json = jsonDecode(res);
      final msg = json['message'];
      setState(() {
        maskedMobile = json['maskedMobile'];
        auth = json['auth'];
      });
      showSnackBar(
        context,
        "Resent! $msg",
      );
      startCountdown();
    }
  }

  void doVerify(BuildContext context) async {
    if (processing) return;
    setState(() => processing = true);
    String otp = '';
    for (var controller in _controllers) {
      otp += controller!.text;
    }
    if (otp.length != 6) {
      setState(() => processing = false);
      return showSnackBar(context, 'otp_screen.alert message'.tr(),
          isSuccess: false);
    }

    if (forgotPassword) {
      final res = await apiController.onVerifyForgotPassword(
        username,
        otp,
        auth,
      );
      setState(() => processing = false);
      final json = jsonDecode(res);
      if (!json['success']) {
        return showSnackBar(
          context,
          json['message'],
          isSuccess: false,
        );
      }
      final data = {
        "otp": otp,
        "employeeID": username,
        "auth": auth,
      } as Map;
      _timer?.cancel();
      routeTo(ResetPasswordPage.path, data: data);
    } else {
      final res = await apiController.onVerifyLogin(
        username,
        otp,
        auth,
      );
      setState(() => processing = false);
      final json = jsonDecode(res);
      if (!json['success']) {
        showSnackBar(
          context,
          json['message'],
          isSuccess: false,
        );
        if (json['returnLogin'] == true) {
          Navigator.pop(context);
        }
        return;
      }
      _timer?.cancel();
      await NyStorage.store('authToken', json['token'])
      .then((value) async {
        // Let Nylo know that user is authenticated
        // can make use the authPage:True functionality for routing
        User user = User();
        await Auth.set(user)
        .then((value) {
          configureUserLanguage(json['langPref'] ?? '', json);
        });
      });
    }
  }

  void configureUserLanguage(String userLangPref, dynamic json) async{
    // Set saved language preference, if applicable
    String langPref = userLangPref ?? '';
    if (langPref.isNotEmpty) {
      await NyStorage.store('languagePref', langPref);
      await changeLanguage(langPref);
      Navigator.pushNamedAndRemoveUntil(context, WelcomePage.path, (route)=>false);
      return;
    }

      // If it's new user, usually language pref hasn't been updated to backend
      // Let's save the local pref to db instead
      String localLangPref = await NyStorage.read<String>("languagePref") ?? 'en';
      
      final res2 = await apiController.updateLanguagePref(langPref: localLangPref, token: json['token']);
      final json2 = jsonDecode(res2);
      bool success = json2.isEmpty ? false : json2['success'] == true;

    if (!success) {
      showSnackBar(
        context,
        json2.isEmpty ? 'Network connection issue!' : json2['message'],
        isSuccess: false,
      );
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, WelcomePage.path, (route)=>false);
    return;
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      // controller!.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: const TitleBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: MasterLayout(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Transform.scale(
                  scale: 1.3, // Adjust the scale as needed
                  child: Image.asset(
                    'public/assets/images/otp_icon.png',
                    height: 100.0,
                  ),
                ),
                const SizedBox(height: 40.0),
                Text(
                  "otp_screen.title".tr(),
                  textScaler: TextScaler.noScaling,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins-Bold",
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  "otp_screen.subtitle".tr(),
                  textScaler: TextScaler.noScaling,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  maskedMobile,
                  textScaler: TextScaler.noScaling,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontFamily: "Poppins-Bold",
                  ),
                ),
                const SizedBox(height: 40.0),
                OtpTextField(
                  numberOfFields: 6,
                  contentPadding: EdgeInsets.zero,
                  alignment: Alignment.topCenter,
                  borderColor: Colors.black,
                  showFieldAsBox: true,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  filled: true,
                  fillColor: ThemeColor.get(context).otpBoxNotEmpty,
                  focusedBorderColor: Colors.blue,
                  enabledBorderColor: ThemeColor.get(context).border,
                  // disabledBorderColor: ThemeColor.get(context).otpBoxEmpty,
                  borderWidth: 2.0,
                  handleControllers: (controllers) => _controllers = controllers,
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: List.generate(6, (index) {
                //     return Container(
                //       width: 40.0,
                //       height: 40.0,
                //       decoration: BoxDecoration(
                //         color: _controllers[index].text.isEmpty
                //             ? ThemeColor.get(context).otpBoxEmpty
                //             : ThemeColor.get(context).otpBoxNotEmpty,
                //         border: Border.all(
                //           color: _controllers[index].text.isEmpty
                //               ? ThemeColor.get(context).border
                //               : Colors.blue,
                //           width: 2.5,
                //         ),
                //         borderRadius: BorderRadius.circular(5.0),
                //       ),
                //       child: Container(
                //         alignment: Alignment.center,
                //         height: double.infinity,
                //         child: TextFormField(
                //           controller: _controllers[index],
                //           focusNode: _focusNodes[index],
                //           maxLength: 1,
                //           keyboardType: TextInputType.number,
                //           textAlign: TextAlign.center,
                //           decoration: const InputDecoration(
                //             contentPadding: EdgeInsets.symmetric(
                //                 vertical:
                //                     14.0), // Adjust the vertical padding here
                //             counterText: '',
                //             border: InputBorder.none,
                //           ),
                //           style: TextStyle(
                //             color: _controllers[index].text.isEmpty
                //                 ? Colors.grey
                //                 : ThemeColor.get(context).primaryContent,
                //             fontFamily: 'Poppins-Bold',
                //             fontSize: 14,
                //           ),
                //           onChanged: (value) {
                //             if (value.isNotEmpty && index < 5) {
                //               FocusScope.of(context)
                //                   .requestFocus(_focusNodes[index + 1]);
                //             } else if (value.isEmpty && index > 0) {
                //               FocusScope.of(context)
                //                   .requestFocus(_focusNodes[index - 1]);
                //             }
                //             if (index == 5) {
                //               FocusManager.instance.primaryFocus?.unfocus();
                //             }
                //             setState(() {}); // Update the UI
                //           },
                //           onTapOutside: (PointerDownEvent event) {
                //             FocusManager.instance.primaryFocus?.unfocus();
                //           },
                //         ),
                //       ),
                //     );
                //   }),
                // ),
                const SizedBox(height: 30.0),
                _canResend
                    ? Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "otp_screen.resend otp".tr(),
                              style: const TextStyle(fontSize: 16.0),
                            ),
                            TextSpan(
                              text: "otp_screen.resend label".tr(),
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  resendOTP(context);
                                },
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      )
                    : Center(
                        child: Text(
                            "otp_screen.otp downtime".tr(
                                arguments: {"timer": _countdown.toString()}),
                            textScaler: TextScaler.noScaling,
                            style: const TextStyle(color: Colors.blue)),
                      ),
                const SizedBox(height: 40.0),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: MasterLayout(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: GeneralButton(
                text: "otp_screen.button".tr(),
                showLoading: processing == true,
                disabled: processing == true,
                onPressed: () {
                  doVerify(context);
                },
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
    );
  }
}
