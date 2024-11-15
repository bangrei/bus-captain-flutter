import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/leave_request.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/leave_request_form_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:bc_app/resources/widgets/components/leave_request_card.dart';
import 'package:bc_app/resources/widgets/components/leave_request_details.dart';
import 'package:bc_app/resources/widgets/custom_scaffold_widget.dart';
import 'package:bc_app/resources/widgets/safearea_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LeaveRequestPage extends NyStatefulWidget {
  static const path = '/leave-request';

  LeaveRequestPage({super.key}) : super(path, child: _LeaveRequestPageState());
}

class _LeaveRequestPageState extends NyState<LeaveRequestPage> {
  //State
  String activeFilter = "All";
  DateTimeRange? leaveDate; // Set to null
  DateTime? applyDate; // Set to null

  List<LeaveRequest> leaveReqLists = [];

  ApiController apiController = ApiController();

  @override
  init() async {}

  @override
  boot() async {
    await _getLists();
  }

  Future<void> _getLists() async{
    List<LeaveRequest> reqList = await apiController.getLeaveRequests(
      context, 
      activeFilter == "All" ? "" : activeFilter,
      stringifyDate(leaveDate),
      stringifyDate(applyDate)
    );

    setState(() {
      leaveReqLists = reqList;
    });
  }

  void setActiveFilter(String filter) async{
    setState(() => activeFilter = filter);

    await _getLists();
  }

  Future<void> _selectDate(BuildContext context, String label) async {
    String lang = await NyStorage.read<String>('languagePref') ?? 'en';
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: Locale(lang),
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: "Select $label",
    );
    if (picked != null) {
      setState(() {
        if (label == "leave_request_page.list_screen.apply date".tr()) {
          applyDate = picked;
        }
      });
      await _getLists();
    }
  }

  Future<void> _selectDateRange(BuildContext context, String label) async {
    String lang = await NyStorage.read<String>('languagePref') ?? 'en';
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      locale: Locale(lang),
      // initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: "Select $label",
    );
    if (picked != null) {
      setState(() {
        if (label == "leave_request_page.list_screen.leave date".tr()) {
          leaveDate = picked;
        }
      });

      await _getLists();
    }
  }

  _handleRefresh() async {
    setState(() {
      activeFilter = "All";
    });
    await _getLists();
  }

  Widget buildFilterButton(String text, String value) {
    bool isActive = activeFilter == value;
    return TextButton(
      onPressed: () => setActiveFilter(value),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        backgroundColor: isActive ? Colors.blue : Colors.transparent,
        foregroundColor: isActive ? Colors.white : ThemeColor.get(context).primaryContent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: Text(text, textScaler: TextScaler.noScaling,),
    );
  }

  // Type 0 = Leave Date, 1 = Submitted Date
  Widget buildDateSelector(
      String label, DateTime? selectedDate, Function() onReset) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA), // Background color
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () =>  _selectDate(context, label),
                child: Row(
                  children: [
                    selectedDate != null
                        ? Text(
                            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                            textScaler: TextScaler.noScaling,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12.0),
                          )
                        : Text(
                            label,
                            textScaler: TextScaler.noScaling,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12.0),
                          ),
                    const SizedBox(width: 10),
                    const Icon(Icons.calendar_today,
                      color: Colors.grey, size: 18.0
                    ),
                    const SizedBox(width: 10),
                    selectedDate == null
                    ? const SizedBox()
                    : GestureDetector(
                      onTap: () {
                        setState(() {
                          onReset();
                        });
                      },
                      child: const Icon(Icons.close, color: Colors.blue, size: 15.0)
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildDateRangeSelector(
      String label, DateTimeRange? selectedDate, Function() onReset) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA), // Background color
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () =>  _selectDateRange(context, label),
                child: Row(
                  children: [
                    selectedDate != null
                        ? Text(
                            "${DateFormat('dd/MM/yyyy').format(selectedDate.start)} - ${DateFormat('dd/MM/yyyy').format(selectedDate.end)}",
                            textScaler: TextScaler.noScaling,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12.0),
                          )
                        : Text(
                            label,
                            textScaler: TextScaler.noScaling,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12.0),
                          ),
                    const SizedBox(width: 10),
                    const Icon(Icons.calendar_today,
                      color: Colors.grey, size: 18.0
                    ),
                    const SizedBox(width: 10),
                    selectedDate == null
                    ? const SizedBox()
                    : GestureDetector(
                      onTap: () {
                        setState(() {
                          onReset();
                        });
                      },
                      child: const Icon(Icons.close, color: Colors.blue, size: 15.0)
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget view(BuildContext context) {
    return CustomScaffold(
      body: SafeAreaWidget(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "leave_request_page.list_screen.title".tr(),
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins-Bold",
                  ),
                ),
                GeneralButton(
                  onPressed: () {
                    Navigator.pushNamed(
                            context, LeaveRequestFormPage.path)
                        .then((value) {
                      _handleRefresh();
                    });
                  },
                  text: "+ ${"leave_request_page.list_screen.new leave".tr()}",
                  height: 0, //Height auto
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildFilterButton(
                      "leave_request_page.list_screen.filter label all".tr(), 
                      "All"
                    ),
                    buildFilterButton(
                      "leave_request_page.list_screen.filter label approved".tr(),
                      "Approved"
                    ),
                    buildFilterButton(
                      "leave_request_page.list_screen.filter label pending".tr(),
                      "Pending"
                    ),
                    buildFilterButton(
                      "leave_request_page.list_screen.filter label rejected".tr(), 
                      "Rejected"
                    ),
                    buildFilterButton(
                      "leave_request_page.list_screen.filter label cancelled".tr(), 
                      "Cancelled"
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      buildDateRangeSelector(                      
                        "leave_request_page.list_screen.leave date".tr(),
                        leaveDate,
                        () async { 
                          setState(() {
                            leaveDate = null;
                          });
                          await _getLists();
                        },
                      ),
                      const SizedBox(width: 16.0),
                      buildDateSelector(
                        "leave_request_page.list_screen.apply date".tr(),
                        applyDate,
                        () async { 
                          setState(() {
                            applyDate = null;
                          });
                          await _getLists();
                        },
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _handleRefresh();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(0), // Remove all padding
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20.0,
            ), // Add spacing between date selector and list of cards
            SizedBox(
              height: 0.49 * MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    leaveReqLists.isEmpty
                    ? Center(child: Text("no data".tr(), textScaler: TextScaler.noScaling,),)
                    : Column(
                        children: [
                          ...leaveReqLists.map((i)=>
                            GestureDetector(
                               onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return LeaveRequestDetails(item: i);
                                  },
                                );
                              },
                              child: LeaveRequestCard(
                                item: i, 
                                onRefresh: _handleRefresh,
                              ),
                            )
                          )
                        ],
                      ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
