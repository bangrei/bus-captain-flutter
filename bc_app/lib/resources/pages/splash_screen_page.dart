import 'package:bc_app/resources/pages/starting_page.dart';
import 'package:bc_app/resources/pages/welcome_page.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nylo_framework/nylo_framework.dart';

class SplashScreenPage extends NyStatefulWidget {
  static const path = '/splash-screen';

  SplashScreenPage({super.key}) : super(path, child: _SplashScreenPageState());
}

class _SplashScreenPageState extends NyState<SplashScreenPage>
    with SingleTickerProviderStateMixin {
  @override
  init() async {
    // super.initState();

    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Make status bar transparent
      statusBarIconBrightness: Brightness.light, // For Android
    ));

    String? myAuthToken = await NyStorage.read('authToken') ?? '';
    Future.delayed(const Duration(seconds: 2), () {
      if (myAuthToken!.isEmpty) {
        Navigator.pushReplacementNamed(context, StartingPage.path);
      } else {
        Navigator.pushReplacementNamed(context, WelcomePage.path);
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  /// Use boot if you need to load data before the [view] is rendered.
  // @override
  // boot() async {
  //
  // }

  @override
  Widget view(BuildContext context) {
    return Scaffold( 
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                  'public/assets/images/splash_background.png'), // Your background image
              fit: BoxFit.fill // Make sure the image covers the whole screen
              ),
        ),
        child: Center(
          child: MasterLayout(
            child: Image.asset(
                    'public/assets/images/SMRT_logo.png'),
          ), // Your app logo
        ),
      ),
    );
  }
}
