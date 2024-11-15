import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/events/login_event.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/config/constants.dart';
import 'package:bc_app/resources/pages/home_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:upgrader/upgrader.dart';

class WelcomePage extends NyStatefulWidget {
  static const path = '/welcome';

  WelcomePage({super.key}) : super(path, child: _WelcomePageState());
}

class _WelcomePageState extends NyState<WelcomePage> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  bool onLoading = false;
  ApiController apiController = ApiController();

  List<Map<String, dynamic>> pages = [];

  Upgrader? upgrader;

  _initData(String langPref) {
    setState(() {
      pages = [
        {
          'logo': 'public/assets/images/SMRT_logo.png',
          'image': 'public/assets/images/Safety${langPref.capitalize()}.png',
          'imageWidth':200.0,
          'imageHeight': 200.0,
          'subTitle1': 'welcome_screen.safety subtitle1'.tr(),
          'subTitle2': 'welcome_screen.safety subtitle2'.tr(),
          'subTitle3': 'welcome_screen.safety subtitle3'.tr(),
          'subtitleFontSize': 25.0,
          'subsubTitle': 'welcome_screen.safety message'.tr(),
          'message': null,
        },
        {
          'logo': 'public/assets/images/SMRT_logo.png',
          'image': 'public/assets/images/Security${langPref.capitalize()}.png',
          'imageWidth':double.infinity,
          'imageHeight': 99.0,
          'subTitle1': 'welcome_screen.security subtitle1'.tr(),
          'subTitle2': 'welcome_screen.security subtitle2'.tr(),
          'subTitle3': 'welcome_screen.security subtitle3'.tr(),
          'subtitleFontSize': 25.0,
          'subsubTitle': 'welcome_screen.security message'.tr(),
          'message': null,
        

        }
      ];
    });
  }

  @override
  init() async {}

  @override
  boot() async {
     // Initialize pref language, in case user start from this page.
    String langPref = await NyStorage.read<String>('languagePref') ?? Constants.defaultLanguage;
    await changeLanguage(langPref);

    _initData(langPref);
    await _fetchMessages(langPref);
    // RUN CRON only for logged in users:
    await event<LoginEvent>(data: {"runCronJob": true});

    // print(pages[0]);

    upgrader = initializedUpgrader(langPref);
  }

  _fetchMessages(String langPref) async {
    setState(() => onLoading = true);
    final Map<String,dynamic> ssm = await apiController.getSSM(context: context);
    setState(() => onLoading = false);
    setState(() {
      pages[0]['message'] = ssm["safety$langPref"];
      pages[1]['message'] = ssm["security$langPref"];
    });

  }

  @override
  Widget view(BuildContext context) {
    return UpgradeAlert(
      upgrader: upgrader,
      showReleaseNotes: false,
      showIgnore: false,
      showLater: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF619865),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  children: [
                    _buildPage(1),
                    _buildPage(2),
                  ],
                ),
              ),
              // Container(
              //   color: ThemeColor.get(context).background,
              //   child: _buildIndicator(),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    
    var page = pages[index - 1]; // Adjust index to be 0-based
    double height = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                // padding: const EdgeInsets.all(16.0),
                // height: 0.6*height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        page['logo'],
                        width: 300, // Adjust the width as needed
                        height: 100, // Adjust the height as needed
                      ),
                    ),
                    // const SizedBox(height: 16.0),
                    // Center(
                    //   child: Text(
                    //     page['title'],
                    //     textAlign: TextAlign.center,
                    //     style: const TextStyle(
                    //       fontSize: 24.0,
                    //       fontWeight: FontWeight.bold,
                    //       color: Colors.white,
                    //       fontFamily: 'Poppins-Bold',
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 16.0),
                    Padding(
                      padding: EdgeInsets.zero,
                      child: Center(
                        child: SizedBox(
                          width: page['imageWidth'],
                          height: page['imageHeight'], // Assuming 16:9 aspect ratio
                          child: Image.asset(
                            page['image'],
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Center(
                      child: Text(
                        page['subTitle1'],
                        textScaler: TextScaler.noScaling,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: page['subtitleFontSize'],
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins-Bold',
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Center(
                      child: Text(
                        page['subTitle2'],
                        textScaler: TextScaler.noScaling,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: page['subtitleFontSize'],
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins-Bold',
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Center(
                      child: Text(
                        page['subTitle3'],
                        textScaler: TextScaler.noScaling,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: page['subtitleFontSize'],
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins-Bold',
                          color: Colors.black,
                        ),
                      ),
                    ),
                    // const SizedBox(height: 8.0),
                  ],
                ),
              ),
              Container(
                height: 0.3*height,
                color: ThemeColor.get(context).background,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      page['subsubTitle']?? '',
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontFamily: 'Poppins-Bold',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA08D47),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Expanded(
                      // decoration: BoxDecoration(
                      //   border: Border.all(color: Colors.white,width: 1)
                      // ),
                      child: Text(
                        page['message']?? '',
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: ThemeColor.get(context).primaryContent,
                        ),
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: _buildIndicator()
                        ),
                        index == 2
                          ? Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamedAndRemoveUntil(context, HomePage.path, (route) => false);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'welcome_screen.home'.tr(),
                                      textScaler: TextScaler.noScaling,
                                      style: TextStyle(
                                        color: ThemeColor.get(context).primaryContent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: ThemeColor.get(context).primaryContent,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          : const SizedBox(height: 50),
                      ]
                    )
                  ],
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }

  Widget _buildIndicator() {
    return  MasterLayout(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCircle(0),
          const SizedBox(width: 10),
          _buildCircle(1),
        ],
      )
    );
  }

  Widget _buildCircle(int index) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPageIndex == index ? const Color(0xFFA08D47) : Colors.grey,
      ),
    );
  }
}
