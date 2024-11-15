import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/duty_roster.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/job_list_view_widget.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';
import 'package:bc_app/resources/widgets/custom_scaffold_widget.dart';
import 'package:bc_app/resources/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nylo_framework/nylo_framework.dart';

class DutyRosterPage extends NyStatefulWidget {
  static const path = '/duty-roster';

  DutyRosterPage({super.key}) : super(path, child: _DutyRosterPageState());
}

class _DutyRosterPageState extends NyState<DutyRosterPage> {
  DateTime now = DateTime.now();
  late DateTime firstDate;
  late DateTime lastDate;
  late int weekNow = 1;
  late int weekNumber = 1;
  late String day;
  late String month;
  late String yearString;
  late int year;
  late String _langPref;
  List<Duty> jobs = [];

  ApiController apiController = ApiController();
  bool onLoading = false;

  int pageIndexNow = 0;

  @override
  init() async {

  }

  /// Use boot if you need to load data before the [view] is rendered.
  @override
  boot() async {
    String langPref = await NyStorage.read<String>('languagePref') ??'en';

    setState(() {
      _langPref = langPref;
      weekNow = getCurrentWeekNumber();
      weekNumber = getCurrentWeekNumber();
      day = DateFormat('EEE', _langPref).format(now);
      month = DateFormat('MMM', _langPref).format(now);
      yearString = getFormattedDate(now, 'yyyy', 'yyyy年', _langPref);
      year = int.parse(DateFormat('yyyy').format(now));
      firstDate = getFirstDateOfWeek(weekNumber);
    });

    await _fetchData();
  }

  _fetchData() async {
    setState(() => onLoading = true);
    final res = await apiController.getDutyRosters(
      context: context, 
      startDate: stringifyDate(firstDate), 
      endDate: stringifyDate(firstDate.add(const Duration(days: 6)))
    );
    setState(() => onLoading = false);

    setState(() {
      jobs = res;
    });
  }

  int getCurrentWeekNumber() {
    DateTime now = DateTime.now();
    int dayOfYear = int.parse(DateFormat("D").format(now));
    int weekNumber = ((dayOfYear - now.weekday + 10) / 7).floor();
    return weekNumber;
  }

  DateTime getFirstDateOfWeek(int weekNumber) {
    DateTime firstDayOfYear = DateTime(year);
    // int daysOffset = (firstDayOfYear.weekday - DateTime.sunday) % 7;
    // daysOffset = daysOffset == 0 ? 7 : daysOffset;
    // //first day of week is monday
    int daysOffset = (firstDayOfYear.weekday - DateTime.monday) % 7;
    daysOffset = daysOffset == 0 ? 0 : daysOffset;
    DateTime firstDayOfTargetWeek =
        firstDayOfYear.subtract(Duration(days: daysOffset));
    return firstDayOfTargetWeek.add(Duration(days: (weekNumber - 1) * 7));
  }

  void _onChangeDate(int week) async {
    setState(() {
      weekNumber = week;
      firstDate = getFirstDateOfWeek(week);
    });
    await _fetchData();
  }

  Future<void> _refreshJob() async {
    await _fetchData();
  }

