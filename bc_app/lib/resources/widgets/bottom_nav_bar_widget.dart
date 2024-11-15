import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '../pages/feedback_page.dart';
import '../pages/home_page.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  static String state = "bottom_nav_bar";

  @override
  createState() => _BottomNavBarState();
}

class _BottomNavBarState extends NyState<BottomNavBar> {
  _BottomNavBarState() {
    stateName = BottomNavBar.state;
  }

  @override
  init() async {}

  @override
  stateUpdated(dynamic data) async {
    // e.g. to update this state from another class
    // updateState(BottomNavBar.state, data: "example payload");
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 70,
      color: const Color(0xFF142431),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Container(
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                // setState(() {
                //   widget.currentIndex = 0;
                // });
                if (ModalRoute.of(context)?.settings.name != HomePage.path) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, HomePage.path, (Route<dynamic> route) => false);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'public/assets/images/icons/tab_home.png',
                    color: Colors.white,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'bottom_nav_bar.home'.tr(),
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(fontSize: 12, color: Colors.white)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 18.0, top: 30.0), // Adjust the left margin as needed
              child: Text(
                'bottom_nav_bar.report hazard'.tr(),
                 textScaler: TextScaler.noScaling,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ), // Add another empty Expanded widget
            GestureDetector(
              onTap: () {
                // setState(() {
                //   widget.currentIndex = 2;
                // });
                if (ModalRoute.of(context)?.settings.name !=
                    FeedbackPage.path) {
                  Navigator.pushNamed(context, FeedbackPage.path);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'public/assets/images/icons/tab_message.png',
                    color: Colors.white,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'bottom_nav_bar.feedback'.tr(),
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(fontSize: 12, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
