import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/hazard_report.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/hazard_report_form_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/hazard_report_card_widget.dart';
import 'package:bc_app/resources/widgets/components/input_dropdown_multiselect_widget.dart';
import 'package:bc_app/resources/widgets/custom_scaffold_widget.dart';
import 'package:bc_app/resources/widgets/safearea_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class HazardReportPage extends NyStatefulWidget {
  static const path = '/hazard-report';

  HazardReportPage({super.key}) : super(path, child: _HazardReportPageState());
}

BoxDecoration myBoxDecoration(BuildContext context, double width) {
  return BoxDecoration(
    border: Border.all(
        color: ThemeColor.get(context).myBoxDecorationLine, width: width),
    borderRadius: BorderRadius.circular(10),
  );
}

class _HazardReportPageState extends NyState<HazardReportPage> {
  String selectedStatus = "All";
  DateTime? _selectedDate;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  //For display purposes "Emailed" status will be displayed as "Processing"
  // Map<String, String> statusButtons = {};
  ApiController apiController = ApiController();

  List<String>? selectedLocation = [];
  List<String> locations = [];
  List<HazardReport> hazardReports = [];

  Future<void> _selectDate(BuildContext context) async {
    String lang = await NyStorage.read<String>('languagePref') ?? 'en';
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: Locale(lang),
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    setState(() {
      _selectedDate = picked;
    });
  }

  changeStatus(String status) {
    if (status == selectedStatus) return;
    setState(() {
      selectedStatus = status;
    });
  }

  double addHeight(String type, String remarks) {
    double total = 0;
    if (type.length > 30) total += 10;
    if (remarks.length > 30) total += 21;
    return total;
  }

  @override
  boot() async {
    List<String> res = await apiController.getDepotList(context);
    setState(() => locations = res);
    
    await _retrieveData();

  }

  _retrieveData() async {
    String? status = selectedStatus == 'All' ? '' : selectedStatus;
    List<HazardReport> hazardReportsRes = await apiController.hazardReportHistory(context, status: status, locations: selectedLocation, submitDate:stringifyDate(_selectedDate));
    setState(() {
      hazardReports = hazardReportsRes;
    });
  }

  Future<void> _refreshData() async{
    await _retrieveData();
  }

  buildFilterButton(String text, String value) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor:
                selectedStatus == value ? Colors.blue : Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            foregroundColor: selectedStatus == value
                ? Colors.white
                : ThemeColor.get(context).primaryContent),
        onPressed: () {
          setState(() {
            changeStatus(value);
          });
        },    
        child: Text(text,textScaler: TextScaler.noScaling,));
  }

   void _triggerRefresh() {
    _refreshIndicatorKey.currentState?.show();
  }

  /// The [view] method should display your page.
  @override
  Widget view(BuildContext context) {
    return CustomScaffold(
      body: SafeAreaWidget(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "hazard_report_page.title".tr(),
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(
                    fontFamily: "Poppins-Bold",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              HazardReportFormPage.path,
                            ).then((value) async => await  _refreshData());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1570EF),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(255, 255, 255, 1),
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(0.0),
                                topLeft: Radius.circular(0.0),
                              ),
                            ),
                          ),
                          child: Text(
                            "+ ${"hazard_report_page.button".tr()}",
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                              color:
                                  ThemeColor.get(context).appBarPrimaryContent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  height: 30,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        buildFilterButton(
                            "hazard_report_page.filter label all".tr(), "All"),
                        buildFilterButton(
                            "hazard_report_page.filter label open".tr(),
                            "Open"),
                        buildFilterButton(
                            "hazard_report_page.filter label in progress".tr(),
                            "In Progress"),
                        buildFilterButton(
                            "hazard_report_page.filter label completed".tr(),
                            "Completed"),
                        buildFilterButton(
                            "hazard_report_page.filter label closed".tr(),
                            "Closed"),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: InputDropdownMultiselect(
                    label: "",
                    items: locations,
                    values: selectedLocation,
                    placeholder: 'Location'.tr(),
                    onChanged: (List<String>? newValue) async {
                      setState(() {
                        selectedLocation = newValue;
                      });
                      _refreshData();
                    },
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF9F9F9),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14.0, vertical: 4.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_selectedDate == null
                              ? 'hazard_report_page.submit date'.tr()
                              : stringifyDate(_selectedDate),
                              textScaler: TextScaler.noScaling,
                            ),
                          const SizedBox(width: 8),
                          _selectedDate == null
                              ? const Icon(Icons.arrow_drop_down)
                              : GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDate = null;
                                    });
                                  },
                                  child: const Icon(Icons.close, size: 15),
                                ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _triggerRefresh,
                      icon: Image.asset(
                        'public/assets/images/refresh.png',
                        width: 32,
                        height: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.32,
                  child: hazardReports.isEmpty
                    ? Center(child: Text('no data'.tr()))
                    : RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: _refreshData,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: hazardReports.length,
                          itemBuilder: (BuildContext context, int index) {
                            final item = hazardReports[index];
                            return HazardReportCard(data: item, context: context);
                          }
                        ),
                      ),
                ),
                const SizedBox(height: 8.0)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