  @override
  Widget view(BuildContext context) {
    return CustomScaffold(
        body: Container(
        color: ThemeColor.get(context).background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MasterLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("duty_roster_page.title".tr(),
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      fontFamily: "Poppins-Bold",
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                    )
                  ),
                  const SizedBox(height: 10),
                  Text(
                  "duty_roster_page.message".tr(),
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(
                    fontFamily: "Poppins-Bold",
                    color: Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold
                    )
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Text("${now.day}",
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(
                          fontSize: 45.76, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(day,
                                textScaler: TextScaler.noScaling,
                                style: const TextStyle(color: Color(0xFFBCC1CD))),
                            Text("$month $yearString",
                                textScaler: TextScaler.noScaling,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFBCC1CD)))
                          ],
                        ),
                      ),
                      Container(
                        width: 85,
                        height: 41,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: nyHexColor('4DC591').withOpacity(0.1)),
                        child: Center(
                          child: Text(
                            "duty_roster_page.today".tr(),
                            textScaler: TextScaler.noScaling,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4DC591)),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                  decoration: BoxDecoration(
                    color: ThemeColor.get(context).background,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(32),
                      topLeft: Radius.circular(32),
                    ),
                  ),
                  child: PageView.builder(
                    itemCount: 3,
                    onPageChanged: (index) {
                      int diffPage = index-pageIndexNow;
                      debugPrint("Diff Page: $diffPage");
                      debugPrint("Week Number: $weekNumber");
                      setState(() {
                        pageIndexNow = index;
                        weekNumber += diffPage;
                      });
                      _onChangeDate(weekNumber);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: nyHexColor('1570EF')),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.calendar_today_outlined,
                                        color: Colors.white, size: 18.0),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${DateFormat('dd/MM/y').format(firstDate)} - ${DateFormat('dd/MM/y').format(firstDate.add(const Duration(days: 6)))}",
                                      textScaler: TextScaler.noScaling,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17
                                        ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 5)
,                             const Divider(height: 0, color: Color(0xFFF6F6F6)),
                              onLoading 
                              ? const Expanded(child: Center(child: Loader()))
                              : Expanded(
                                  child: JobListView(jobs: jobs, refreshJob: _refreshJob)
                                )
                            ],
                          ),
                        ),
                      );
                    }
                  )
              )
            )
            // Expanded(
            //   child: Container(
            //       decoration: BoxDecoration(
            //         color: ThemeColor.get(context).background,
            //         borderRadius: const BorderRadius.only(
            //           topRight: Radius.circular(32),
            //           topLeft: Radius.circular(32),
            //         ),
            //       ),
            //       child: Column(
            //         children: [
            //           Padding(
            //             padding: const EdgeInsets.symmetric(vertical: 20),
            //             child: SingleChildScrollView(
            //               scrollDirection: Axis.horizontal,
            //               child: Row(
            //                 mainAxisAlignment: MainAxisAlignment.center,
            //                 children: [
            //                   IconButton(
            //                       disabledColor: Colors.transparent,
            //                       onPressed: weekNumber == weekNow
            //                           ? null
            //                           : () {
            //                               weekNumber -= 1;
            //                               _onChangeDate(weekNumber);
            //                             },
            //                       icon: const Icon(Icons.chevron_left, size: 24)),
            //                   Container(
            //                     padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            //                     decoration: BoxDecoration(
            //                         borderRadius: BorderRadius.circular(16),
            //                         color: nyHexColor('1570EF')),
            //                     child: Row(
            //                       children: [
            //                         const Icon(Icons.calendar_today_outlined,
            //                             color: Colors.white, size: 18.0),
            //                         const SizedBox(width: 8),
            //                         Text(
            //                           "${DateFormat('dd/MM/y').format(firstDate)} - ${DateFormat('dd/MM/y').format(firstDate.add(const Duration(days: 6)))}",
            //                           textScaler: TextScaler.noScaling,
            //                           style: const TextStyle(
            //                               color: Colors.white,
            //                               fontWeight: FontWeight.w600,
            //                               fontSize: 17
            //                             ),
            //                         )
            //                       ],
            //                     ),
            //                   ),
            //                   IconButton(
            //                       disabledColor: Colors.transparent,
            //                       onPressed: weekNumber == weekNow + 2
            //                           ? null
            //                           : () {
            //                               weekNumber += 1;
            //                               _onChangeDate(weekNumber);
            //                             },
            //                       icon: const Icon(Icons.chevron_right, size: 24)),
            //                 ],
            //               ),
            //             ),
            //           ),
            //           const Divider(height: 0, color: Color(0xFFF6F6F6)),
            //           onLoading 
            //             ? const Center(child: Loader())
            //             : Expanded(
            //                 child: JobListView(jobs: jobs, refreshJob: _refreshJob)
            //               )
            //         ],
            //       )),
            // )
          ],
        ),
      )
    );
  }
}
