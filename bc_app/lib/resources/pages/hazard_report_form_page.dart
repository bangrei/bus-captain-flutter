import 'dart:io';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:bc_app/resources/widgets/components/input_dropdown_widget.dart';
import 'package:bc_app/resources/widgets/components/input_text_widget.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nylo_framework/nylo_framework.dart';

class HazardReportFormPage extends NyStatefulWidget {
  static const path = '/hazard-report-form';

  HazardReportFormPage({super.key}) : super(path, child: _HazardReportFormPageState());
}

class _HazardReportFormPageState extends NyState<HazardReportFormPage> {
  String? selectedLocation;

  final TextEditingController _descController = TextEditingController();
  final TextEditingController _otherController = TextEditingController();
  List<String> depotList = [];
  int maxDocuments = 5;
  List<File> supportDocuments = [];
  ApiController apiController = ApiController();

  @override
  void dispose() {
    super.dispose();
    _descController.dispose();
    _otherController.dispose();
  }

  @override
  init() async {}

  /// Use boot if you need to load data before the [view] is rendered.
  @override
  boot() async {
    List<String> depots = await apiController.getDepotList(context);
    if (depots.isNotEmpty) {
      depots.add("Others");
    }
    setState(() {
      depotList = depots.toList();
    });
  }

  DropdownMenuItem<String> _buildDropdownMenu(String item) {
    return DropdownMenuItem(value: item, child: Text(item, textScaler: TextScaler.noScaling,));
  }

  pickImage({
    String source = "gallery",
    required Function(File?) callback,
  }) async {
    try {
      await ImagePicker()
          .pickImage(
              source:
                  source == "camera" ? ImageSource.camera : ImageSource.gallery)
          .then((value) async {
        if (value == null) return callback(null);
        File imageTemp = File(value.path);
        imageTemp = await compute(compressImage, imageTemp);
        callback(imageTemp);
      });
    } on PlatformException catch (e) {
      final msg = 'Failed to pick image: $e';
      showSnackBar(context, msg);
      callback(null);
    }
  }

  _handleOnSubmitReportHazard() async {
    if (!_validatedFields()) return;
    if (isLoading(name: "hazard_loading")) return;

    setLoading(true, name: "hazard_loading");
    String loc = selectedLocation!;
    if (selectedLocation == "Others") loc = _otherController.text;
    final res = await apiController.submitReportHazard(
      context: context,
      description: _descController.text,
      location: loc,
      documents: supportDocuments,
      others: _otherController.text,
    );
    setLoading(false, name: "hazard_loading");
    if (res) {
      Navigator.pop(context, 'update');
    }
  }

  _handleDropdownMenuChange(String? value) {
    setState(() {
      selectedLocation = value;
    });
  }

  bool _validatedFields() {
    //Check if description is filled
    if (_descController.text == '') {
      showSnackBar(context, "hazard_report_form_page.description required".tr(),
          isSuccess: false);
      return false;
    }

    //Check if any location is selected
    if (selectedLocation == null) {
      showSnackBar(context, "hazard_report_form_page.location required".tr(),
          isSuccess: false);
      return false;
    }

    if (selectedLocation == 'Others' && _otherController.text == '') {
      showSnackBar(context, "hazard_report_form_page.others required".tr(),
          isSuccess: false);
      return false;
    }
    // if (supportDocuments.isEmpty) {

    //   showSnackBar(context, "hazard_report_form_page.supporting docs required".tr(),
    //       isSuccess: false);
    //   return false;
    // }
    return true;
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: TitleBar(title: 'hazard_report_form_page.title'.tr()),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InputText(
                      label: "hazard_report_form_page.description".tr(),
                      placeholder: "hazard_report_form_page.description hint".tr(),
                      required: true,
                      maxLength: 100,
                      maxLines: 3,
                      // expands: true,
                      // maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      // inputFormatters: [LengthLimitingTextInputFormatter(100)],
                      controller: _descController,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 10),
                    InputDropdown(
                      required: true,
                      label: "hazard_report_form_page.location".tr(),
                      items: depotList,
                      value: null,
                      placeholder: "hazard_report_form_page.location hint".tr(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedLocation = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    if (selectedLocation == "Others") ...[
                      InputText(
                        label: "hazard_report_form_page.others".tr(),
                        controller: _otherController,
                      ),
                      const SizedBox(height: 20),
                    ],
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "hazard_report_form_page.supporting documents".tr(),
                              textScaler: TextScaler.noScaling,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            // Text(
                            //   "*${"user_profile.driving_license_screen.required".tr()}",
                            //   style: const TextStyle(
                            //     color: Colors.red,
                            //     fontStyle: FontStyle.italic,
                            //   ),
                            // )
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Wrap(
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          runSpacing: 24,
                          spacing: 24,
                          children: List.generate(
                              supportDocuments.length < 5
                                  ? supportDocuments.length + 1
                                  : supportDocuments.length, (int index) {
                            return GestureDetector(
                              onTap: () async {
                                if (index < supportDocuments.length) return;
                                await showSourceOptions(context,
                                    (String? source) async {
                                  setLoading(true, name: "pickImage");
                                  await pickImage(
                                      source: source!,
                                      callback: (File? file) async {
                                        setLoading(false, name: "pickImage");
                                        if (file != null) {
                                          setState(() {
                                            supportDocuments.add(file);
                                          });
                                        }
                                      });
                                });
                              },
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: index < supportDocuments.length
                                    ? Stack(
                                        alignment: AlignmentDirectional.center,
                                        children: [
                                          Image.file(supportDocuments[index]),
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    supportDocuments
                                                        .removeAt(index);
                                                  });
                                                },
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(6),
                                        child: isLoading(name: "pickImage")
                                            ? Center(
                                                child: Text(
                                                  'loading'.tr(),
                                                  textScaler: TextScaler.noScaling,
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                            : const Icon(
                                                Icons.add,
                                                color: Colors.grey,
                                                size: 32,
                                              ),
                                      ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                    // SizedBox(height:300),
                    SizedBox(
                      // alignment: Alignment.bottomCenter,
                      width: double.infinity,
                      child: GeneralButton(
                        text: "hazard_report_form_page.button".tr(),
                        onPressed: _handleOnSubmitReportHazard,
                        disabled: isLoading(name: "hazard_loading") || isLoading(name:"pickImage"),
                        showLoading: isLoading(name: "hazard_loading"),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future showSourceOptions(
    BuildContext context, Function(String?) callbackResult) async {
  showCupertinoModalPopup(
    context: context,
    builder: (context) => CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          child: Text('hazard_report_form_page.photo gallery'.tr(), textScaler: TextScaler.noScaling,),
          onPressed: () async {
            Navigator.of(context).pop();
            callbackResult('gallery');
          },
        ),
        CupertinoActionSheetAction(
          child: Text('hazard_report_form_page.camera'.tr(), textScaler: TextScaler.noScaling,),
          onPressed: () async {
            Navigator.of(context).pop();
            callbackResult('camera');
          },
        ),
      ],
    ),
  );
}
