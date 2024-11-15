import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:bc_app/app/controllers/api_controller.dart';

class DrivingPerformanceOccurrenceDetailPage extends NyStatefulWidget {
  static const path = '/driving-performance-occurrence-detail';

  DrivingPerformanceOccurrenceDetailPage({super.key})
      : super(path, child: _DrivingPerformanceOccurrenceDetailPageState());
}

class _DrivingPerformanceOccurrenceDetailPageState
    extends NyState<DrivingPerformanceOccurrenceDetailPage> {
  String selectedDetailType =
      "detail_trips"; // Default selection is "detail_trips"
  String? selectedType; // Variable to keep track of selected event type
  Map<String, List<Map<String, dynamic>>> perfList = {
    'detail_events': [],
    'detail_trips': []
  };

  Map<String, List<Map<String, dynamic>>> perfData = {
    'detail_events': [],
    'detail_trips': []
  };
  List<dynamic>? availableTypes = [];
  ApiController apiController = ApiController();

  // For detail trip
  TimeOfDay? _startTimeFilter;
  TimeOfDay? _endTimeFilter;
  // For detail event
  TimeOfDay? _tripTimeFilter;

  String _langPref ='';

  @override
  boot() async {
    String langPref = await NyStorage.read<String>('languagePref') ??'en';

    setState(() {
      _langPref = langPref;
    });
    
    await retrievePerformanceEvents();
    
    _retrieveEventTypes();
  }

  _retrieveEventTypes() {
    setState(() {
      availableTypes = perfList[selectedDetailType]!
        .map((detail) => detail['alarmType'])
        .toSet()
        .toList();
      availableTypes!.insert(0, "All");
    });
  }

  retrievePerformanceEvents() async {
    final data = widget.data();
    final items = await apiController.getDrivingPerformanceDailyOccurence(
        context: context, date: data);
    if (items.isNotEmpty) {
      setState(() {
        perfList = items;
        perfData = items;
      });
    }
  }

  void _selectTimeRange(BuildContext context) async{
    TimeOfDay? selectedStartTime = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.inputOnly,
      initialTime: _startTimeFilter ?? TimeOfDay.fromDateTime(DateTime.now()),
      helpText: 'driving_performance_page.occurrence_detail_screen.trip_events.enter start time'.tr(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (selectedStartTime == null) return;

    if(!context.mounted) {
      return;
    }

    TimeOfDay? selectedEndTime = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.inputOnly,
      initialTime: _endTimeFilter ?? TimeOfDay.fromDateTime(DateTime.now()),
      helpText: 'driving_performance_page.occurrence_detail_screen.trip_events.enter end time'.tr(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (selectedEndTime == null) return;

    setState(() {
      _startTimeFilter = selectedStartTime;
      _endTimeFilter = selectedEndTime;
    });

    _applyFilter();
  }

  void _applyFilter() {
    var filteredList = Map<String, List<Map<String, dynamic>>>.from(perfData);
    if (selectedDetailType == 'detail_trips') {
      if (_startTimeFilter == null || _endTimeFilter == null) {
        setState(() {
          perfList = Map.from(perfData);
        });
        return;
      }

      final startTime = _convertToDateTime(_startTimeFilter!);
      final endTime = _convertToDateTime(_endTimeFilter!);
      
      filteredList[selectedDetailType] = perfData[selectedDetailType]!.where((item) {
        DateTime itemStartTime = _parseTime(item['startTime']);
        DateTime itemEndTime = _parseTime(item['endTime']);
        return (itemStartTime.isAfter(startTime) || itemStartTime.isAtSameMomentAs(startTime)) &&
            (itemEndTime.isBefore(endTime) || itemEndTime.isAtSameMomentAs(endTime));
      }).toList();
      // Update perfList with the filtered data
    } else {
      if (_tripTimeFilter ==  null) {
        setState(() {
          perfList = Map.from(perfData);
        });
        return;
      }

      final tripTime = _convertToDateTime(_tripTimeFilter!);

      filteredList[selectedDetailType] = perfData[selectedDetailType]!.where((item) {
         DateTime itemTripTime = _parseTime(item['time']);
         return itemTripTime.isAtSameMomentAs(tripTime);
      }).toList();
    }

    setState(() {
      perfList = filteredList;
    });
  }

  DateTime _convertToDateTime(TimeOfDay time) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final dt = _convertToDateTime(time);
    final format = DateFormat.Hm(); // 24-hour format
    return format.format(dt);
  }

  DateTime _parseTime(String time) {
    final now = DateTime.now();
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  void _selectTime(BuildContext context) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.inputOnly,
      initialTime: _tripTimeFilter ?? TimeOfDay.fromDateTime(DateTime.now()),
      helpText: 'driving_performance_page.occurrence_detail_screen.detail_events.enter trip time'.tr(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      setState(() {
        _tripTimeFilter = selectedTime;
      });
    }

    _applyFilter();
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: TitleBar(
        title: getFormattedDate(DateFormat('dd MMMM yyyy').parse(widget.data()), 'dd/MM/yyyy', 'dd/MM/yyyy', _langPref),
        subtitle:
            "driving_performance_page.occurrence_detail_screen.subtitle".tr(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              children: [
                // Dropdown for selecting detail type
                Align(
                  alignment:
                      Alignment.centerLeft, // Align the dropdown to the left
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10), // Add padding inside the container
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Colors.grey), // Set border color
                      borderRadius:
                          BorderRadius.circular(10), // Set border radius
                    ),
                    child: DropdownButtonHideUnderline(
                      // Hide the default underline
                      child: DropdownButton<String>(
                        value: selectedDetailType,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedDetailType = newValue!;
                            selectedType = null; // Reset selectedType when switching detail type

                            //reset all filter
                            _endTimeFilter = null;
                            _startTimeFilter = null;
                            _endTimeFilter = null;
                          });
                          _retrieveEventTypes();
                          _applyFilter();
                        },
                        items: <String>['detail_trips', 'detail_events']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value == 'detail_events'
                              ? 'driving_performance_page.occurrence_detail_screen.filter label view by events'.tr()
                              : 'driving_performance_page.occurrence_detail_screen.filter label view by trip'.tr(),
                              textScaler: TextScaler.noScaling,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Conditionally render the filter row
                selectedDetailType == 'detail_events'
                  ? Column(
                      children: [
                        Container(
                          height: 50, // Set a fixed height for the filter row
                          alignment: Alignment.centerLeft,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: availableTypes!.map((type) {
                              String label = 'driving_performance_page.occurrence_detail_screen.detail_events.filter label ${type.toLowerCase()}'.tr();
                              bool isSelected = selectedType == type ||
                                  (type == "All" && selectedType == null);

                                return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                child: isSelected
                                    ? ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            selectedType =
                                                type == "All" ? null : type;
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 6),
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: Text(
                                          label,
                                          textScaler: TextScaler.noScaling,
                                          style: TextStyle(
                                            color: ThemeColor.get(context).primaryContent,
                                            fontFamily: "Poppins-Bold",
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      )
                                    : TextButton(
                                        onPressed: () {
                                          setState(() {
                                            selectedType =
                                                type == "All" ? null : type;
                                          });
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: Text(
                                          label,
                                          textScaler: TextScaler.noScaling,
                                          style: TextStyle(
                                            color: ThemeColor.get(context).primaryContent,
                                            fontFamily: "Poppins-Bold",
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ),
                                );
                              }
                              ).toList(),
                            ),
                            
                          )
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IntrinsicWidth(
                            child: Container(
                              // width: 175,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: GestureDetector(
                                onTap: () {
                                  _selectTime(context);
                                },
                                child: Row(
                                  children: [
                                    _tripTimeFilter == null
                                    ? Text(
                                        'driving_performance_page.occurrence_detail_screen.trip_events.filter by time'.tr(),
                                        textScaler: TextScaler.noScaling,
                                      )
                                    : Text(
                                        _formatTimeOfDay(_tripTimeFilter!),
                                        textScaler: TextScaler.noScaling,
                                      ),
                                    const SizedBox(width: 8),
                                    _tripTimeFilter == null
                                    ? const Icon(
                                        Icons.arrow_drop_up,
                                        color: Colors.blue,
                                      )
                                    : GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _tripTimeFilter = null;
                                        });
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
                        ),
                      ],
                    )
                  : Align(
                    alignment: Alignment.centerLeft,
                    child: IntrinsicWidth(
                      child: Container(
                        // width: 175,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: GestureDetector(
                          onTap: () {
                            _selectTimeRange(context);
                          },
                          child: Row(
                            children: [
                              _startTimeFilter == null && _endTimeFilter == null
                              ? Text(
                                  'driving_performance_page.occurrence_detail_screen.detail_events.filter by time'.tr(),
                                  textScaler: TextScaler.noScaling,
                                )
                              : Text(
                                  "${_formatTimeOfDay(_startTimeFilter!)} - ${_formatTimeOfDay(_endTimeFilter!)}",
                                  textScaler: TextScaler.noScaling,
                                ),
                              const SizedBox(width: 8),
                               _startTimeFilter == null && _endTimeFilter == null
                              ? const Icon(
                                  Icons.arrow_drop_up,
                                  color: Colors.blue,
                                )
                              : GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _startTimeFilter = null;
                                    _endTimeFilter = null;
                                  });
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
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: perfList[selectedDetailType]!.length,
                  itemBuilder: (context, index) {
                    final detail = perfList[selectedDetailType]![index];
                    if (selectedType != null &&
                        selectedType != detail['alarmType']) {
                      return const SizedBox
                          .shrink(); // Hide the item if it's not selected
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        color: ThemeColor.get(context).cardBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: const BorderSide(color: Color(0xFFF6F6F5)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: selectedDetailType == 'detail_events'
                                ? _buildEventDetail(detail)
                                : _buildTripDetail(detail),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEventDetail(Map<String, dynamic> detail) {
    return [
      Text(
        "driving_performance_page.occurrence_detail_screen.detail_events.filter label ${detail['alarmType'].toLowerCase()}".tr(),
        textScaler: TextScaler.noScaling,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: "Poppins-Bold",
        ),
      ),
      const SizedBox(height: 5),
      Text.rich(
        TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: 'driving_performance_page.occurrence_detail_screen.detail_events.time'.tr(),
            ),
            TextSpan(
              text: detail['time'],
              style: TextStyle(
                fontFamily: "Poppins-Bold",
                color: ThemeColor.get(context).primaryContent.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
      Text.rich(
        TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: 'driving_performance_page.occurrence_detail_screen.detail_events.service number'.tr(),
              style: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
            TextSpan(
              text: detail['serviceno'],
              style: TextStyle(
                fontFamily: "Poppins-Bold",
                color: ThemeColor.get(context).primaryContent.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
      detail.containsKey('location')
          ? Text.rich(
              TextSpan(
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Location: ',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  TextSpan(
                    text: detail['location'],
                    style: TextStyle(
                      fontFamily: "Poppins-Bold",
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(), // Hide location if not available
    ];
  }

  List<Widget> _buildTripDetail(Map<String, dynamic> detail) {
    return [
      Text(
        detail['startTime'] + ' - ' + detail['endTime'],
        textScaler: TextScaler.noScaling,
        style: const TextStyle(fontFamily: "Poppins-Bold", fontSize: 20),
      ),
      const SizedBox(height: 10),
      Text.rich(
        TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: 'driving_performance_page.occurrence_detail_screen.trip_events.bus number'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: ThemeColor.get(context).primaryContent,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: detail['busPlateNum'],
              style: TextStyle(
                fontSize: 14,
                fontFamily: "Poppins-Bold",
                color: ThemeColor.get(context).primaryContent,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      Text("driving_performance_page.occurrence_detail_screen.trip_events.driving behaviour events".tr(),
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: ThemeColor.get(context).primaryContent,
        )),
      const SizedBox(height: 10),
      detail['eventOcc'] .isEmpty
      ? Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: ThemeColor.get(context).surfaceBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF797979),
            ),
          ),
          child: Text("no events".tr(), textScaler: TextScaler.noScaling,)
        )
      :Wrap(
        spacing: 8,
        runSpacing: 12,
        children: (detail['eventOcc'] as Map<String, dynamic>)
            .entries
            .map((MapEntry<String, dynamic> entry) {
          String alarmName = entry.key;
          int alarmCount = entry.value;

          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: ThemeColor.get(context).surfaceBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF797979),
              ),
            ),
            child: Text(
              "${'driving_performance_page.occurrence_detail_screen.detail_events.filter label ${alarmName.toLowerCase()}'.tr()} : $alarmCount",
              textScaler: TextScaler.noScaling,
            ),
          );
        }).toList(),
      ),

      const SizedBox(height: 10),
      // Text.rich(
      //   TextSpan(
      //     children: <TextSpan>[
      //       TextSpan(
      //         text: 'Service Number: ',
      //         style: TextStyle(
      //             fontWeight: FontWeight.bold,
      //             color: Colors.black.withOpacity(0.6),
      //             fontSize: 14),
      //       ),
      //       TextSpan(
      //         text: detail['serviceno'],
      //         style: TextStyle(
      //             fontWeight: FontWeight.bold,
      //             color: Colors.black.withOpacity(0.6),
      //             fontSize: 14),
      //       ),
      //     ],
      //   ),
      // ),
    ];
  }
}
