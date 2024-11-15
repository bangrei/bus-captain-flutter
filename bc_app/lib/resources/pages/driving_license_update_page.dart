import 'dart:convert';
import 'dart:io';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/driving_license.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:bc_app/resources/widgets/components/image_photo_picker_widget.dart';
import 'package:bc_app/resources/widgets/components/input_date_widget.dart';
import 'package:bc_app/resources/widgets/components/input_text_widget.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nylo_framework/nylo_framework.dart';

class DrivingLicenseUpdatePage extends NyStatefulWidget {
  static const path = '/driving-license-update';

  DrivingLicenseUpdatePage({super.key})
      : super(path, child: _DrivingLicenseUpdatePageState());
}

class _DrivingLicenseUpdatePageState extends NyState<DrivingLicenseUpdatePage> {
  bool onLoading = false;
  bool onSaving = false;
  ApiController apiController = ApiController();
  DrivingLicense? currLicense;
  DateTime? issueDate;
  DateTime? expiryDate;
  List<String>? drivingLicenseTypes;
  File? imgFront;
  File? imgBack;

  final bcIdController = TextEditingController();
  final driverNameController = TextEditingController();
  final imgBackController = TextEditingController();
  final imgFrontController = TextEditingController();
  final selectedLicenseTypeController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    bcIdController.dispose();
    driverNameController.dispose();
    imgBackController.dispose();
    imgFrontController.dispose();
    selectedLicenseTypeController.dispose();
  }

  @override
  init() async {}

  /// Use boot if you need to load data before the [view] is rendered.
  @override
  boot() async {
    // String langPref = await NyStorage.read<String>('languagePref') ?? '';
    // changeLanguage(langPref);
    Map data =
        (ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>);
    setState(() {
      currLicense = data['drivingLicense'] as DrivingLicense;
      bcIdController.text = data['bcId'] ?? '-';
      driverNameController.text = data['name'] ?? '-';
      drivingLicenseTypes = currLicense!.drivingLicenseTypes;
      expiryDate = currLicense!.expiryDate;
      issueDate = currLicense!.issueDate;
    });
  }

  saveLicense(BuildContext context) async {
    if (onSaving == true) return;

    if (!_noDataChange()) {
      return;
    }
    setState(() => onSaving = true);
    List<int> ids = currLicense!.items.map((it) => it.id).toList();
    final res = await apiController.onRenewDrivingLicense(
        expiryDate: DateFormat('yyyy-MM-dd').format(expiryDate!),
        issueDate: DateFormat('yyyy-MM-dd').format(issueDate!),
        imgFront: imgFront,
        imgBack: imgBack,
        licenseIds: ids);
    setState(() => onSaving = false);
    final json = jsonDecode(res);
    final message = json['message'] ?? '';
    showSnackBar(
      context,
      json['success'] == true ? 'Successfully saved!' : message,
      isSuccess: json['success'] == true,
    );
    if (json['success']) {
      Navigator.pop(context);
    }
  }

  bool _noDataChange() {
    // Validate Driving License renewal form
    if (expiryDate == null) {
      showSnackBar(
          context,
          "user_profile.driving_license_screen.expiry date field alert message"
              .tr(),
          isSuccess: false);
      return false;
    }

    if (issueDate == null) {
      showSnackBar(
          context,
          "user_profile.driving_license_screen.issue date field alert message"
              .tr(),
          isSuccess: false);
      return false;
    }

    if (imgFront == null && imgFrontController.text == '') {
      showSnackBar(
          context,
          "user_profile.driving_license_screen.front image field alert message"
              .tr(),
          isSuccess: false);
      return false;
    }

    if (imgBack == null && imgBackController.text == '') {
      showSnackBar(
          context,
          "user_profile.driving_license_screen.back image field alert message"
              .tr(),
          isSuccess: false);
      return false;
    }

    return true;
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: TitleBar(
          title: "user_profile.driving_license_screen.title update".tr()),
      body: SafeArea(
        child: SingleChildScrollView(
          child: MasterLayout(
            child: Column(
              children: [
                SizedBox(
                  child: Column(
                    children: [
                      InputText(
                        label: "user_profile.driving_license_screen.bcid".tr(),
                        type: TextInputType.text,
                        value: bcIdController.text,
                        controller: bcIdController,
                        required: false,
                        editable: false,
                        readOnly: true,
                      ),
                      InputText(
                        label: "user_profile.driving_license_screen.name".tr(),
                        type: TextInputType.text,
                        value: driverNameController.text,
                        controller: driverNameController,
                        required: false,
                        editable: false,
                        readOnly: true,
                      ),
                      InputText(
                        label:
                            "user_profile.driving_license_screen.license type"
                                .tr(),
                        type: TextInputType.text,
                        value: drivingLicenseTypes!.join(", "),
                        required: false,
                        editable: false,
                        readOnly: true,
                      ),
                      InputDate(
                        label: "user_profile.driving_license_screen.issue date"
                            .tr(),
                        required: true,
                        value: issueDate,
                        dateFormat: 'dd/MM/yyyy',
                        onDateChanged: (DateTime? value) {
                          setState(() {
                            issueDate = value!;
                          });
                        },
                      ),
                      InputDate(
                        label: "user_profile.driving_license_screen.expiry date"
                            .tr(),
                        required: true,
                        value: expiryDate,
                        dateFormat: 'dd/MM/yyyy',
                        onDateChanged: (DateTime? value) {
                          setState(() {
                            expiryDate = value!;
                          });
                        },
                      ),
                      PhotoPicker(
                        label:
                            "user_profile.driving_license_screen.front license"
                                .tr(),
                        required: true,
                        callback: (file) async {
                          imgFront = file;
                          imgFrontController.text =
                              await convertFileToStringBase64(file);
                        },
                      ),
                      const SizedBox(height: 20),
                      PhotoPicker(
                        label:
                            "user_profile.driving_license_screen.back license"
                                .tr(),
                        required: true,
                        callback: (file) async {
                          imgBack = file;
                          imgBackController.text =
                              await convertFileToStringBase64(file);
                        },
                      ),
                      GeneralButton(
                        text: "user_profile.driving_license_screen.button".tr(),
                        showLoading: onSaving,
                        disabled: onSaving,
                        onPressed: () async {
                          await saveLicense(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
