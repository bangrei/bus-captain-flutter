import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AboutPage extends NyStatefulWidget {
  static const path = '/about';
  
  AboutPage({super.key}) : super(path, child: _AboutPageState());
}

class _AboutPageState extends NyState<AboutPage> {
  String appVersion='';
  @override
  init() async {
    appVersion = await getAppVersion();
  }
  
  /// Use boot if you need to load data before the [view] is rendered.
  // @override
  // boot() async {
  //
  // }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: TitleBar(title: "about_page.title".tr()),
      body: SafeArea(
         child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Image(image:AssetImage('public/assets/images/SMRT_logo.png')),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 33),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black
                    ),
                    children: <TextSpan> [
                      TextSpan(
                        text: 
                        "about_page.description1".tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ThemeColor.get(context).primaryContent
                        )
                      ),
                      TextSpan(
                        text: "about_page.description2".tr(),
                        style: TextStyle(color: nyHexColor("#8F8F8F"))
                      ),
                      const TextSpan(text: "\n\n"),
                      TextSpan(
                        text: "about_page.description3".tr(),
                        style: TextStyle(color: nyHexColor("#8F8F8F"))
                      )
                    ]
                  )
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 33),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Image(image: AssetImage('public/assets/images/Solo_logo.png'), width: 130),
                    // const SizedBox(width: 50),
                    Text(
                      "about_page.version".tr(arguments: {"version_num": appVersion}),
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(color: nyHexColor("#8F8F8F")))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
