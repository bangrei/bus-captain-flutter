import 'package:bc_app/resources/pages/about_page.dart';
import 'package:bc_app/resources/pages/settings_choose_language_page.dart';
import 'package:bc_app/resources/widgets/components/section_divider_widget.dart';
import 'package:bc_app/resources/widgets/components/section_header_widget.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class SettingsPage extends NyStatefulWidget {
  static const path = '/settings';
  
  SettingsPage({super.key}) : super(path, child: _SettingsPageState());
}

class _SettingsPageState extends NyState<SettingsPage> {
  bool isSwitchOn = false;

  @override
  init() async {

  }
  
  /// Use boot if you need to load data before the [view] is rendered.
  @override
  boot() async {
    String langPref = await NyStorage.read<String>('languagePref') ?? '';
    changeLanguage(langPref); 
  }
  
  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: TitleBar(
        title: "settings_page.title".tr(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height:10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(icon: Icons.settings,sectionName: "settings_page.title".tr()),
                    const SizedBox(height: 20),
                    ListTile(
                      title: Text(
                        "settings_page.change language".tr(),
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          fontFamily: "Poppins-Bold",
                          fontSize: 16,
                          fontWeight: FontWeight.w600
                        ),
                      
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: nyHexColor("#ABABAB")
                      ),
                      onTap: () => {
                        Navigator.pushNamed(context, SettingsChooseLanguagePage.path)
                      } ,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left:15),
                      child: Text("settings_page.lang".tr(), textScaler: TextScaler.noScaling,),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
              const SectionDivider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical:20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(icon: Icons.lock,sectionName: "settings_page.security".tr()),
                    const SizedBox(height: 20),
                    ListTile(
                      title: Text(
                        "settings_page.enable face id".tr(),
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          fontFamily: "Poppins-Bold",
                          fontSize: 16,
                          fontWeight: FontWeight.w600
                        ),
                      
                      ),
                      trailing: SizedBox(
                        height: 32,
                        child: FittedBox(
                          fit: BoxFit.fill,
                          child: Switch(
                            value: isSwitchOn, 
                            onChanged: (value) {
                              setState(() {
                                isSwitchOn = value;
                              });
                            }
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 250,
                      child: Padding(
                        padding: const EdgeInsets.only(left:15),
                        child: Text("settings_page.enable face id description".tr(), textScaler: TextScaler.noScaling,),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
              const SectionDivider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ListTile(
                  title: Text(
                    "settings_page.about".tr(),
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      fontFamily: "Poppins-Bold",
                      fontSize: 16,
                      fontWeight: FontWeight.w600
                    ),
                  
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: nyHexColor("#ABABAB")
                  ),
                  onTap: () => {
                    Navigator.pushNamed(context, AboutPage.path)
                  } ,
                ),
              ),
              const SectionDivider(),
            ],
          )
        )
      )
    );
  }
}
