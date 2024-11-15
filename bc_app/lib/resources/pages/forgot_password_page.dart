import 'dart:convert';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/resources/pages/otp_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:bc_app/resources/widgets/components/input_text_widget.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ForgotPasswordPage extends NyStatefulWidget {
  static const path = '/forgot-password';

  ForgotPasswordPage({super.key})
      : super(path, child: _ForgotPasswordPageState());
}

class _ForgotPasswordPageState extends NyState<ForgotPasswordPage> {
  final idController = TextEditingController();
  final mobileController = TextEditingController();
  bool processing = false;
  ApiController apiController = ApiController();
  String countryCode = '';

  @override
  void dispose() {
    super.dispose();
    idController.dispose();
    mobileController.dispose();
  }

  void _updateCountryCode(String data) {
    countryCode = data;
  }

  void getOTP(BuildContext context) async {
    if (processing) return;
    setState(() => processing = true);
    final res = await apiController.onForgotPasswordOTP(
      idController.text,
      countryCode + mobileController.text,
    );
    setState(() => processing = false);
    final json = jsonDecode(res);
    if (!json['success']) {
      return showSnackBar(
        context,
        json['message'] ?? "Something went wrong!",
        isSuccess: false,
      );
    }

    final data = {
      "username": idController.text,
      "password": countryCode + mobileController.text,
      "maskedMobile": json['maskedMobile'],
      "auth": json['auth'],
      "forgotPassword": true,
    } as Map;
    
    routeTo(
      OtpPage.path,
      data: data,
    );
  }

  @override
  init() async {
    processing = false;
  }

  /// Use boot if you need to load data before the [view] is rendered.
  // @override
  // boot() async {
  //
  // }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
        appBar: TitleBar(title: "forgot_password_screen.title".tr()),
        body: SafeArea(
          child: SingleChildScrollView(
            child: MasterLayout(
                child: Column(
                children: [
                  Text(
                    "forgot_password_screen.subtitle1".tr(),
                    textScaler: TextScaler.noScaling,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 14.56, color: nyHexColor("8F8F8F")),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "forgot_password_screen.subtitle2".tr(),
                    textScaler: TextScaler.noScaling,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 14.56, color: nyHexColor("8F8F8F")),
                  ),
                  const SizedBox(height: 37.0),
                  InputText(
                    label: 'forgot_password_screen.employee id'.tr(),
                    controller: idController,
                  ),
                  InputText(
                    label: 'forgot_password_screen.mobile number'.tr(),
                    controller: mobileController,
                    type: TextInputType.phone,
                    onCountryCodeChange: _updateCountryCode
                  ),
                  Text(
                    "forgot_password_screen.warning message".tr(),
                    textScaler: TextScaler.noScaling,
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 15, color: Colors.redAccent),
                  )
                ],
              )
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
                  text: "forgot_password_screen.button".tr(),
                  onPressed: () {
                    getOTP(context);
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
        ));
  }
}
