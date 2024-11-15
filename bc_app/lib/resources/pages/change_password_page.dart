import 'dart:convert';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/resources/pages/welcome_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:bc_app/resources/widgets/components/input_text_form_widget.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ChangePasswordPage extends NyStatefulWidget {
  static const path = '/change-password';

  ChangePasswordPage({super.key})
      : super(path, child: _ChangePasswordPageState());
}

class _ChangePasswordPageState extends NyState<ChangePasswordPage> {
  @override
  init() async {}

  /// Use boot if you need to load data before the [view] is rendered.
  @override
  boot() async {

  }

  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool processing = false;
  ApiController apiController = ApiController();

  final _formKey = GlobalKey<FormState>();

  _validationMinMax(String value, int length, String rules) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    if (rules == 'min' && value.length < length) {
      return "password_warning_label.minimum characters".tr();
    }
    if (rules == 'max' && value.length > length) {
      return 'Must be a minimum of 6 characters.';
    }
    return null;
  }

  _validationMatchOrNot(String value, String compareValue, String rules) {
    if (value == null || value.isEmpty) {
      return "password_warning_label.enter value".tr();
    }
    if (rules == 'match' && value != compareValue) {
      return "password_warning_label.not match".tr();
    }
    if (rules == 'notmatch' && value == compareValue) {
      return "password_warning_label.different password".tr();
    }
    return null;
  }

  void handleSubmit() async {
    if (processing) return;
    setState(() => processing = true);
    final res = await apiController.onChangeMyPassword(
        _currentPassController.text,
        _newPassController.text,
        _confirmPassController.text);
    setState(() => processing = false);
    final json = jsonDecode(res);
    String message = json['message'] ?? '';
    if (!json['success']) {
      message = "Something went wrong! $message";
    } else if (message.isEmpty) {
      message = "Password is successfully changed!";
    }
    showSnackBar(
      context,
      message,
      isSuccess: json['success'],
    );
    if (json['success']) routeTo(WelcomePage.path);
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: const TitleBar(),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: MasterLayout(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Transform.scale(
                scale: 1.3, // Adjust the scale as needed
                child: Image.asset(
                  'public/assets/images/change_password_icon.png',
                  height: 100.0,
                ),
              ),
              const SizedBox(height: 40.0),
              Text(
                "user_profile.change_password_screen.title".tr(),
                textScaler: TextScaler.noScaling,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins-Bold",
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                "user_profile.change_password_screen.subtitle".tr(),
                textScaler: TextScaler.noScaling,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14.56,
                ),
              ),
              const SizedBox(height: 37.0),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    InputTextForm(
                      controller: _currentPassController,
                      label:
                          'user_profile.change_password_screen.current password'
                              .tr(),
                      type: TextInputType.visiblePassword,
                      keyboardType: TextInputType.number,
                      validator: (value) => _validationMinMax(value, 6, 'min'),
                      onChanged: (text) {
                        setState(() {});
                      },
                    ),
                    InputTextForm(
                        controller: _newPassController,
                        label:
                            'user_profile.change_password_screen.new password'
                                .tr(),
                        type: TextInputType.visiblePassword,
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            _validationMinMax(value, 6, 'min') ??
                            _validationMatchOrNot(
                                value, _currentPassController.text, 'notmatch'),
                        onChanged: (text) {
                          setState(() {});
                        }),
                    InputTextForm(
                        controller: _confirmPassController,
                        label:
                            'user_profile.change_password_screen.confirm new password'
                                .tr(),
                        type: TextInputType.visiblePassword,
                        keyboardType: TextInputType.number,
                        validator: (value) => _validationMatchOrNot(
                            value, _newPassController.text, 'match')),
                  ],
                ),
              ),
            ],
          )),
        ),
      ),
      bottomNavigationBar: MasterLayout(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: GeneralButton(
                  text: 'user_profile.change_password_screen.button'.tr(),
                  showLoading: processing == true,
                  disabled: processing == true,
                  onPressed: () {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, display a snackbar. In the real world,
                      handleSubmit();
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
