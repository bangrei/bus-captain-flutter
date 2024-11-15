import 'dart:convert';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/events/login_event.dart';
import 'package:bc_app/resources/pages/home_page.dart';
import 'package:bc_app/resources/pages/login_page.dart';
import 'package:bc_app/resources/pages/profile_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '/config/sidemenu.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  static String state = "sidemenu";

  @override
  createState() => _SideMenuState();
}

class _SideMenuState extends NyState<SideMenu> {
  _SideMenuState() {
    stateName = SideMenu.state;
  }

  String username = "";
  ApiController apiController = ApiController();

  

  @override
  init() async {
    
  }

  @override
  boot() async {
    final name = await NyStorage.read('username') ?? '';
    setState(() => username = name);
    
  }

  @override
  stateUpdated(dynamic data) async {
    reboot();
  }

  _cleanUp() async{
    await NyStorage.delete('authToken');
    await Auth.remove();
    // Stop Cron when logout:
    await event<LoginEvent>(data: {"runCronJob": false});
    /*
    * Remove cart list, in case user change to another user
    * This also means, we only keep shopping cart for as long as the app session last.
    * 
    */
    await NyStorage.delete('cart_list');
  }

  doLogout() async {
    final res = await apiController.onLogout();
    final json = jsonDecode(res);
    if (json['success']) {
      // Perform necessary clean up routine
      await _cleanUp();
      
      Navigator.pushNamedAndRemoveUntil(
        context,
        LoginPage.path,
        (route) => false,
      );
    } else {
      final msg = json['message'] ?? '';
      showSnackBar(
        context,
        "Something went wrong! $msg",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF333333),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 60),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context); // Close sidebar
                if (ModalRoute.of(context)?.settings.name == HomePage.path) {
                  Navigator.pushNamed(context, ProfilePage.path);
                } else {
                  // Always replace if current page is not HomePage.
                  Navigator.pushReplacementNamed(context, ProfilePage.path);
                }
              },
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Image.asset(
                      'public/assets/images/icons/defaultprofile.png',
                      fit: BoxFit.cover, // Adjust the fit as needed
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ), // Add spacing between image and name
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins-Bold',
                          fontSize: 18,
                        ), // Set text color to white
                      ),
                      Text(
                        "sidebar.profile".tr(),
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                          color: Colors.blue,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(width: 20),
                  // const Icon(Icons.chevron_right, color: Colors.white)
                ],
              ),
            ),
          ),
          const Divider(
            color: Color(0xFFF6F6F6),
            thickness: 2.5,
            indent: 20,
            endIndent: 20,
          ),
          ListView.builder(
              padding: const EdgeInsets.only(top: 15),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  sideMenuItems.length, // "+2" For Divider and "Settings" label
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ListTile(
                    leading: SizedBox(
                      width: 25,
                      height: 25,
                      child: Image.asset(
                        'public/assets/images/icons/${sideMenuItems[index]["icon"]}',
                        fit: BoxFit.cover, // Adjust the fit as needed
                      ),
                    ),
                    title: Text(
                      "sidebar.${sideMenuItems[index]["name"]}".tr(),
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ), // Set text color to white
                    ),
                    trailing: const Icon(Icons.chevron_right,
                        color: Colors.white), // Set icon color to white
                    onTap: () {
                      Navigator.pop(
                          context); // Close drawer before going to next page.

                      // Assuming 'path' is the route name
                      if (ModalRoute.of(context)?.settings.name ==
                          HomePage.path) {
                        Navigator.pushNamed(
                          context,
                          sideMenuItems[index]["path"],
                        );
                      } else {
                        // Always replace if current page is not HomePage.
                        Navigator.pushReplacementNamed(
                          context,
                          sideMenuItems[index]["path"],
                        );
                      }
                    },
                  ),
                );
              }),
          const SizedBox(height: 20),
          const Divider(
            color: Color(0xFFF6F6F6),
            thickness: 2.5,
            indent: 20,
            endIndent: 20,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 25),
            child: Text(
              "sidebar.settings".tr(),
              textScaler: TextScaler.noScaling,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          ListView.builder(
              padding: const EdgeInsets.only(top: 15),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sideMenuSettings
                  .length, // "+2" For Divider and "Settings" label
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ListTile(
                    leading: SizedBox(
                      width: 25,
                      height: 25,
                      child: Image.asset(
                        'public/assets/images/icons/${sideMenuSettings[index]["icon"]}',
                        fit: BoxFit.cover, // Adjust the fit as needed
                      ),
                    ),
                    title: Text(
                      "sidebar.${sideMenuSettings[index]["name"]}".tr(),
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ), // Set text color to white
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    ), // Set icon color to white
                    onTap: () async {
                      // Remove user if logging out
                      if (sideMenuSettings[index]["name"] == "logout account") {
                        doLogout();
                        return;
                      } else {
                        Navigator.pop(
                            context); // Close drawer before going to next page.
                      }

                      // Assuming 'path' is the route name
                      Navigator.pushNamed(
                        context,
                        sideMenuSettings[index]["path"],
                      );
                    },
                  ),
                );
              }),
          const SizedBox(height: 60)
        ],
      ),
    );
  }
}
