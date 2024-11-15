import 'dart:io';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/controllers/home_controller.dart';
import 'package:bc_app/app/models/bus_check_item.dart';
import 'package:bc_app/app/models/bus_check_response.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/qr_scanner_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/bus_check_component.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:bc_app/resources/widgets/components/input_dropdown_widget.dart';
import 'package:bc_app/resources/widgets/components/input_text_widget.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';
import 'package:bc_app/resources/widgets/custom_scaffold_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class EndOfTripTasksPage extends NyStatefulWidget<HomeController> {
  static const path = '/end-of-trip-tasks';

  EndOfTripTasksPage({super.key})
      : super(path, child: _EndOfTripTasksTasksPageState());
}

class _EndOfTripTasksTasksPageState extends NyState<EndOfTripTasksPage> {
  bool showResume = false;
  ApiController apiController = ApiController();
  String taskName = "";
  String plateNumber = "";
  List<BusCheckItem> checklist = [];
  List<String> depotList = [];
  int currentLevel = -1;
  List<String> levelSD = ['Level 1 Front', 'Level 1 Back'];
  List<String> levelDD = ['Level 1 Front', 'Level 2 Back', 'Level 1 Back'];
  Map<String, dynamic>? busDetails;

  int stepNumber = -1;
  TextEditingController plateController = TextEditingController();
  TextEditingController depotController = TextEditingController();
  TextEditingController tripNumberController = TextEditingController();
  List<Map<String, dynamic>> remarkControllers = [];
  
  bool _isSubmitting = false;

  @override
  boot() async {
    String langPref = await NyStorage.read<String>('languagePref') ?? '';
    changeLanguage(langPref);
    Map args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    String task = args['taskName'] ?? "";
    String result = args['result'] ?? "";
    List<BusCheckItem> res = args['checklist'] ?? [];
    final bdt = args['bus'];

    bool istypeDD = bdt['type'] == "DD";
    bool istypeSD = bdt['type'] == "SD";
    int indexDD = res.indexWhere((it) => it.type == "Bus Lower Deck Check");
    if (istypeDD) {
      if (indexDD > -1) {
        res = remapDoubleDeck(res, indexDD);
      }
    }
    if (istypeSD) {
      int indexSD = res.indexWhere((it) => it.type == "Bus Upper Deck Check");
      if (indexSD > -1) {
        res.removeAt(indexSD);
        if (indexDD > -1) {
          res = remapDoubleDeck(res, indexDD);
        }
      }
    }

    List<String> depots = await apiController.getDepotList(context);
    setState(() {
      taskName = task;
      plateNumber = result;
      plateController.text = plateNumber;
      checklist = res;
      depotList = depots.toList();
      busDetails = bdt;
    });
    generateRemarkControllers();
  }

  remapDoubleDeck(List<BusCheckItem> res, int index) {
    BusCheckItem dd = res[index];
    List<int> oldIndexes = [];
    final serials = dd.logs.map((it) => it.serialNo).toList();
    List<BusCheckResponse> newDDLogs = [];
    List<BusCheckResponse> oldDDLogs = [];
    for (int i = 0; i < serials.length; i++) {
      if (oldIndexes.contains(serials[i])) {
        newDDLogs.add(dd.logs[i]);
      } else {
        oldDDLogs.add(dd.logs[i]);
        oldIndexes.add(serials[i]);
      }
    }
    if (newDDLogs.isNotEmpty) {
      BusCheckItem oldDD = dd;
      oldDD.logs = oldDDLogs;
      res[index] = oldDD;
      final newDD = BusCheckItem(type: dd.type, logs: newDDLogs);
      res.add(newDD);
    }
    return res;
  }

  generateRemarkControllers() {
    if (checklist.isEmpty) return;
    for (final item in checklist) {
      for (final log in item.logs) {
        remarkControllers
            .add({"id": log.id, "controller": TextEditingController()});
      }
    }
  }

  isLastOne() {
    return stepNumber == checklist.length - 1;
  }

  openScanner(Function callback) async {
    setLoading(true, name: 'EOT_loading');
    routeTo(
      QRScanner.path,
      data: {'task': taskName, 'needReturnBack': true},
      onPop: (value) async {
        debugPrint("Value of open scanner: ${value.toString()}");
        setLoading(false, name: 'EOT_loading');
        callback(value.toString());
      },
    );
  }

