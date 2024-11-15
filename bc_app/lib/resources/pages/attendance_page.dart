import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';
import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nylo_framework/nylo_framework.dart'; // Replace with your specific package import for DateRangePickerDialog
import 'package:bc_app/resources/widgets/custom_scaffold_widget.dart'; // Adjust as per your project structure

class AttendancePage extends NyStatefulWidget {
  static const path = '/attendance';

  AttendancePage({super.key}) : super(path, child: _AttendancePageState());
}

class _AttendancePageState extends NyState<AttendancePage> {
  //State data
  List<Map<String, dynamic>> attendances = [];
  DateTimeRange? _selectedDateRange;
  ApiController apiController = ApiController();
  bool onLoading = false;

  String _langPref = '';

  @override
  init() async {
    // Any initialization code if needed
  }

  @override
  boot() async {
    String langPref = await NyStorage.read<String>('languagePref') ??'en';

    setState(() {
      _langPref = langPref;
    });

    DateTime now = DateTime.now();
    DateTime startDate = now.subtract(Duration(days: now.weekday - 1));
    DateTime endDate = startDate.add(const Duration(days: 6));
    _selectedDateRange = DateTimeRange(
      start: startDate,
      end: endDate
    );
    await _fetchAttendanceData();
  }

  _fetchAttendanceData() async{
    setState(() => onLoading = true);
    String startDate = stringifyDate(_selectedDateRange!.start);
    String endDate = stringifyDate(_selectedDateRange!.end);
    final items = await apiController.attendanceList(context, startDate, endDate);

    setState(() {
      onLoading = false;
      attendances = items;
    });
  }

  Future<void> _onRefresh() async {
    await _fetchAttendanceData();
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    // DateTime now = DateTime.now();
    // // Calculate the start date (Monday of the current week)
    // DateTime startDate = now.subtract(Duration(days: now.weekday - 1));
    // // Calculate the end date (Sunday of the current week)
    // DateTime endDate = startDate.add(Duration(days: 6));

    DateTimeRange selectedRange = _selectedDateRange!;
    String lang = await NyStorage.read<String>('languagePref') ?? 'en';

    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      locale: Locale(lang),
      initialDateRange: selectedRange,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      currentDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }

    _fetchAttendanceData();
  }


  @override
  Widget view(BuildContext context) {
    // DateTime now = DateTime.now();
    // // Calculate the start date (Monday of the current week)
    // DateTime startDate = now.subtract(Duration(days: now.weekday - 1));
    // // Calculate the end date (Sunday of the current week)
    // DateTime endDate = startDate.add(Duration(days: 6));

    // // Format the dates
    // String formattedStartDate = DateFormat('dd/MM/yyyy').format(startDate);
    // String formattedEndDate = DateFormat('dd/MM/yyyy').format(endDate);

    // Combine the formatted dates into the date range string
    String dateRange = '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}';

    return CustomScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MasterLayout(
              child: Row(
              children: [
                Expanded(
                  child: Text(
                    "attendance_page.title".tr(),
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      fontFamily: "Poppins-Bold",
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            )
          ),
          Center(
            child: TextButton(
              onPressed: () => _showDateRangePicker(context),
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    dateRange,
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(thickness: 1, color: Color(0xFFE9E6E6)),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: 
              attendances.isEmpty
              ? Center(
                  child: Text(
                    "no data".tr(),
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      color:Colors.black54
                    ),
                  ),
                )
              : ListView.builder(
                itemCount: attendances.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> data = attendances[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                        child: Text(
                          getFormattedDate(parsedDate('dd/MM/yyyy EEEE', data['workday']), 'dd/MM/yyyy EEEE', 'dd/MM/yyyy EEEE', _langPref),
                          textScaler: TextScaler.noScaling,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Adjust horizontal padding here
                        decoration: BoxDecoration(
                          color: ThemeColor.get(context).cardBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCardRow('attendance_page.driver id'.tr(), data['bcid']),
                            _buildCardRow('attendance_page.depot'.tr(), data['depot']),
                            _buildCardRow('attendance_page.duty'.tr(), data['duty']),
                            _buildCardRow('attendance_page.schedule time'.tr(), '${data['scheduledStartTime']} - ${data['scheduledEndTime']}'),
                            _buildCardRow('attendance_page.actual time'.tr(), "${data['actualStartTime']} - ${data['actualEndTime']}"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                  
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardRow(String label, String value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, textScaler: TextScaler.noScaling, style: const TextStyle(fontSize: 12)),
            Text(value, textScaler: TextScaler.noScaling, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const Divider(thickness: 1, color: Color(0xFFE9E6E6)),
      ],
    );
  }
}
