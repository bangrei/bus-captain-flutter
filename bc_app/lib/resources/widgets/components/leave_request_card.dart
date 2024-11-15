import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/leave_request.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nylo_framework/nylo_framework.dart';


class LeaveRequestCard extends StatelessWidget {
  final LeaveRequest item;
  final Function onRefresh;
  LeaveRequestCard({
    super.key,
    required this.item,
    required this.onRefresh
  });

  ApiController apiController = ApiController();

  void _handleCancel(BuildContext context) async {
    return _showConfirmation(context, 
      (bool confirmed) async {
        if (!confirmed) return;
        await apiController.cancelLeaveRequest(context: context, requestNo: item.requestNo);
        onRefresh();
      }
    );
  }

  bool isPastDate(String date) {
    DateTime dateTime = DateFormat('yyyy-MM-dd').parse(date);
    DateTime currentDate = DateTime.now();
    return dateTime.isBefore(currentDate);
  }

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
                        "leave_request_page.cancel_screen.title".tr(),
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
                const SizedBox(height: 30),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'leave_request_page.cancel_screen.confirmation message'.tr(),
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: ThemeColor.get(context).primaryContent,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${"leave_request_page.details_popup.leave type".tr()} ${item.leaveType}',
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: ThemeColor.get(context).primaryContent,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins-Bold",
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GeneralButton(
                      text: "no".tr(),
                      color: Colors.black.withOpacity(0.1),
                      onPressed: () {
                        response(false);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 24),
                    GeneralButton(
                      text: "yes".tr(),
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
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ThemeColor.get(context).cardBg,
      elevation: 0, // Optional: Set elevation to 0 to remove shadow
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black12, width: 1.0),
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 16.0,
              right: 16.0,
              bottom: 16.0, // Add bottom padding if there is an attachment
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.leaveType,
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(
                      fontSize: 16.0, fontFamily: "Poppins-Bold"),
                ),
                const SizedBox(height: 0.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        datesWithDuration(item.startDate, item.endDate, format: 'dd/MM/yyyy'),
                        textScaler: TextScaler.noScaling,
                        maxLines: null,
                        style: TextStyle(
                            color: ThemeColor.get(context).primaryContent, fontSize: 12),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: selectLeaveStatusColor(item.status),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 4.0,
                      ),
                      child: Text(
                        "leave_request_page.list_screen.filter label ${item.status.toLowerCase()}".tr(),
                        textScaler: TextScaler.noScaling,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  "${"leave_request_page.list_screen.applied on".tr()}${stringifyDate(DateFormat('yyyy-MM-dd HH:mm:ss').parse(item.submittedTime), format: 'dd/MM/yyyy HH:mm')}",
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [     
                    Visibility(
                      visible: item.attachments!.isNotEmpty,
                      child: Icon(
                        Icons.attach_file,
                        color: ThemeColor.get(context).primaryContent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Visibility(
                      visible: item.status == "Pending" && !isPastDate(item.startDate),
                      child: GestureDetector(
                        onTap: () {
                          _handleCancel(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(9.5),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.red
                          ),
                          child: Text(
                            'leave_request_page.cancel_screen.button label cancel'.tr(),
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                              color: ThemeColor.get(context).appBarPrimaryContent,
                              fontSize: 12
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),        
          ),
          // if (item.attachments!.isNotEmpty)
          //   Positioned(
          //     bottom: 13,
          //     right: 13,
          //     child: Icon(
          //       Icons.attach_file,
          //       color: ThemeColor.get(context).primaryContent,
          //     ),
          //   ),
        ],
      ),
    );
  }
}
