import 'package:bc_app/app/models/driving_performance_events.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/driving_performance_occurrence_detail_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:flutter/material.dart';
import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:bc_app/resources/widgets/safearea_widget.dart';
import 'package:intl/intl.dart';

class DrivingPerformanceDetailPage extends NyStatefulWidget {
  static const path = '/driving-performance-detail';

  DrivingPerformanceDetailPage({super.key})
      : super(path, child: _DrivingPerformanceDetailPageState());
}

class _DrivingPerformanceDetailPageState
    extends NyState<DrivingPerformanceDetailPage> {
  bool _isAscending = true; // Default sorting order
  ApiController apiController = ApiController();
  List<DrivingPerformanceEvents> perfData = [];
  List<DrivingPerformanceEvents> perfList = [];

  DateTime? _filterDate;

  String _langPref = '';

  @override
  init() async {
    String langPref = await NyStorage.read<String>('languagePref') ??'en';

    setState(() {
      _langPref = langPref;
    });

    retrievePerformanceEvents();
  }

  retrievePerformanceEvents() async {
    final data = widget.data();
    final items = await apiController.getEventsDrivingPerformance(
        context: context, month: data);

    if (items.isNotEmpty) {
      setState(() {
        perfData = items;
        perfList = items;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async{
    String lang = await NyStorage.read<String>('languagePref') ?? 'en';
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: Locale(lang),
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: "driving_performance_page.detail_screen.select filter date".tr(),
    );

    if (picked != null) {
      setState(() {
        _filterDate = picked;
        _applyFilter();
      });
    }
  }

  void _applyFilter() {
    setState(() {
      if (_filterDate != null) {
        perfList = perfData.where((item) => item.date == DateFormat('d MMMM yyyy').format(_filterDate!)).toList();
      } else {
        perfList = List.from(perfData);
      }
    });
  }

  @override
  Widget view(BuildContext context) {
    final data = widget.data();

    List<dynamic> sortedData = perfList; // Create a copy of the original data

    final DateFormat dateFormat = DateFormat(
        'MMMM yyyy'); // Adjust the format according to your date string. Example: "May 2024"
    final DateFormat dateFormat2 = DateFormat(
      'd MMMM yyyy'// Adjust the format according to your date string. Example: "30 May 2024"
    );

    sortedData.sort((a, b) {
      // Compare dates for sorting
      DateTime dateA = dateFormat2.parse(a.date);
      DateTime dateB = dateFormat2.parse(b.date);
      return _isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });

    // Get the current month and year
    DateTime date = dateFormat.parse(data);
    int currentYear = date.year;
    int currentMonth = date.month;

    // Get the first and last date of the current month
    DateTime firstDateOfMonth = DateTime(currentYear, currentMonth, 1);
    DateTime lastDateOfMonth = DateTime(currentYear, currentMonth + 1, 0);

    // Format the date range
    String dateRange = '${DateFormat('dd/MM/yyyy').format(firstDateOfMonth)} - ${DateFormat('dd/MM/yyyy').format(lastDateOfMonth)}';

    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: TitleBar(title: getFormattedDate(dateFormat.parse(data), 'MMMM yyyy', 'M月 yyyy年', _langPref)),
      body: SafeAreaWidget(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Date range display with border radius
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 25.0),
                  margin: const EdgeInsets.symmetric(vertical: 16.0),
                  decoration: BoxDecoration(
                    color: ThemeColor.get(context).backButtonIcon,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize
                        .min, // This makes the Row take only as much space as needed
                    children: [
                      const Icon(
                        Icons.calendar_today, // Use the appropriate icon here
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(
                          width:
                              8.0), // Add some space between the icon and the text
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
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    // width: 138,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC4C4C4).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isAscending = !_isAscending;
                        });
                      },
                      child: Row(
                        children: [
                          Text(
                              'driving_performance_page.detail_screen.sort date'
                                  .tr(),
                              textScaler: TextScaler.noScaling,),
                          const SizedBox(width: 8),
                          if (_isAscending)
                            const Icon(
                              Icons.arrow_drop_up,
                              color: Colors.blue,
                            ),
                          if (!_isAscending)
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.blue,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    // width: 138,
                    decoration: BoxDecoration(
                      color: ThemeColor.get(context).surfaceBackground,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GestureDetector(
                      onTap: () {
                        _selectDate(context);
                      },
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _filterDate == null
                            ? Text(
                                'driving_performance_page.detail_screen.filter date'.tr(),
                                textScaler: TextScaler.noScaling,)
                            : Text(
                                _filterDate.toFormat('d MMMM yyyy')!,
                                textScaler: TextScaler.noScaling,
                              ),
                              const SizedBox(width: 5),
                            _filterDate == null
                            ? const Icon(
                                Icons.arrow_drop_up,
                                color: Colors.blue,
                              )
                            : GestureDetector(
                              onTap: () {
                                _filterDate = null;
                                _applyFilter();
                              },
                              child: const Icon(
                                  Icons.close,
                                  color: Colors.blue,
                                  size: 16,
                                ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              perfList.isEmpty 
              ? Center(
                  child: Text(
                    "no data".tr(),
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      color: Colors.black54
                    ),
                  )
                )
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: perfList.length,
                itemBuilder: (context, index) {
                  var item = perfList[index];
                  Map<String, int> events = item.eventOcc;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getFormattedDate(DateFormat('dd MMMM yyyy').parse(item.date),'dd/MM/yyyy EEEE', 'dd/MM/yyyy EEEE', _langPref),
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          routeTo(DrivingPerformanceOccurrenceDetailPage.path,
                              data: item.date);
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                            color: ThemeColor.get(context).cardBg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      events.isEmpty
                                      ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: ThemeColor.get(context).surfaceBackground,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: const Color(0xFF797979),
                                          ),
                                        ),
                                        child: Text("no events".tr(), textScaler: TextScaler.noScaling,),
                                      )
                                      : Container(
                                        width: 0.70*width,
                                        child: Wrap(
                                          spacing: 8,
                                          runSpacing: 12,
                                          children: events.entries
                                              .map((MapEntry<String, int> entry) {
                                            String alarmName = entry.key;
                                            int alarmCount = entry.value;
                                        
                                            return Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: ThemeColor.get(context).surfaceBackground,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: const Color(0xFF797979),
                                                ),
                                              ),
                                              child:
                                                  Text(
                                                    "${'driving_performance_page.occurrence_detail_screen.detail_events.filter label ${alarmName.toLowerCase()}'.tr()} : $alarmCount",
                                                    textScaler: TextScaler.noScaling,
                                                  ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child:
                                        _getOccurrenceIcon(item.performance),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getOccurrenceIcon(String occurrence) {
    if (occurrence.toLowerCase() == 'excellent') {
      return Image.asset('public/assets/images/star.png',
          width: 40, height: 40);
    } else if (occurrence.toLowerCase() == 'good') {
      return Image.asset('public/assets/images/thumb_up.png',
          width: 40, height: 40);
    } else {
      return Image.asset('public/assets/images/block.png',
          width: 40, height: 40);
    }
  }
}