  nextTask() {
    if (showResume) return;
    if (stepNumber == -1) {
      if (plateController.text == "") {
        return showSnackBar(
          context,
          "buscheck_page.endoftrip_screen.bus plate number alert message".tr(),
          isSuccess: false,
        );
      }
      if (tripNumberController.text == "") {
        return showSnackBar(
          context,
          "buscheck_page.endoftrip_screen.trip number alert message".tr(),
          isSuccess: false,
        );
      }
      if (depotController.text == "") {
        return showSnackBar(
          context,
          "buscheck_page.endoftrip_screen.depot field alert message".tr(),
          isSuccess: false,
        );
      }
    }

    if (!isRadioCheckedAll() && stepNumber > -1) {
      return showSnackBar(
        context,
        "buscheck_page.endoftrip_screen.check all alert message".tr(),
        isSuccess: false,
      );
    }

    if (isLastOne()) {
      setState(() => showResume = true);
      return;
    }
    // Scan then move to next
    openScanner((String? value) async {
      if (value == null) return;
      List<String> levels = busDetails!['type'] == 'DD' ? levelDD : levelSD;
      debugPrint("Levels: ${levels.toString()}");
      int ix = levels.indexWhere(
          (it) => it.toLowerCase() == value.toString().toLowerCase());
      debugPrint("Current Level: $currentLevel, index: $ix");
      debugPrint("Level: ${levels[0].toLowerCase()}, value: ${value!.toLowerCase()}, bool: ${levels[0].toLowerCase() == value.toLowerCase().trim()}");
      if (currentLevel + 1 == ix) {
        setState(() {
          stepNumber += 1;
          currentLevel = ix;
        });
        return;
      }
      showSnackBar(
          context, "buscheck_page.endoftrip_screen.unrecognized qr code".tr(),
          isSuccess: false);
    });
  }

  prevTask() {
    if (stepNumber == -1) return;
    if (showResume) {
      setState(() => showResume = false);
      return;
    }
    if (stepNumber == 0) {
      setState(() {
        currentLevel = -1;
        stepNumber = -1;
        showResume = false;
      });
      return;
    }
    openScanner((String? value) async {
      if (value == null) return;
      List<String> levels = busDetails!['type'] == 'DD' ? levelDD : levelSD;
      int ix = levels.indexWhere(
          (it) => it.toLowerCase() == value.toString().toLowerCase());
      if (currentLevel - 1 == ix) {
        setState(() {
          stepNumber -= 1;
          showResume = false;
          currentLevel = ix;
        });
        return;
      }
      showSnackBar(context, "Unrecognized QR code!", isSuccess: false);
    });
  }

  void toggleCheckAllItem() {
    if (stepNumber < 0) return;
    final checked = isRadioCheckedAll();
    setState(() {
      for (int i = 0; i < checklist[stepNumber].logs.length; i++) {
        checklist[stepNumber].logs[i].checked = !checked;
      }
    });
  }

  isRadioCheckedAll() {
    if (stepNumber < 0) return false;
    return checklist[stepNumber].logs.where((n) => n.checked != null && n.checked!).toList().length ==
        checklist[stepNumber].logs.length;
  }

  submitBusCheck() async {
    if (depotController.text == "") {
      return showSnackBar(
        context,
        "buscheck_page.endoftrip_screen.depot field alert message".tr(),
        isSuccess: false,
      );
    }
    if (plateController.text == "") {
      return showSnackBar(
        context,
        "buscheck_page.endoftrip_screen.bus plate number alert message".tr(),
        isSuccess: false,
      );
    }
    if (tripNumberController.text == "") {
      return showSnackBar(
        context,
        "buscheck_page.endoftrip_screen.trip number alert message".tr(),
        isSuccess: false,
      );
    }
    setState(() {
      _isSubmitting = true;
    });
    
    final res = await apiController.submitBusCheck(
      context: context,
      taskName: taskName,
      buscheckItems: checklist,
      plate: plateController.text,
      depot: depotController.text,
      tripNumber: tripNumberController.text,
    );
    if (!res) return;
    final hasRemarks = checklist
        .where((c) {
          return c.logs
              .where((l) {
                return l.remarks!.isNotEmpty ||
                    l.attachment1 != null ||
                    l.attachment2 != null;
              })
              .toList()
              .isNotEmpty;
        })
        .toList()
        .isNotEmpty;
    
    setState(() {
      _isSubmitting = false;
    });

    Navigator.of(context).pop();
    if (hasRemarks) {
      _showPopup(context);
    }
  }

