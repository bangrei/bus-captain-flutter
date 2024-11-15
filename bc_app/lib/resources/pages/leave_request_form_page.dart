import 'dart:io';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:bc_app/resources/widgets/components/image_photo_picker_widget.dart';
import 'package:bc_app/resources/widgets/components/input_date_range_widget.dart';
import 'package:bc_app/resources/widgets/components/input_text_area_widget.dart';
import 'package:bc_app/resources/widgets/safearea_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:bc_app/resources/widgets/components/input_dropdown_widget.dart';

class LeaveRequestFormPage extends NyStatefulWidget {
  static const path = '/leave-request-form';

  LeaveRequestFormPage({super.key})
      : super(path, child: _LeaveRequestFormPageState());
}

class _LeaveRequestFormPageState extends NyState<LeaveRequestFormPage> {
  String? _selectedLeaveType;
  String? _selectedLeaveDayType;
  DateTime? _fromDate;
  DateTime? _toDate;
  bool onLoading = false;
  List<String> leaveTypes = [];

  // State
  bool isLeaveDayTypeRequired =
      true; // Track if Full Day / AM / PM dropdown needs to be shown
  bool isSupportingDocsRequired = true;
  File? attachment;
  TextEditingController reasonController = TextEditingController();
  ApiController apiController = ApiController();

  @override
  boot() async {
    setState(() => onLoading = true);
    String langPref = await NyStorage.read<String>('languagePref') ?? '';
    changeLanguage(langPref);
    getLeaveTypes();
    setState(() => onLoading = false);
  }

  getLeaveTypes() async {
    final types = await apiController.getLeaveTypes(context);
    setState(() {
      leaveTypes = types;
      leaveTypes.sort((a, b) {
        return a.toLowerCase().compareTo(b.toLowerCase());
      });
    });
  }

  // Function / Method
  _handleLeaveTypeChange(String? newValue) {
    setState(() {
      _selectedLeaveType = newValue!;
      isLeaveDayTypeRequired = true;
      isSupportingDocsRequired = true;
      
      if (newValue == 'Annual Leave 年假') {
        isLeaveDayTypeRequired = true;
        isSupportingDocsRequired = false;
      } else {
        isLeaveDayTypeRequired = false;
        isSupportingDocsRequired = true;
      }
      
    });
  }

