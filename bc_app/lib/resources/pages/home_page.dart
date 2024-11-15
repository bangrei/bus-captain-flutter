import 'dart:async';

import 'package:bc_app/resources/pages/login_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';
import 'package:bc_app/resources/widgets/custom_scaffold_widget.dart';
import 'package:bc_app/resources/widgets/modal_duty_bidding_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '/config/mainmenu.dart';

class HomePage extends NyStatefulWidget {
  static const path = '/home';

  HomePage({super.key}) : super(path, child: _HomePageState());

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends NyState<HomePage> {

  @override
  boot() async {
    String? myAuthToken = await NyStorage.read('authToken') ?? '';
    if (myAuthToken!.isEmpty) {
      Navigator.pushReplacementNamed(context, LoginPage.path);
    }
  }

  void _showPopupJobAssignment(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () {
      displayDialog(
          context: context,
          buttonLabel: 'Acknowledge',
          buttonOnPressed: () => Navigator.pop(context),
          headerWidget: const Text(
            'Incoming Job assignment (61AM17)',
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            )),
          bodyWidget: const ModalDutyBidding());
    });
  }

  void _showPopupDutyBidding(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () {
      displayDialog(
          context: context,
          buttonLabel: 'Bid for job',
          buttonOnPressed: () {
            Navigator.pop(context);
            _showBottomSheet(context, confirmBid);
          },
          headerWidget: const Text('New Duty Available for Bidding',
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              )),
          bodyWidget: const ModalDutyBidding());
    });
  }

  void confirmBid(context) {
    Navigator.pop(context);
  }

  @override
  Widget view(BuildContext context) {
    return CustomScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MasterLayout(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Text(
                "homepage_screen.dashboard".tr(),
                textScaler: TextScaler.noScaling,
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'Poppins-Bold',
                  fontWeight: FontWeight.bold,
                ),
              ).onTap(() => _showPopupJobAssignment(context)),
            ),
            MasterLayout(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              child: Text(
                'homepage_screen.shortcuts'.tr(),
                textScaler: TextScaler.noScaling,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins-Bold',
                ),
              ).onTap(() => _showPopupDutyBidding(context)),
            ),
            SizedBox(
              height: 680,
              child: MasterLayout(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 10.0,
                ),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing:
                        10, // Horizontal spacing between grid items
                    mainAxisSpacing: 30, // Vertical spacing between grid items
                    childAspectRatio: 0.85, // Adjust this ratio to make items taller or shorter
                  ),
                  itemCount: mainMenuItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = mainMenuItems[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigate to the route specified in the 'path' attribute
                        Navigator.pushNamed(context, item["path"]);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'public/assets/images/icons/${item["icon"]}',
                            height: 60,
                          ),
                          const SizedBox(
                              height:
                                  8), // Vertical space between icon and text
                          Flexible(
                            child: Wrap(
                              children: [
                                Text(
                                  "homepage_screen.${item["name"]}".tr(),
                                  textScaler: TextScaler.noScaling,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins-Bold',
                                  ),
                                ),
                              ]
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showBottomSheet(BuildContext context, Function confirmBid) {
  showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    builder: (BuildContext context) {
      return SizedBox(
          height: 230,
          child: Padding(
              padding: const EdgeInsets.all(25.5),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Submit bid for job",
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins-Bold",
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Divider(height: 0, color: Colors.black12),
                  const SizedBox(
                    height: 20.0,
                  ),
                  RichText(
                      text: const TextSpan(
                          style: TextStyle(color: Colors.grey),
                          children: <TextSpan>[
                        TextSpan(text: "You are submitting a bid for "),
                        TextSpan(
                            text: "Service 11 (184AM07)",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                        TextSpan(text: ". Please confirm your submission.")
                      ])),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(width: 1, color: nyHexColor("CBD0DC")),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              padding: const EdgeInsets.symmetric(horizontal: 16)
                            ),
                            child: Text(
                                "message_page.details_screen.cancel".tr(),
                                textScaler: TextScaler.noScaling,
                                style: const TextStyle(
                                    fontFamily: 'Poppins-Regular',
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF54575C)))),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GeneralButton(
                            text: "Confirm",
                            onPressed: () {
                              Navigator.of(context).pop();
                            }),
                      )
                    ],
                  ),
                ],
              )));
    },
  );
}