  void _showPopup(BuildContext context) {
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
                        "buscheck_page.checklist_screen.${taskName.toLowerCase()}".tr(),
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
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
                  'buscheck_page.endoftrip_screen.alert message'.tr(),
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

  bool isImageLoading() {
    return stepNumber == -1 
      ? false 
      : checklist[stepNumber]
        .logs
        .where((BusCheckResponse item) => item.isLoading1! || item.isLoading2!)
        .toList().isNotEmpty;
  }

  @override
  Widget view(BuildContext context) {
    return CustomScaffold(
      bottomnavhide: true,
      body: Stack(
        children: [Container(
          color: ThemeColor.get(context).background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MasterLayout(
                child: Text(
                  "buscheck_page.checklist_screen.${taskName.toLowerCase()}".tr(),
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(
                    fontFamily: "Poppins-Bold",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          InputText(
                            label:
                                'buscheck_page.endoftrip_screen.bus plate number'
                                    .tr(),
                            controller: plateController,
                            value: plateNumber,
                            placeholder:
                                "buscheck_page.endoftrip_screen.bus plate number hint"
                                    .tr(),
                            type: TextInputType.text,
                            readOnly: true,
                            required: true,
                          ),
                          InputText(
                            label:
                                'buscheck_page.endoftrip_screen.trip number'.tr(),
                            placeholder:
                                "buscheck_page.endoftrip_screen.trip number hint"
                                    .tr(),
                            controller: tripNumberController,
                            value: tripNumberController.text,
                            readOnly: stepNumber >= 0,
                            type: TextInputType.text,
                            required: true,
                          ),
                          InputDropdown(
                            required: true,
                            label: 'buscheck_page.endoftrip_screen.depot'.tr(),
                            items: depotList,
                            value: null,
                            placeholder:
                                'buscheck_page.endoftrip_screen.depot hint'.tr(),
                            readOnly: stepNumber >= 0,
                            onChanged: (String? newValue) {
                              setState(() {
                                depotController.text = newValue!;
                              });
                            },
                          ),
                          showResume
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    Text(
                                      "$taskName Summary",
                                      textScaler: TextScaler.noScaling,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Poppins",
                                        fontSize: 18.0,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    showResumeWidget(checklist),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (checklist.isNotEmpty && stepNumber >= 0)
                                      Text(
                                        checklist[stepNumber].type,
                                        textScaler: TextScaler.noScaling,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Poppins",
                                          fontSize: 18.0,
                                        ),
                                      ),
                                    const SizedBox(height: 20),
                                    checklist.isNotEmpty && stepNumber >= 0
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              radioSelectAllWidget(
                                                isRadioCheckedAll(),
                                                toggleCheckAllItem,
                                              ),
                                              Column(
                                                children: stepNumber < 0
                                                    ? []
                                                    : checklist[stepNumber]
                                                        .logs
                                                        .asMap()
                                                        .entries
                                                        .map((entry) {
                                                        int idx = entry.key;
                                                        final currentList =
                                                            checklist[stepNumber];
                                                        final log =
                                                            currentList.logs[idx];
                                                        TextEditingController
                                                            logRemarkController =
                                                            remarkControllers
                                                                    .firstWhere((r) =>
                                                                        r['id'] ==
                                                                        log.id)[
                                                                'controller'];
                                                        return BusCheckComponent(
                                                          remarkController:
                                                              logRemarkController,
                                                          radioChanged:
                                                              (bool? value) {
                                                            setState(() {
                                                              checklist[stepNumber].logs[idx].checked = 
                                                                checklist[stepNumber].logs[idx].checked != null
                                                                  ? !checklist[stepNumber].logs[idx].checked! 
                                                                  : true;
                                                            });
                                                          },
                                                          remarkChanged:
                                                              (String rm) {
                                                            setState(() {
                                                              checklist[
                                                                      stepNumber]
                                                                  .logs[idx]
                                                                  .remarks = rm;
                                                            });
                                                          },
                                                          pickImage1: (File?
                                                                  file,
                                                              String?
                                                                  path) async {
                                                            setState(() {
                                                              checklist[stepNumber]
                                                                      .logs[idx]
                                                                      .attachment1 =
                                                                  file;
                                                              checklist[stepNumber]
                                                                      .logs[idx]
                                                                      .attachmentPath1 =
                                                                  path;
                                                            });
                                                          },
                                                          pickImage2: (File?
                                                                  file,
                                                              String?
                                                                  path) async {
                                                            setState(() {
                                                              checklist[stepNumber]
                                                                      .logs[idx]
                                                                      .attachment2 =
                                                                  file;
                                                              checklist[stepNumber]
                                                                      .logs[idx]
                                                                      .attachmentPath2 =
                                                                  path;
                                                            });
                                                          },
                                                          isLoadingImage1: (bool isLoading) {
                                                            setState(() {
                                                               checklist[stepNumber]
                                                                .logs[idx]
                                                                .isLoading1 = isLoading;
                                                            });
                                                          },
                                                          isLoadingImage2: (bool isLoading) {
                                                            setState(() {
                                                              checklist[stepNumber]
                                                                .logs[idx]
                                                                .isLoading2 = isLoading;
                                                            });
                                                          },
                                                          log: log,
                                                        );
                                                      }).toList(),
                                              ),
                                            ],
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (_isSubmitting) ...[
            ModalBarrier(
              dismissible: false,
              color: Colors.black.withOpacity(0.3),
            ),
          const Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ]
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        decoration: BoxDecoration(color: ThemeColor.get(context).background),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (isImageLoading() || _isSubmitting) return;
                  if (stepNumber < 0) {
                    Navigator.of(context).pop();
                  } else {
                    prevTask();
                  }
                },
                style: ButtonStyle(
                  side: WidgetStateProperty.all(
                      BorderSide(color: nyHexColor("CBD0DC"))),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                  padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 16)),
                ),
                child: Text(
                  stepNumber < 0
                      ? "buscheck_page.endoftrip_screen.button cancel".tr()
                      : "buscheck_page.endoftrip_screen.button previous".tr(),
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontFamily: 'Poppins-Regular',
                    fontWeight: FontWeight.w500,
                    color: ThemeColor.get(context).primaryContent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GeneralButton(
                disabled: isImageLoading() || _isSubmitting,
                text: (showResume || checklist.isEmpty)
                    ? "buscheck_page.endoftrip_screen.button submit".tr()
                    : "buscheck_page.endoftrip_screen.button next".tr(),
                onPressed: () async {
                  bool allowSubmit = showResume;
                  if (checklist.isEmpty) allowSubmit = true;
                  if (allowSubmit) {
                    await submitBusCheck();
                    return;
                  }
                  nextTask();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get isThemeDark =>
      ThemeProvider.controllerOf(context).currentThemeId ==
      getEnv('DARK_THEME_ID');
}

Widget radioSelectAllWidget(
  bool isCheckedAll,
  Function toggleCheckAllItem,
) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: Row(
          children: [
            Radio<bool?>(
              value: true,
              groupValue: isCheckedAll,
              toggleable: true,
              onChanged: (bool? value) {
                toggleCheckAllItem();
              },
              visualDensity:
                  const VisualDensity(horizontal: -4.0, vertical: -4.0),
            ),
            Flexible(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          'buscheck_page.endoftrip_screen.select all'.tr(),
                          textScaler: TextScaler.noScaling,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
    ],
  );
}

Widget showResumeWidget(List<BusCheckItem> items) {
  return SizedBox(
    child: Column(
      children: items.map((item) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: item.logs.asMap().entries.map((entry) {
            final log = item.logs[entry.key];
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black12,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(log.description, textScaler: TextScaler.noScaling,) ,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: log.attachment1 != null
                                ? Colors.blue
                                : Colors.transparent,
                          ),
                        ),
                        width: 60,
                        height: 60,
                        child: log.attachment1 != null
                            ? Image.file(log.attachment1!)
                            : const SizedBox(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "buscheck_page.endoftrip_screen.remarks".tr(),
                              textScaler: TextScaler.noScaling,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(log.remarks!.isEmpty
                                      ? '-'
                                      : log.remarks!,
                                      textScaler: TextScaler.noScaling,
                                    ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: log.attachment2 != null
                                ? Colors.blue
                                : Colors.transparent,
                          ),
                        ),
                        width: 60,
                        height: 60,
                        child: log.attachment2 != null
                            ? Image.file(log.attachment2!)
                            : const SizedBox(),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      }).toList(),
    ),
  );
}
