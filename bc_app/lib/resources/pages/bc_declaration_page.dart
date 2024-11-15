import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/controllers/home_controller.dart';
import 'package:bc_app/app/models/bus_check_item.dart';
import 'package:bc_app/app/models/bus_check_response.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/bus_check_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:bc_app/resources/widgets/custom_scaffold_widget.dart';
import 'package:bc_app/resources/widgets/safearea_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class BCDeclarationPage extends NyStatefulWidget<HomeController> {
  static const path = '/bc-declaration';

  BCDeclarationPage({super.key})
      : super(path, child: _BCDeclarationPageState());
}

class _BCDeclarationPageState extends NyState<BCDeclarationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<BusCheckResponse> responses = [];
  ApiController apiController = ApiController();

  @override
  boot() async {
    String langPref = await NyStorage.read<String>('languagePref') ?? '';
    changeLanguage(langPref);
    //  await NyStorage.saveCollection('bcDeclarations', []);
    final json = await apiController.myDeclarationsDeclared(context);
    bool isDeclared = json['declared'] || false;

    //If redeclaration is needed, set isDeclared to false
    dynamic args = ModalRoute.of(context)!.settings.arguments;
    if (args != null) {
      isDeclared = args['declared'] || false;
    }

    if (isDeclared) {
      Navigator.pushReplacementNamed(context, BusCheckPage.path);
    } else {
      final res = await apiController.getDeclarations(context);

      setState(() {
        responses = res.toList();
      });
    }
  }

  saveDeclarations() async {
    final unfilled = responses.where((it) {
      setState(() {
        it.unfilled = it.checked == null;
      });
      return it.checked == null;
    }).toList();

    if (unfilled.isNotEmpty) {
      displayDialog(
          context: context,
          headerWidget: const SizedBox(),
          bodyWidget: Text(
              "buscheck_page.busdeclaration_screen.unfilled message".tr(),
              textScaler: TextScaler.noScaling),
          buttonLabel: "buscheck_page.busdeclaration_screen.close".tr());
      return;
    }

    final unmarked = responses.where((it) => !it.checked!).toList();
    if (unmarked.isNotEmpty) {
      return _showConfirmation(context, (bool? confirmed) async {
        if (confirmed != true) return;
        final bci = BusCheckItem(type: "Declaration", logs: responses);
        final res = await apiController.submitBusCheckDeclaration(
            context: context, buscheckItem: bci, needApproval: true);
        if (!res) return;
        // await NyStorage.saveCollection<dynamic>(
        //     "bcDeclarations", responses.map((it) => it.toMap()).toList());
        Navigator.pushReplacementNamed(context, BusCheckPage.path);
      });
    } else {
      // If all 'yes' response, still send to BE but with needApproval = false.
      // BE will record the response to redis.
      final bci = BusCheckItem(type: "Declaration", logs: responses);
      final res = await apiController.submitBusCheckDeclaration(
          context: context, buscheckItem: bci, needApproval: false);
      if (!res) return;
      // await NyStorage.saveCollection<dynamic>(
      //     "bcDeclarations", responses.map((it) => it.toMap()).toList());
      Navigator.pushReplacementNamed(context, BusCheckPage.path);
    }
  }

  /// The [view] method should display your page.
  @override
  Widget view(BuildContext context) {
    return CustomScaffold(
      key: _scaffoldKey,
      body: SafeAreaWidget(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'buscheck_page.busdeclaration_screen.title'.tr(),
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(
                    fontSize: 24,
                    fontFamily: 'Poppins-Bold',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  'buscheck_page.busdeclaration_screen.reminder message'.tr(),
                  textScaler: TextScaler.noScaling,
                ),
                const SizedBox(height: 20.0),
                ...responses.asMap().entries.map((entry) {
                  int index = entry.key;
                  final res = responses[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: ThemeColor.get(context).cardBg,
                      borderRadius: BorderRadius.circular(10.0),
                      border: res.unfilled
                          ? Border.all(color: Colors.red, width: 1)
                          : null,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            res.description,
                            textScaler: TextScaler.noScaling,
                            style: const TextStyle(fontSize: 14.0),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Row(
                          children: [
                            Row(
                              children: [
                                Radio(
                                  value: true,
                                  groupValue: res.checked,
                                  onChanged: (bool? value) async {
                                    setState(() {
                                      responses[index].checked = value!;
                                    });
                                  },
                                  visualDensity: const VisualDensity(
                                    horizontal: -4.0,
                                    vertical: -4.0,
                                  ),
                                ),
                                Text(
                                  'buscheck_page.busdeclaration_screen.yes'
                                      .tr(),
                                  textScaler: TextScaler.noScaling,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Radio(
                                  value: false,
                                  groupValue: res.checked,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      responses[index].checked = value!;
                                    });
                                  },
                                  visualDensity: const VisualDensity(
                                    horizontal: -4.0,
                                    vertical: -4.0,
                                  ),
                                ),
                                Text(
                                  'buscheck_page.busdeclaration_screen.no'.tr(),
                                  textScaler: TextScaler.noScaling,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFFFFF),
                          foregroundColor: const Color(0xFF566789),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF566789),
                          ),
                          shape: const RoundedRectangleBorder(
                            side: BorderSide(color: Color(0xFF566789)),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                        ),
                        child: Text(
                          "buscheck_page.endoftrip_screen.button cancel".tr(),
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                              color: ThemeColor.get(context).surfaceContent),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 1,
                      child: ElevatedButton(
                        onPressed: () async {
                          await saveDeclarations();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1570EF),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                        ),
                        child: Text(
                          "buscheck_page.endoftrip_screen.button submit".tr(),
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                              color: ThemeColor.get(context).primaryContent),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get isThemeDark =>
      ThemeProvider.controllerOf(context).currentThemeId ==
      getEnv('DARK_THEME_ID');

  void _showConfirmation(BuildContext context, Function(bool) response) {
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
                        "buscheck_page.busdeclaration_screen.confirmation".tr(),
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        response(false);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Text(
                  'buscheck_page.busdeclaration_screen.warning message'.tr(),
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    color: ThemeColor.get(context).primaryContent,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    GeneralButton(
                      text: "buscheck_page.endoftrip_screen.button cancel".tr(),
                      color: Colors.black.withOpacity(0.1),
                      onPressed: () {
                        response(false);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 24),
                    GeneralButton(
                      text: "buscheck_page.endoftrip_screen.button submit".tr(),
                      onPressed: () {
                        response(true);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