  Widget _buildLeaveBalanceItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          textScaler: TextScaler.noScaling,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          textScaler: TextScaler.noScaling,
          style: TextStyle(
            fontSize: 12,
            color: nyHexColor("1570EF"),
          ),
        ),
      ],
    );
  }

  bool _validateForm() {
    //Check if leave type is filled
    if (_selectedLeaveType == null) {
      showSnackBar(context, 'leave_request_page.new_leave_screen.leave type field alert message'.tr(), isSuccess: false);
      return false;
    }
    //Check if from date is filled
    if (_fromDate == null) {
      showSnackBar(context, 'leave_request_page.new_leave_screen.from date field alert message'.tr(), isSuccess: false);
      return false;
    }
    //Check if toDate is filled
    if (_toDate == null) {
      showSnackBar(context, 'leave_request_page.new_leave_screen.to date field alert message'.tr(), isSuccess: false);
      return false;
    }

    //Check if fromDate and toDate is valid
    if (_fromDate!.isAfter(_toDate!)) {
      showSnackBar(context, 'leave_request_page.new_leave_screen.from date cannot be after to date alter message'.tr(),
          isSuccess: false);
      return false;
    }

    // Check if leave day type is filled when applicable
    // if (isLeaveDayTypeRequired && _selectedLeaveDayType == '') {
    //   showSnackBar(context, 'Please select Full day/AM/PM', isSuccess: false);
    //   return false;
    // }
    // Check if supporting docs is filled when applicable
    if (isSupportingDocsRequired && attachment == null) {
      showSnackBar(context, 'leave_request_page.new_leave_screen.support docs field alert message'.tr(),
          isSuccess: false);
      return false;
    }

    return true;
  }

  applyLeave(BuildContext context) async {
    if (onLoading) return;

    // Perform form validation
    if (!_validateForm()) return;

    setState(() => onLoading = true);
    final success = await apiController.onApplyLeave(
      context: context,
      type: _selectedLeaveType!,
      startDate: stringifyDate(_fromDate),
      endDate: stringifyDate(_toDate),
      // amOrPm: isLeaveDayTypeRequired ? _selectedLeaveDayType : '',
      reason: reasonController.text,
      attachment: isSupportingDocsRequired ? attachment : null,
    );
    setState(() => onLoading = false);
    if (success) Navigator.pop(context, 'update');
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: TitleBar(title: "leave_request_page.new_leave_screen.title".tr()),
      body: SafeAreaWidget(
        child: SingleChildScrollView(
          // Wrap with SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputDropdown(
                label: 'leave_request_page.new_leave_screen.leave type'.tr(),
                value: _selectedLeaveType,
                items: leaveTypes,
                onChanged: _handleLeaveTypeChange,
                placeholder: 'leave_request_page.new_leave_screen.leave type hint'.tr(),
              ),
              const SizedBox(height: 16),
              // Container(
              //   width: double.infinity,
              //   decoration: BoxDecoration(
              //     color: const Color(0xFFE4F0F1),
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   padding: const EdgeInsets.all(16),
                // child: Column(
                //   crossAxisAlignment: CrossAxisAlignment.center,
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                    // Text(
                    //   'leave_request_page.new_leave_screen.leave balance'.tr(),
                    //   style: const TextStyle(
                    //     fontSize: 20,
                    //     fontFamily: "Poppins-Bold",
                    //   ),
                    // ),
                    // const SizedBox(height: 10),
                    // SingleChildScrollView(
                    //   scrollDirection: Axis.horizontal,
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //     children: [
                    //       Container(
                    //         width: 90,
                    //         padding: const EdgeInsets.only(right: 4),
                    //         child: _buildLeaveBalanceItem(
                    //             'leave_request_page.new_leave_screen.leave type'
                    //                 .tr(),
                    //             _selectedLeaveType ?? '-'),
                    //       ),
                    //       Container(
                    //         width: 120,
                    //         padding: const EdgeInsets.only(right: 4),
                    //         child: _buildLeaveBalanceItem(
                    //             'leave_request_page.new_leave_screen.entitlement'
                    //                 .tr(),
                    //             '20'),
                    //       ),
                    //       Container(
                    //         width: 100,
                    //         padding: const EdgeInsets.only(right: 4),
                    //         child: _buildLeaveBalanceItem(
                    //             'leave_request_page.new_leave_screen.taken'
                    //                 .tr(),
                    //             '5'),
                    //       ),
                    //       Container(
                    //         width: 110,
                    //         padding: const EdgeInsets.only(right: 4),
                    //         child: _buildLeaveBalanceItem(
                    //             'leave_request_page.new_leave_screen.available'
                    //                 .tr(),
                    //             '15'),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  // ],
              //   ),
              // ),
              const SizedBox(height: 16),
              InputDateRange(
                labelFrom: 'leave_request_page.new_leave_screen.from'.tr(),
                labelTo: 'leave_request_page.new_leave_screen.to'.tr(),
                fromDate: _fromDate,
                toDate: _toDate,
                onFromChanged: (DateTime? value) {
                  setState(() {
                    _fromDate = value;
                  });
                },
                onToChanged: (DateTime? value) {
                  setState(() {
                    _toDate = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // if (isLeaveDayTypeRequired) ...[
              //   Text(
              //     'leave_request_page.new_leave_screen.full day'.tr(),
              //     style: const TextStyle(
              //         fontSize: 16, fontWeight: FontWeight.bold),
              //   ),
              //   const SizedBox(height: 8),
              //   InputDropdown(
              //     value: _selectedLeaveDayType,
              //     items: const ['Full Day', 'AM', 'PM'],
              //     onChanged: (newValue) {
              //       setState(() {
              //         _selectedLeaveDayType = newValue;
              //       });
              //     },
              //     hintText: 'Full Day / AM / PM',
              //   ),
              // ],
              // const SizedBox(height: 16),
              InputTextArea(
                label: 'leave_request_page.new_leave_screen.reason'.tr(),
                placeholder: 'leave_request_page.new_leave_screen.reason hint'.tr(),
                textarea: true,
                controller: reasonController,
              ),
              // Text(
              //   'leave_request_page.new_leave_screen.reason'.tr(),
              //   style:
              //       const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              // ),
              // Container(
              //   margin: const EdgeInsets.symmetric(vertical: 8),
              //   padding: const EdgeInsets.all(8),
              //   decoration: BoxDecoration(
              //     border: Border.all(color: Colors.grey),
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   child: InputTextArea(
              //     textarea: true,
              //     // minLines: 3, // Set minimum number of lines
              //     // maxLines: null, // Allows the text area to expand vertically
              //     // decoration: InputDecoration.collapsed(
              //       hintText:
              //           'leave_request_page.new_leave_screen.reason hint'.tr(),
              //       hintStyle: const TextStyle(
              //         color: Color(0xFF666666),
              //       ), // Change the color here
              //     controller: reasonController,
              //     ),
              //   ),
              // ),
              const SizedBox(height: 16),
              if (isSupportingDocsRequired)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: PhotoPicker(
                    label: "leave_request_page.new_leave_screen.supporting doc"
                        .tr(),
                    required: true,
                    callback: (file) async {
                      setState(() {
                        attachment = file;
                      });
                    },
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: GeneralButton(
                  text: "leave_request_page.new_leave_screen.button".tr(),
                  disabled: onLoading == true,
                  showLoading: onLoading == true,
                  onPressed: () {
                    applyLeave(context);
                  },
                ),
              )
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: true, // Enable keyboard pushing
    );
  }
}
