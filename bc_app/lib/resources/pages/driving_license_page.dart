import 'dart:convert';
import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/driving_license.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/driving_license_update_page.dart';
import 'package:bc_app/resources/pages/login_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';
import 'package:bc_app/resources/widgets/components/section_divider_widget.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:bc_app/resources/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nylo_framework/nylo_framework.dart';

class DrivingLicensePage extends NyStatefulWidget {
  static const path = '/driving-license';

  DrivingLicensePage({super.key})
      : super(path, child: _DrivingLicensePageState());
}

BoxDecoration myBoxDecoration(BuildContext context, double width) {
  return BoxDecoration(
    border: Border(
      bottom: BorderSide(
        color: ThemeColor.get(context).myBoxDecorationLine,
        width: width, // Set the width of the border
      ),
    ),
  );
}

Container myContainer(BuildContext context,String title, String value, {bool? expirySoon}) {
  return Container(
    margin: const EdgeInsets.only(top: 8),
    padding: const EdgeInsets.symmetric(vertical: 6),
    decoration: myBoxDecoration(context, 1),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("${title.tr()}:",
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              color: ThemeColor.get(context).drivingLicenseLabel
            )
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value, 
            textScaler: TextScaler.noScaling,
            maxLines: 4,
            textAlign: TextAlign.right,
            style: textValueStyle(context,expirySoon)),
        ),
      ],
    ),
  );
}

TextStyle textValueStyle(BuildContext context, bool? expirySoon) {
  return TextStyle(
      color: expirySoon == true ? Colors.red : ThemeColor.get(context).primaryContent,
      fontWeight: FontWeight.w600);
}

class _DrivingLicensePageState extends NyState<DrivingLicensePage> {
  bool onLoading = false;
  bool onSaving = false;
  ApiController apiController = ApiController();
  Map? profileData;
  List<dynamic> drivingLicenses = [];

  @override
  init() async {}

  /// Use boot if you need to load data before the [view] is rendered.
  @override
  boot() async {
    // String langPref = await NyStorage.read<String>('languagePref') ?? '';
    // changeLanguage(langPref);
    await _fetchProfile();
  }

