import 'dart:convert';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:bc_app/resources/widgets/components/checkbox_widget.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';

class SettingsChooseLanguagePage extends NyStatefulWidget {
  static const path = '/settings-choose-language';

  SettingsChooseLanguagePage({super.key}) : super(path, child: _SettingsChooseLanguagePageState());
}

class _SettingsChooseLanguagePageState extends NyState<SettingsChooseLanguagePage> {
  bool _englishSelected = false;
  bool _chineseSelected = false;

  String langPref = '';
  bool onLoading = false;
  ApiController apiController = ApiController();

  @override
  init() async {

  }
  
  /// Use boot if you need to load data before the [view] is rendered.
  @override
  boot() async{
    String deviceLang = await NyStorage.read<String>('languagePref')?? '';
    setState(() {
      langPref = deviceLang;

      _englishSelected = langPref == 'en';
      _chineseSelected = langPref == 'zh';
    });
  }
  
  //Update language and app state upon selection
  updateLanguage() async{
    String langPref = "";

    if (_englishSelected) langPref = 'en';
    if (_chineseSelected) langPref = 'zh';
    // Update backend
    setState(() => onLoading = true);
    final res = await apiController.updateLanguagePref(langPref: langPref);
    final json = jsonDecode(res);
    setState(() => onLoading = false);
    bool success = json.isEmpty ? false : json['success'] == true;

    if (!success) {
      showSnackBar(
        context,
        json.isEmpty ? 'Network connection issue!' : json['message'],
        isSuccess: false,
      );
    }

    // Update device app local
    await NyStorage.store('languagePref',langPref);
    await changeLanguage(langPref);
    return;
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: const TitleBar(),
      body: SafeArea(
        child: Stack(
          children: [
            MasterLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20.0),
                  const Text(
                    "Choose Your Language",
                    textScaler: TextScaler.noScaling,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins-Bold",
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    "Select your preferred language to use Bus Captain Management System (BCMS) easily.",
                    textScaler: TextScaler.noScaling,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w300,
                      color: nyHexColor("#8F8F8F")
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        _englishSelected = true;
                        _chineseSelected = false;
                      });
                      await updateLanguage();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _englishSelected ? ThemeColor.get(context).chosenLanguage  : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: ThemeColor.get(context).border,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "English",
                                  textScaler: TextScaler.noScaling,
                                  style: TextStyle(fontSize: 18.0),
                                ),
                              ),
                            ],
                          ),
                          GeneralCheckbox(
                            value: _englishSelected,
                            onChanged: (value) async {
                              setState(() {
                                _englishSelected = value ?? false;
                                _chineseSelected = !(value ?? false);
                              });
                              await updateLanguage();
                            },
                            color: Colors.blue,
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  GestureDetector(
                    onTap: () async{
                      setState(() {
                        _englishSelected = false;
                        _chineseSelected = true;
                      });
                      await updateLanguage();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _chineseSelected ? ThemeColor.get(context).chosenLanguage  : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: ThemeColor.get(context).border,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "华语",
                                  textScaler: TextScaler.noScaling,
                                  style: TextStyle(fontSize: 18.0),
                                ),
                              ),
                            ],
                          ),
                          GeneralCheckbox(
                            value: _chineseSelected,
                            onChanged: (value) async {
                              setState(() {
                                _englishSelected = !(value ?? false);
                                _chineseSelected = value ?? false;
                              });
                              await updateLanguage();
                            },
                            color: Colors.blue,
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40.0),
                ],
              ),
            ),
            // Positioned(
            //   bottom: 0,
            //   left: 0,
            //   right: 0,
            //   child: Padding(
            //     padding: const EdgeInsets.all(30.0),
            //     child: GeneralButton(
            //       text: 'Continue',
            //       onPressed: () {
            //         Navigator.pushReplacementNamed(context, '/login');
            //       },
            //       borderRadius: 10.0,
            //       color: Colors.blue,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
