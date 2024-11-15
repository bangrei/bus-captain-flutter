import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:bc_app/resources/widgets/components/checkbox_widget.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';

class ChooseLanguagePage extends NyStatefulWidget {
  static const path = '/choose-language';

  ChooseLanguagePage({super.key}) : super(path, child: _ChooseLanguagePageState());
}

class _ChooseLanguagePageState extends NyState<ChooseLanguagePage> {
  bool _englishSelected = false;
  bool _chineseSelected = false;

  //Update language and app state upon selection
  updateLanguage() async {
    if (_englishSelected) {
      await NyStorage.store('languagePref','en');
      changeLanguage('en');
    }else if (_chineseSelected) {
      await NyStorage.store('languagePref','zh');
      changeLanguage('zh');
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
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
                  const Text(
                    "Select your preferred language to use Bus Captain Management System (BCMS) easily.",
                    textScaler: TextScaler.noScaling,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w300,
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
                        color: _englishSelected ? ThemeColor.get(context).chosenLanguage : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: ThemeColor.get(context).border,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "English",
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(fontSize: 18.0),
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
                    onTap: () async {
                      setState(() {
                        _englishSelected = false;
                        _chineseSelected = true;
                      });
                      await updateLanguage();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _chineseSelected ? ThemeColor.get(context).chosenLanguage : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: ThemeColor.get(context).border,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "华语",
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(fontSize: 18.0),
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
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: GeneralButton(
                  text: 'Continue',
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, LoginPage.path);
                  },
                  borderRadius: 10.0,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