  _fetchProfile() async {
    setState(() => onLoading = true);
    final res = await apiController.getProfile();
    final json = jsonDecode(res);
    setState(() => onLoading = false);
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

    final List<Map<String, dynamic>> items =
        List<Map<String, dynamic>>.from((json['drivingLicense'] ?? []));
    final licenses = items.toList().map((it) {
      final ditems = List<Map<String, dynamic>>.from((it['items'] ?? []));
      List<String> types = [];
      List<DrivingLicenseItem> licenseItems = [];
      for (final d in ditems.toList()) {
        final ltypes = d["licenseType"] == null
            ? []
            : d["licenseType"].split(",") as List<String>;

        List<String> dtypes = ltypes.map((t) => t.toString()).toList();

        types.addAll(dtypes);
        licenseItems.add(
          DrivingLicenseItem(
              id: d['id'],
              drivingLicenseTypes: dtypes,
              issueDate: toDatetime(d["issueDate"])!,
              expiryDate: toDatetime(d["expiryDate"])!,
              renewRequested: (d['renewRequested'] ?? false) == true),
        );
      }
      return DrivingLicense(
        id: ditems[0]["id"],
        drivingLicenseTypes: types.map((it) {
          return it.toString().trim();
        }).toList(),
        issueDate: toDatetime(ditems[0]["issueDate"])!,
        expiryDate: toDatetime(ditems[0]["expiryDate"])!,
        renewRequested: (ditems[0]['renewRequested'] ?? false) == true,
        items: licenseItems,
      );
    });

    setState(() {
      profileData = json;
      drivingLicenses = licenses.toList();
    });
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: TitleBar(title: "user_profile.driving_license_screen.title".tr()),
      body: onLoading
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Loader()],
            )
          : SafeArea(
              child: Column(
                children: [
                  MasterLayout(
                    child: Column(
                      children: [
                        myContainer(
                            context,
                            "user_profile.driving_license_screen.bcid".tr(),
                            profileData!["bcId"] ?? '-'),
                        myContainer(
                            context,
                            "user_profile.driving_license_screen.name".tr(),
                            profileData!["name"] ?? '-'),
                      ],
                    ),
                  ),
                  const SectionDivider(),
                  drivingLicenses.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: Center(
                            child: Text(
                              "user_profile.driving_license_screen.no data"
                                  .tr(),
                              textScaler: TextScaler.noScaling,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: ThemeColor.get(context).primaryContent,
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                              itemCount: drivingLicenses.length,
                              itemBuilder: (context, index) {
                                final drivingLicense = drivingLicenses[index];
                                int daysUntilExpiry() {
                                  return drivingLicense.expiryDate
                                      .difference(DateTime.now())
                                      .inDays;
                                }

                                bool unlimitedExpiry() {
                                  return stringifyDate(
                                          drivingLicense.expiryDate) ==
                                      "9999-12-31";
                                }

                                bool isExpirySoon() {
                                  if (unlimitedExpiry()) return false;
                                  return daysUntilExpiry() < 30;
                                }

                                return Column(
                                  children: [
                                    MasterLayout(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "License #${index + 1}",
                                              textScaler: TextScaler.noScaling,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: ThemeColor.get(context).primaryContent,
                                              ),
                                            ),
                                            isExpirySoon()
                                                ? SizedBox(
                                                    height: 24,
                                                    child:
                                                        drivingLicense
                                                                .renewRequested
                                                            ? Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 15),
                                                              decoration: BoxDecoration(
                                                                color: nyHexColor("#FD9843"),
                                                                borderRadius: const BorderRadius.all(Radius.circular(20))
                                                              ),
                                                              child: Text(
                                                                  "user_profile.driving_license_screen.pending".tr(),
                                                                  textScaler: TextScaler.noScaling,
                                                                  style: const TextStyle(
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.bold
                                                                  ),
                                                                ),
                                                            )
                                                            : ElevatedButton(
                                                                onPressed: () {
                                                                  Navigator.pushNamed(
                                                                      context,
                                                                      DrivingLicenseUpdatePage
                                                                          .path,
                                                                      arguments: {
                                                                        "bcId":
                                                                            profileData!["bcId"],
                                                                        "name":
                                                                            profileData!["name"],
                                                                        "drivingLicense":
                                                                            drivingLicense
                                                                      }).then(
                                                                      (value) {
                                                                    _fetchProfile();
                                                                  });
                                                                },
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .blue,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            24),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  "user_profile.driving_license_screen.renew"
                                                                      .tr(),
                                                                  textScaler: TextScaler.noScaling,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                  ),
                                                                ),
                                                              ),
                                                  )
                                                : const SizedBox()
                                          ],
                                        ),
                                        myContainer(
                                            context,
                                            "user_profile.driving_license_screen.license type",
                                            "${drivingLicense.drivingLicenseTypes.join(
                                              ", ",
                                            )}"),
                                        myContainer(
                                            context,
                                            "user_profile.driving_license_screen.issue date",
                                            DateFormat("dd/MM/yyyy").format(
                                                drivingLicense.issueDate)),
                                        myContainer(
                                            context,
                                            "user_profile.driving_license_screen.expiry date",
                                            unlimitedExpiry()
                                                ? "user_profile.driving_license_screen.no expiry"
                                                    .tr()
                                                : DateFormat("dd/MM/yyyy").format(
                                                    drivingLicense.expiryDate)),
                                        myContainer(
                                            context,
                                            "user_profile.driving_license_screen.days to expiration",
                                            unlimitedExpiry()
                                                ? "-"
                                                : "user_profile.driving_license_screen.expiry days"
                                                    .tr(arguments: {
                                                    "days":
                                                        "${daysUntilExpiry()}"
                                                  }),
                                            expirySoon: isExpirySoon()),
                                      ],
                                    )),
                                    const SectionDivider(),
                                  ],
                                );
                              }),
                        )
                ],
              ),
            ),
    );
  }
}
