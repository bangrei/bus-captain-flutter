import 'dart:io';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/controllers/home_controller.dart';
import 'package:bc_app/app/models/bus_check_response.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/bc_declaration_page.dart';
import 'package:bc_app/resources/pages/bus_checklist_history_page.dart';
import 'package:bc_app/resources/pages/bus_last_parked_page.dart';
import 'package:bc_app/resources/pages/qr_scanner_page.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:bc_app/resources/widgets/custom_scaffold_widget.dart';
import 'package:bc_app/resources/widgets/safearea_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:permission_handler/permission_handler.dart';

class BusCheckPage extends NyStatefulWidget<HomeController> {
  static const path = '/bus-check';

  BusCheckPage({super.key}) : super(path, child: _BusCheckPageState());
}

BoxDecoration myBoxDecoration(double width) {
  return BoxDecoration(
    border: Border.all(color: Colors.black26, width: width),
    borderRadius: BorderRadius.circular(10),
  );
}

class _BusCheckPageState extends NyState<BusCheckPage> {
  bool declared = false;
  bool bcRedeclared = false;
  bool redeclarationApproved = false;
  List<BusCheckResponse> declarationChecklist = [];
  ApiController apiController = ApiController();
  List<String> tasks = [];

  @override
  boot() async {
    String langPref = await NyStorage.read<String>('languagePref') ?? '';
    changeLanguage(langPref);
    setLoading(true, name: 'onLoading');
    // List<BusCheckResponse> mydeclarations = await myBCDelarations();
    final json = await apiController.myDeclarationsDeclared(context);
    final res = await apiController.getBusTripTypes(context);
    setLoading(false, name: 'onLoading');
    setState(() {
      tasks = res;
      // declarationChecklist = mydeclarations;
      declared = json['declared'] || false;
      bcRedeclared = json['bcNeedRedeclared'] || false;
      redeclarationApproved = json['redeclarationApproved'] || false;

      // declarationChecklist
      //         .where((it) => it.checked == true)
      //         .toList()
      //         .length ==
      //     declarationChecklist.length;
    });
  }

  Future<bool> checkCameraPermission() async {
    final cameraPermissionStatus = await Permission.camera.request();
    if (cameraPermissionStatus.name == "granted") {
      return true;
    }
    return false;
  }

  openScanner(BuildContext context, String task) async {
    if (await checkCameraPermission() || Platform.isIOS) {
      routeTo(
        // ChooseBusPage.path,
        QRScanner.path,
        data: {'task': task},
      );
    }
  }

  /// The [view] method should display your page.
  @override
  Widget view(BuildContext context) {
    return CustomScaffold(
      body: SafeAreaWidget(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  declared && !bcRedeclared
                      ? 'buscheck_page.main_screen.bus declaration declared'
                          .tr()
                      : 'buscheck_page.main_screen.bus declaration not declared'
                          .tr(),
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                      fontSize: 15,
                      color: declared && !bcRedeclared ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins-Bold"),
                ),
                const SizedBox(height: 10),
                Text(
                  'buscheck_page.main_screen.title'.tr(),
                  textScaler: TextScaler.noScaling,
                  style:
                      const TextStyle(fontSize: 24, fontFamily: 'Poppins-bold'),
                ),
                const SizedBox(height: 20.0),
                Text(
                  'buscheck_page.main_screen.description'.tr(),
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    children: tasks.map((task) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: GeneralButton(
                          text:
                              "buscheck_page.main_screen.${task.toLowerCase()}"
                                  .tr(),
                          borderRadius: 0.0,
                          height: 50.0,
                          onPressed: () async {
                            //Show message if BC need to redeclare
                            if (bcRedeclared) {
                              return _showConfirmation(
                                  context,
                                  "buscheck_page.main_screen.${task.toLowerCase()}"
                                      .tr(),
                                  'buscheck_page.main_screen.bus declaration failed alert message'
                                      .tr(), (bool resp) async {
                                if (resp != true) return;
                                await openScanner(context, task);
                                // await goToCheckBusPage(context, task);
                              });
                            }
                            await openScanner(context, task);
                            // await goToCheckBusPage(context, task);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 30),
                GeneralButton(
                  text: "buscheck_page.main_screen.bus checklist history".tr(),
                  color: ThemeColor.get(context).primaryContent,
                  textColor: ThemeColor.get(context).background,
                  borderRadius: 0.0,
                  height: 50.0,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      BusChecklistHistoryPage.path,
                    );
                  },
                ),
                const SizedBox(height: 20),
                GeneralButton(
                  text:
                      "buscheck_page.main_screen.bus last parked location".tr(),
                  color: ThemeColor.get(context).primaryContent,
                  textColor: ThemeColor.get(context).background,
                  borderRadius: 0.0,
                  height: 50.0,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      BuslastParkedLocationPage.path,
                    );
                  },
                ),
                const SizedBox(height: 40),
                declared && !bcRedeclared
                    ? const SizedBox()
                    : GeneralButton(
                        text: "BC Redeclaration",
                        color: Colors.redAccent,
                        borderRadius: 0.0,
                        height: 50.0,
                        onPressed: () async {
                          //Show confirmation if redeclaration req has not been approved
                          if (!redeclarationApproved) {
                            return _showConfirmation(
                                context,
                                'Declaration',
                                'buscheck_page.main_screen.bus declaration not declared'
                                    .tr(),
                                (bool resp) {});
                          }
                          // Reset BC declaration record to allow re-declaration
                          // await NyStorage.saveCollection('bcDeclarations', []);

                          Navigator.pushReplacementNamed(
                            context,
                            BCDeclarationPage.path,
                            arguments: {'declared': false}
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmation(
      BuildContext context, String taskName, String message,
      Function(bool) response) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        taskName,
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Text(
                  message,
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    color: ThemeColor.get(context).primaryContent,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool get isThemeDark =>
      ThemeProvider.controllerOf(context).currentThemeId ==
      getEnv('DARK_THEME_ID');
}
