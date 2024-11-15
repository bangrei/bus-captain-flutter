import 'dart:convert';

import 'package:bc_app/app/events/login_event.dart';
import 'package:bc_app/resources/pages/hazard_report_page.dart';
import 'package:bc_app/resources/pages/home_page.dart';
import 'package:bc_app/resources/pages/message_category_page.dart';
import 'package:bc_app/resources/pages/message_page.dart';
import 'package:bc_app/resources/pages/notifications_page.dart';
import 'package:bc_app/resources/widgets/components/sidemenu_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

import 'bottom_nav_bar_widget.dart';
import 'components/appbar_widget.dart';

// ignore: must_be_immutable
class CustomScaffold extends StatefulWidget {
  CustomScaffold(
      {super.key,
      required this.body,
      this.bottomNavigationBar,
      this.bottomnavhide = false,
      this.bottomcenterhide = false});

  Widget body;
  Widget? bottomNavigationBar;
  bool bottomnavhide;
  bool bottomcenterhide;

  static String state = "custom_scaffold";

  @override
  createState() => _CustomScaffoldState();
}

// Define a global key to keep track of the state.
final GlobalKey<_CustomScaffoldState> customScaffoldState =
    GlobalKey<_CustomScaffoldState>();

class _CustomScaffoldState extends NyState<CustomScaffold> {
  _CustomScaffoldState() {
    stateName = CustomScaffold.state;
  }

  @override
  init() async {
    super.init();
    String token = await NyStorage.read('authToken') ?? '';
    if (token != '') {
      final res = await apiController.getProfile();
      if (res == null) return;
      final json = jsonDecode(res);
      if (json['success']) {
        await NyStorage.store('username', json['name']);
        updateState(SideMenu.state);
      }
    }
  }

  @override
  boot() async {}

  @override
  stateUpdated(dynamic data) async {
    // e.g. to update this state from another class
    // updateState(CustomScaffold.state, data: "example payload");
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        onOpenDrawer: () async {
          _scaffoldKey.currentState?.openDrawer();
        },
        onOpenMessage: () {
          // Add your message functionality here
          if (ModalRoute.of(context)?.settings.name == HomePage.path) {
            Navigator.pushNamed(context, MessageCategoryPage.path);
            return;
          }

          if (ModalRoute.of(context)?.settings.name != MessagePage.path) {
            Navigator.pushReplacementNamed(context, MessageCategoryPage.path);
            return;
          }
        },
        onOpenNotification: () {
          // Add your message functionality here
          if (ModalRoute.of(context)?.settings.name == HomePage.path) {
            Navigator.pushNamed(context, NotificationsPage.path);
            return;
          }

          if (ModalRoute.of(context)?.settings.name != NotificationsPage.path) {
            Navigator.pushReplacementNamed(context, NotificationsPage.path);
            return;
          }
        },
      ),
      body: widget.body,
      drawer: const SideMenu(),
      extendBody: true,
      floatingActionButton: !widget.bottomnavhide
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, HazardReportPage.path);
                // setState(() {
                //   _currentIndex = 1;
                // });
              },
              shape: const CircleBorder(),
              backgroundColor: const Color(0xFF1570EF),
              child: Image.asset('public/assets/images/icons/tab_hazard.png'),
            )
          : null,
      floatingActionButtonLocation: !widget.bottomnavhide
          ? FloatingActionButtonLocation.centerDocked
          : null,
      bottomNavigationBar: !widget.bottomnavhide
          ? const BottomNavBar()
          : widget.bottomNavigationBar,
    );
  }
}
