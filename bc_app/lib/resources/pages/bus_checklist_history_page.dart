import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/bus_check_history.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/bus_checklist_detail_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/bus_checklist_card_widget.dart';
import 'package:bc_app/resources/widgets/components/input_dropdown_multiselect_widget.dart';
import 'package:bc_app/resources/widgets/custom_scaffold_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '/app/controllers/home_controller.dart';
import '/resources/widgets/safearea_widget.dart';

class BusChecklistHistoryPage extends NyStatefulWidget<HomeController> {
  static const path = '/bus-checklist';

  BusChecklistHistoryPage({super.key})
      : super(path, child: _BusChecklistHistoryState());
}

String truncateWithEllipsis(int maxLength, String text) {
  return (text.length <= maxLength)
      ? text
      : '${text.substring(0, maxLength)}...';
}

class _BusChecklistHistoryState extends NyState<BusChecklistHistoryPage> {
  String selectedStatus = "All";
  List<String>? selectedType = [];
  DateTime? selectedDate;
  BusCheckHistory? selectedList;
  List<BusCheckHistory> thelist = [];
  // Map<String, String> statusButtons = {
  //   'All': "buscheck_page.checklist_screen.filter label all".tr(),
  //   'Pending': "buscheck_page.checklist_screen.filter label pending".tr(),
  //   'Acknowledged': "buscheck_page.checklist_screen.filter label acknowledged".tr(),
  // };

  List<String> type = [
    'First Parade Tasks',
    'Last Parade Tasks',
    'End of Trip Tasks',
  ];

  Future<void> _selectDate(BuildContext context) async {
    String lang = await NyStorage.read<String>('languagePref') ??'en';
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: Locale(lang),
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      callAPI();
    }
  }

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse('$date-01');

    DateFormat formatter = DateFormat('MMM yyyy');

    String formattedDate = formatter.format(dateTime);

    return formattedDate;
  }

  double addHeight(String type, String remarks) {
    double total = 0;

    if (type.length > 30) total += 10;
    if (remarks.length > 30) total += 21;

    return total;
  }

  List<BusCheckHistory> getFilteredRequests() {
    List<BusCheckHistory> filteredList = selectedStatus == 'All'
        ? List.from(thelist)
        : thelist.where((request) => request.status == selectedStatus).toList();

    if (selectedType != null && selectedType!.isNotEmpty) {
      filteredList = filteredList
          .where((request) => selectedType!.contains(request.type))
          .toList();
    }

    return filteredList;
  }

  ApiController apiController = ApiController();

  @override
  boot() async {
    await callAPI();
  }

  callAPI() async {
    final res = await apiController.getBusCheckHistory(
      context,
      selectedStatus == "All" ? "" : selectedStatus,
      selectedType,
      stringifyDate(selectedDate),
    );

    setState(() {
      thelist = res;
    });
  }

  buildFilterButton(String text, String value) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
              backgroundColor: selectedStatus == value ? Colors.blue : Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              foregroundColor: ThemeColor.get(context).primaryContent),
      onPressed: () async {
        setState(() {
          selectedStatus = value;
        });
        await callAPI();
      },
      child: Text(text,textScaler: TextScaler.noScaling,)
    );
  }

  /// The [view] method should display your page.
  @override
  Widget view(BuildContext context) {
    return CustomScaffold(
      body: SafeAreaWidget(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        // Must always return to homepage
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios_new),
                      color: ThemeColor.get(context).backButtonIcon,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "buscheck_page.checklist_screen.title".tr(),
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(
                        fontFamily: "Poppins-Bold",
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.5),
                child: Column(
                  children: [
                    SizedBox(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            buildFilterButton(
                              "buscheck_page.checklist_screen.filter label all".tr(), 
                              "All"
                            ),
                            buildFilterButton(
                              "buscheck_page.checklist_screen.filter label pending".tr(), 
                              "Pending"
                            ),
                            buildFilterButton(
                              "buscheck_page.checklist_screen.filter label approved".tr(), 
                              "Approved"
                            ),
                            buildFilterButton(
                              "buscheck_page.checklist_screen.filter label acknowledged".tr(), 
                              "Acknowledged"
                            ),
                          ]
                        )
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InputDropdownMultiselect(
                          label: "",
                          items: type,
                          values: selectedType,
                          placeholder:
                              'buscheck_page.checklist_screen.filter task type'.tr(),
                          onChanged: (List<String>? newValue) async {
                            setState(() {
                              selectedType = newValue;
                            });
                            await callAPI();
                          },
                        ),
                        const SizedBox(width: 8.0),
                        ElevatedButton(
                          onPressed: () => _selectDate(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColor.get(context).inputBoxNormal,
                            foregroundColor: ThemeColor.get(context).primaryContent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 4.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(selectedDate != null
                                  ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                                  : 'buscheck_page.checklist_screen.submit date'
                                      .tr(),
                                  textScaler: TextScaler.noScaling,
                                ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    selectedDate = null;
                                  });
                                  callAPI();
                                },
                                child: Icon(
                                  size: (selectedDate != null ? 16 : 22),
                                  selectedDate != null
                                      ? Icons.close
                                      : Icons.arrow_drop_down,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    for (var i in thelist)
                      BusChecklistCard(
                        data: i,
                        handler: () {
                          Navigator.pushNamed(
                            context,
                            BusChecklistDetailPage.path,
                            arguments: i,
                          );
                        },
                        context: context,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          textScaler: TextScaler.noScaling,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            value,
            textScaler: TextScaler.noScaling,
            textAlign: TextAlign.right,
            style: const TextStyle(fontFamily: 'Poppins-bold', fontSize: 13),
          ),
        )
      ],
    );
  }

  bool get isThemeDark =>
      ThemeProvider.controllerOf(context).currentThemeId ==
      getEnv('DARK_THEME_ID');
}
