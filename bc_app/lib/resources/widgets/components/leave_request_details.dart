import 'package:bc_app/app/models/leave_request.dart';
import 'package:bc_app/app/networking/api_service.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LeaveRequestDetails extends StatelessWidget {
  final LeaveRequest item;
  final String baseUrl = ApiService().baseUrl;
  LeaveRequestDetails({
    super.key,
    required this.item,
  });



  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(40.0),
        topRight: Radius.circular(40.0),
      ),
      child: Container(
        padding: const EdgeInsets.only(
          top: 30.0,
          left: 16.0,
          right: 16.0,
          bottom: 16.0,
        ),
        color: ThemeColor.get(context).background,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'leave_request_page.details_popup.title'.tr(),
                textScaler: TextScaler.noScaling,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: "Poppins-Bold",
                ),
              ),
              const Divider(
                color: Color(0xFFF6F6F6),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'leave_request_page.details_popup.leave type'.tr(),
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      item.leaveType,
                      textScaler: TextScaler.noScaling,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const Divider(
                color: Color(0xFFF6F6F6),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'leave_request_page.details_popup.leave requested date time'
                          .tr(),
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      dateFormatString(
                        item.submittedTime,
                        fromFormat: 'yyyy-MM-dd H:m:s',
                        toFormat: 'dd/MM/yyyy HH:mm',
                      ),
                      textScaler: TextScaler.noScaling,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const Divider(
                color: Color(0xFFF6F6F6),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'leave_request_page.details_popup.leave period'.tr(),
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      datesWithDuration(
                        item.startDate,
                        item.endDate,
                        format: 'dd/MM/yyyy'
                      ),
                      textScaler: TextScaler.noScaling,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const Divider(
                color: Color(0xFFF6F6F6),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'leave_request_page.details_popup.status'.tr(),
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: selectLeaveStatusColor(item.status),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: 4.0,
                    ),
                    child: Text(
                      "leave_request_page.list_screen.filter label ${item.status.toLowerCase()}".tr(),
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              item.approvedTime.isEmpty
                  ? const SizedBox()
                  : const Divider(
                      color: Color(0xFFF6F6F6),
                    ),
              item.approvedTime.isEmpty
                  ? const SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'leave_request_page.details_popup.approved date time'
                              .tr(),
                          textScaler: TextScaler.noScaling,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          dateFormatString(
                            item.approvedTime,
                            fromFormat: 'yyyy-MM-dd H:m:s',
                            toFormat: 'dd/MM/yyyy HH:mm',
                          ),
                          textScaler: TextScaler.noScaling,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
              const Divider(
                color: Color(0xFFF6F6F6),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'leave_request_page.details_popup.supporting documents'.tr(),
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  item.attachments!.isEmpty
                      ? const Text('-', textScaler: TextScaler.noScaling,)
                      : GestureDetector(
                          onTap: () {
                            displayDialog(
                              context: context,
                              headerWidget: const Text(
                                "Supporting document",
                                textScaler: TextScaler.noScaling,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: "Poppins-Bold",
                                ),
                              ),
                              bodyWidget: Image.network(
                                "$baseUrl${item.attachments![0]['url']}",
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(
                                0x1A1570EF,
                              ), // This color is very transparent
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(
                                color: const Color(
                                  0xFF1570EF,
                                ), // Border color
                                width: 1.0,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 4.0,
                            ),
                            child: const Icon(
                              Icons.file_open_outlined,
                              color: Color(
                                0xFF1570EF,
                              ),
                            ),
                          ),
                        )
                ],
              ),
              const Divider(
                color: Color(0xFFF6F6F6),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'leave_request_page.details_popup.reason'.tr(),
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    item.reason,
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const Divider(
                color: Color(0xFFF6F6F6),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'leave_request_page.details_popup.rejected reason'.tr(),
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    item.supervisorRemarks,
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Center(
                child: GeneralButton(
                  text: 'leave_request_page.details_popup.button'.tr(),
                  onPressed: () {
                    Navigator.pop(context); // Close the bottom sheet
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
