import 'dart:convert';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/networking/api_service.dart';
import 'package:bc_app/resources/pages/change_password_page.dart';
import 'package:bc_app/resources/pages/driving_license_page.dart';
import 'package:bc_app/resources/pages/login_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:bc_app/resources/widgets/components/section_divider_widget.dart';
import 'package:bc_app/resources/widgets/components/section_header_widget.dart';
import 'package:bc_app/resources/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ProfilePage extends NyStatefulWidget {
  static const path = '/profile';

  ProfilePage({super.key}) : super(path, child: _ProfilePageState());
}

class _ProfilePageState extends NyState<ProfilePage> {
  bool onLoading = false;
  ApiController apiController = ApiController();
  String? bcId;
  String? name;
  Map<dynamic, dynamic>? reportingSupervisor;
  String? interchange;
  String? busNo;
  List<dynamic>? drivingLicenses;

  
  String baseUrl = ApiService().baseUrl;

  @override
  init() async {}

  /// Use boot if you need to load data before the [view] is rendered.
  @override
  boot() async {
    await _fetchProfile();
  }

  //Subroutine to call 'Get Profile' API
  _fetchProfile() async {
    setState(() => onLoading = true);
    final res = await apiController.getProfile();
    setState(() => onLoading = false);
    final json = jsonDecode(res);
    bool success = json.isEmpty ? false : json['success'] == true;
    if (!success) {
      showSnackBar(
        context,
        json.isEmpty ? 'snackbar.network issue'.tr() : json['message'],
        isSuccess: false,
      );
      NyStorage.delete('authToken');
      routeTo(LoginPage.path);
      return;
    }
    setState(() {
      bcId = json["bcId"] ?? '-';
      name = json["name"] ?? '-';
      reportingSupervisor = (json["reportingSupervisor"]!.isNotEmpty
          ? json["reportingSupervisor"]
          : {}) as Map<dynamic, dynamic>;
      interchange = json["interchange"] ?? '-';
      if (json["drivingLicense"] != null) {
        drivingLicenses = json['drivingLicense']!.map((it) {
          return it as Map<dynamic, dynamic>;
        }).toList();
      }
    });
  }

  String listDrivingLicenses() {
    if (drivingLicenses!.isEmpty) return "-";
    List<String> items = [];
    for (final k in drivingLicenses!) {
      items.add(dateFormatString(
        k["expiryDate"] ?? '',
        fromFormat: 'yyyy-MM-dd',
        toFormat: 'dd MMM yyyy',
      ));
    }
    return items.join(", ");
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: TitleBar(title: "user_profile.title".tr()),
      body: onLoading
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Loader()],
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            icon: Icons.person_3_rounded,
                            sectionName: "user_profile.profile".tr(),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "user_profile.bc id".tr(),
                                      textScaler: TextScaler.noScaling,
                                      style: const TextStyle(
                                          fontFamily: "Poppins-SemiBold",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      bcId!.toString(),
                                      textScaler: TextScaler.noScaling,
                                      style: const TextStyle(fontSize: 14),
                                    )
                                  ],
                                ),
                                const Divider(color: Colors.black12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "user_profile.bc name".tr(),
                                      textScaler: TextScaler.noScaling,
                                      style: const TextStyle(
                                          fontFamily: "Poppins-SemiBold",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      name!.isNotEmpty ? name.toString() : '-',
                                      textScaler: TextScaler.noScaling,
                                      style: const TextStyle(fontSize: 14),
                                    )
                                  ],
                                ),
                                const Divider(color: Colors.black12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "user_profile.reporting supervisor".tr(),
                                      textScaler: TextScaler.noScaling,
                                      style: const TextStyle(
                                          fontFamily: "Poppins-SemiBold",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      reportingSupervisor!["name"] ?? '-',
                                      textScaler: TextScaler.noScaling,
                                      style: const TextStyle(fontSize: 14),
                                    )
                                  ],
                                ),
                                const Divider(color: Colors.black12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "user_profile.depot/interchange".tr(),
                                      textScaler: TextScaler.noScaling,
                                      style: const TextStyle(
                                          fontFamily: "Poppins-SemiBold",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      interchange!.isNotEmpty
                                          ? interchange.toString()
                                          : '-',
                                      textScaler: TextScaler.noScaling,
                                      style: const TextStyle(fontSize: 14),
                                    )
                                  ],
                                ),
                                const Divider(color: Colors.black12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "user_profile.bus no".tr(),
                                      textScaler: TextScaler.noScaling,
                                      style: const TextStyle(
                                          fontFamily: "Poppins-SemiBold",
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      busNo ?? '-',
                                      textScaler: TextScaler.noScaling,
                                      style: const TextStyle(fontSize: 14),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SectionDivider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                              image: 'public/assets/images/card.png',
                              sectionName: "user_profile.driving license".tr()),
                          const SizedBox(height: 20),
                          InkWell(
                            onTap: () => {
                              Navigator.pushNamed(
                                      context, DrivingLicensePage.path)
                                  .then((value) {
                                _fetchProfile();
                              })
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "user_profile.driving license".tr(),
                                    textScaler: TextScaler.noScaling,
                                    style: const TextStyle(
                                        fontFamily: "Poppins-SemiBold",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Icon(Icons.arrow_forward_ios,
                                      size: 16, color: nyHexColor("#ABABAB")),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SectionDivider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                              image: 'public/assets/images/lock.png',
                              sectionName: "user_profile.security".tr()),
                          const SizedBox(height: 20),
                          InkWell(
                            onTap: () => {
                              Navigator.pushNamed(
                                  context, ChangePasswordPage.path)
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "user_profile.change password".tr(),
                                    textScaler: TextScaler.noScaling,
                                    style: const TextStyle(
                                        fontFamily: "Poppins-SemiBold",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Icon(Icons.arrow_forward_ios,
                                      size: 16, color: nyHexColor("#ABABAB")),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SectionDivider(),
                  ],
                ),
              ),
            ),
    );
  }
}
