import 'dart:io';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/controllers/home_controller.dart';
import 'package:bc_app/app/models/bus_check_item.dart';
import 'package:bc_app/app/models/bus_check_response.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/bus_check_page.dart';
import 'package:bc_app/resources/pages/home_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/bus_check_component.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:bc_app/resources/widgets/components/input_dropdown_widget.dart';
import 'package:bc_app/resources/widgets/components/input_text_widget.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';
import 'package:bc_app/resources/widgets/custom_scaffold_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ParadeTasksPage extends NyStatefulWidget<HomeController> {
  static const path = '/parade-tasks';

  ParadeTasksPage({super.key}) : super(path, child: _ParadeTasksPageState());
}

class _ParadeTasksPageState extends NyState<ParadeTasksPage> {
  bool onLoading = false;
  ApiController apiController = ApiController();
  String taskName = "";
  String plateNumber = "";
  List<BusCheckItem> checklist = [];
  List<String> depotList = [];
  List<String> mandatory = [
    "First Parade Duties",
    "Bus Exterior Check",
    "Bus Interior Check",
    "Last Parade Duties",
  ];
  int stepNumber = 0;
  TextEditingController plateController = TextEditingController();
  TextEditingController depotController = TextEditingController();
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
    List<BusCheckResponse> declarationChecklist = await myBCDelarations();
    bool storageDeclared = declarationChecklist.toList().isNotEmpty;
    List<String> depots = await apiController.getDepotList(context);
    if (storageDeclared) {
      res = res.toList().where((it) {
        return it.type.toLowerCase() != "declaration";
      }).toList();
    }
    setState(() {
      taskName = task;
      plateNumber = result;
      plateController.text = plateNumber;
      checklist = res;
      depotList = depots.toList();
    });
    generateRemarkControllers();
  }

  generateRemarkControllers() {
    if (checklist.isEmpty) return;
    final items = checklist.where((it) {
      return mandatory
              .toList()
              .indexWhere((m) => m.toLowerCase() == it.type.toLowerCase()) >=
          0;
    });
    if (items.isEmpty) return;
    for (final item in items) {
      for (final log in item.logs) {
        remarkControllers
            .add({"id": log.id, "controller": TextEditingController()});
      }
    }
  }

  List<int> steps() {
    List<int> numbers = [];
    for (int i = 0; i < checklist.length; i++) {
      numbers.add(i);
    }
    return numbers;
  }

  isLastOne() {
    return stepNumber + 1 == checklist.length;
  }

  nextTask() {
    if (isLastOne()) return;
    if (stepNumber == 0) {
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
    }
    if (isWithAction() && !isRadioCheckedAll()) {
      return showSnackBar(
        context,
        "buscheck_page.endoftrip_screen.check all alert message".tr(),
        isSuccess: false,
      );
    }
    if (!isWithAction()) {
      setState(() {
        checklist[stepNumber].logs.map((it) {
          it.checked = true;
          return it;
        });
      });
    }
    setState(() => stepNumber += 1);
  }

  prevTask() {
    if (stepNumber - 1 < 0) return;
    setState(() => stepNumber -= 1);
  }

  void toggleCheckAllItem() {
    final checked = isRadioCheckedAll();
    setState(() {
      for (int i = 0; i < checklist[stepNumber].logs.length; i++) {
        checklist[stepNumber].logs[i].checked = !checked;
      }
    });
  }

  isWithAction() {
    return mandatory.toList().indexWhere((m) =>
            m.toLowerCase() == checklist[stepNumber].type.toLowerCase()) >=
        0;
  }

  isRadioCheckedAll() {
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
    if (isWithAction() && !isRadioCheckedAll()) {
      return showSnackBar(
        context,
        "buscheck_page.endoftrip_screen.check all alert message".tr(),
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
      tripNumber: "",
    );
    if (!res) return;
    final hasRemarksOrAttachments = checklist.where((it) {
      return it.logs.where((log) {
        return log.remarks!.isNotEmpty ||
            log.attachment1 != null ||
            log.attachment2 != null;
      }).isNotEmpty;
    }).isNotEmpty;

    setState(() {
      _isSubmitting = false;
    });
     routeTo(BusCheckPage.path,
          navigationType: NavigationType.pushAndRemoveUntil,
            removeUntilPredicate: ModalRoute.withName(HomePage.path),
            pageTransition: PageTransitionType.leftToRight
        );
    if (hasRemarksOrAttachments) {
      _showInfo(context, taskName);
    }
  }

  bool isImageLoading() {
    return checklist[stepNumber]
          .logs
          .where((BusCheckResponse item) => item.isLoading1! || item.isLoading2!)
          .toList().isNotEmpty;
  }

  @override
  Widget view(BuildContext context) {
    return CustomScaffold(
      bottomnavhide: true,
      body: Stack(
        children: [
          Container(
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
                            checklist.length <= 2
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 24.0,
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              height: 1.5,
                                              decoration: const BoxDecoration(
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: steps().map((step) {
                                            return GestureDetector(
                                              onTap: () {
                                                if (step > stepNumber) nextTask();
                                                if (step < stepNumber) prevTask();
                                              },
                                              child: Container(
                                                width: 40.0,
                                                height: 40.0,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadiusDirectional
                                                          .circular(20),
                                                  color: stepNumber == step
                                                      ? Colors.blue
                                                      : Colors.white,
                                                  border: Border.all(
                                                    color: stepNumber == step
                                                        ? Colors.transparent
                                                        : Colors.blue,
                                                  ),
                                                ),
                                                child: step < stepNumber
                                                    ? const Icon(
                                                        Icons.check,
                                                        color: Colors.blue,
                                                      )
                                                    : Text(
                                                        (step + 1).toString(),
                                                        textScaler: TextScaler.noScaling,
                                                        style: TextStyle(
                                                          color: stepNumber == step
                                                              ? Colors.white
                                                              : Colors.blue,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14.0,
                                                        ),
                                                      ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                            const SizedBox(height: 20),
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
                            InputDropdown(
                              required: true,
                              label: 'buscheck_page.endoftrip_screen.depot'.tr(),
                              items: depotList,
                              value: null,
                              placeholder:
                                  'buscheck_page.endoftrip_screen.depot hint'.tr(),
                              readOnly: stepNumber > 0,
                              onChanged: (String? newValue) {
                                setState(() {
                                  depotController.text = newValue!;
                                });
                              },
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (checklist.isNotEmpty)
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
                                checklist.isNotEmpty
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          radioSelectAllWidget(
                                            isWithAction(),
                                            isRadioCheckedAll(),
                                            toggleCheckAllItem,
                                          ),
                                          Column(
                                            children: checklist[stepNumber]
                                                .logs
                                                .asMap()
                                                .entries
                                                .map((entry) {
                                              int idx = entry.key;
                                              int no = idx + 1;
                                              final currentList =
                                                  checklist[stepNumber];
                                              final log = currentList.logs[idx];
                                              if (!isWithAction()) {
                                                return noActionWidget(log, no);
                                              }
                                              TextEditingController
                                                  logRemarkController =
                                                  remarkControllers.firstWhere(
                                                          (r) => r['id'] == log.id)[
                                                      'controller'];
                                              return BusCheckComponent(
                                                remarkController:
                                                    logRemarkController,
                                                radioChanged: (bool value) {
                                                  setState(() {
                                                    checklist[stepNumber].logs[idx].checked = 
                                                      checklist[stepNumber].logs[idx].checked != null
                                                        ? !checklist[stepNumber].logs[idx].checked! 
                                                        : true;
                                                  });
                                                },
                                                remarkChanged: (String rm) {
                                                  setState(() {
                                                    checklist[stepNumber]
                                                        .logs[idx]
                                                        .remarks = rm;
                                                  });
                                                },
                                              pickImage1:
                                                  (File? file, String? path) {
                                                  setState(() {
                                                    checklist[stepNumber]
                                                        .logs[idx]
                                                      .attachment1 = file;
                                                  checklist[stepNumber]
                                                      .logs[idx]
                                                      .attachmentPath1 = path;
                                                  });
                                                },
                                              pickImage2:
                                                  (File? file, String? path) {
                                                  setState(() {
                                                    checklist[stepNumber]
                                                        .logs[idx]
                                                      .attachment2 = file;
                                                  checklist[stepNumber]
                                                      .logs[idx]
                                                      .attachmentPath2 = path;
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
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
        decoration: BoxDecoration(color: ThemeColor.get(context).background),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (isImageLoading() ||  _isSubmitting) return;
                  if (stepNumber == 0) {
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
                  stepNumber == 0
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
            const SizedBox(width: 5),
            Expanded(
              child: GeneralButton(
                disabled: isImageLoading() || _isSubmitting,
                text:
                    ((stepNumber == checklist.length - 1) || checklist.isEmpty)
                    ? "buscheck_page.endoftrip_screen.button submit".tr()
                        : isWithAction()
                        ? ("buscheck_page.endoftrip_screen.button next".tr())
                        : "buscheck_page.endoftrip_screen.button acknowledge"
                            .tr(),
                onPressed: () async {
                  bool allowSubmit = stepNumber == checklist.length - 1;
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
  bool withAction,
  bool isCheckedAll,
  Function toggleCheckAllItem,
) {
  if (!withAction) return const SizedBox();
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

Widget noActionWidget(BusCheckResponse log, int no) {
  return Padding(
    padding: const EdgeInsets.only(
      bottom: 16.0,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20.0,
          child: Text("${no.toString()}.", textScaler: TextScaler.noScaling,),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          flex: 4,
          child: Text(
            log.description,
            textScaler: TextScaler.noScaling,
          ),
        ),
      ],
    ),
  );
}

void _showInfo(BuildContext context, String title) {
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
                      "buscheck_page.checklist_screen.${title.toLowerCase()}".tr(),
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
