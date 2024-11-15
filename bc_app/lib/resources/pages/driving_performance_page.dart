import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/driving_performance_monthly.dart';
import 'package:bc_app/resources/widgets/custom_scaffold_widget.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';
import 'driving_performance_detail_page.dart'; // Import the detail page

class DrivingPerformancePage extends NyStatefulWidget {
  static const path = '/driving-performance';

  DrivingPerformancePage({super.key})
      : super(path, child: _DrivingPerformancePageState());
}

class _DrivingPerformancePageState extends NyState<DrivingPerformancePage> {
  ApiController apiController = ApiController();
  List<DrivingPerformanceMonthly> perfList = [];

  String _langPref = '';

  @override
  init() async {
    String langPref = await NyStorage.read<String>('languagePref') ??'en';

    setState(() {
      _langPref = langPref;
    });

    retrievePerformanceList();
  }

  retrievePerformanceList() async {
    final items = await apiController.getMonthlyDrivingPerformance(
      context: context,
    );

    if (items.isNotEmpty) {
      setState(() {
        perfList = items;
      });
    }
  }

  String getDominantType(Map<String, int> occurrence) {
    if (occurrence['Excellent']! >= occurrence['Good']! &&
        occurrence['Excellent']! >= occurrence['NeedToImprove']!) {
      return 'excellent';
    } else if (occurrence['Good']! >= occurrence['Excellent']! &&
        occurrence['Good']! >= occurrence['NeedToImprove']!) {
      return 'good';
    } else {
      return 'need_improve';
    }
  }

  @override
  Widget view(BuildContext context) {
    return CustomScaffold(
      body: MasterLayout(
        child: ListView(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "driving_performance_page.main_screen.title".tr(),
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      fontFamily: "Poppins-Bold",
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            perfList.isEmpty 
            ? Center(
                child: Text(
                  "no data".tr(),
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    color: ThemeColor.get(context).primaryAccent
                  )
                )
              )
            : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: perfList.length,
              itemBuilder: (context, index) {
                DrivingPerformanceMonthly performance = perfList[index];
                Map<String, int> events =
                    performance.eventsCount; // Events list
                Map<String, int> occurrence = performance.performanceCount;
                String dominantType = getDominantType(occurrence);
                String interventionStatus = performance.interventionStatus;
                String iconPath;
                if (dominantType == 'excellent') {
                  iconPath = 'public/assets/images/star.png';
                } else if (dominantType == 'good') {
                  iconPath = 'public/assets/images/thumb_up.png';
                } else {
                  iconPath = 'public/assets/images/block.png';
                }

                // DateTime monthDate =
                //     DateFormat("MMMM yyyy").parse(performance.date);
                // String formattedMonth =
                //     DateFormat("MMMM yyyy").format(monthDate);

                return GestureDetector(
                  onTap: () {
                    routeTo(DrivingPerformanceDetailPage.path,
                        data: performance.date);
                    // routeTo(DrivingPerformanceDetailPage.path,
                    //     data: cardData[index]);
                  },
                  child: Card(
                    color: ThemeColor.get(context).cardBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getFormattedDate(parsedDate('MMMM yyyy', performance.date), 'MMMM yyyy', 'M月 yyyy年', _langPref),
                                textScaler: TextScaler.noScaling,
                                style: const TextStyle(
                                  fontFamily: "Poppins-Bold",
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "driving_performance_page.main_screen.driving behaviour events".tr(),
                                textScaler: TextScaler.noScaling,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold
                                )                                
                              ),
                              const SizedBox(height: 8),
                              events.isEmpty
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
                                  child: Text(
                                    "no events".tr(),
                                    textScaler: TextScaler.noScaling,
                                  ),
                                )
                              :Wrap(
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
                              const SizedBox(height: 8),
                              Text(
                                "driving_performance_page.main_screen.total occurrence count".tr(),
                                textScaler: TextScaler.noScaling,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    "driving_performance_page.main_screen.excellent".tr(),
                                    textScaler: TextScaler.noScaling,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF95959D),
                                    ),
                                  ),
                                  Text(
                                    occurrence['Excellent'].toString(),
                                    textScaler: TextScaler.noScaling,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF95959D),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    "driving_performance_page.main_screen.good".tr(),
                                    textScaler: TextScaler.noScaling,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF95959D),
                                    ),
                                  ),
                                  Text(
                                    occurrence['Good'].toString(),
                                    textScaler: TextScaler.noScaling,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF95959D),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    "driving_performance_page.main_screen.need to improve".tr(),
                                    textScaler: TextScaler.noScaling,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF95959D),
                                    ),
                                  ),
                                  Text(
                                    occurrence['NeedToImprove'].toString(),
                                    textScaler: TextScaler.noScaling,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF95959D),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "driving_performance_page.main_screen.intervention status".tr(),
                                textScaler: TextScaler.noScaling,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold
                                )
                              ),
                              const SizedBox(height: 8),
                              Text(
                                interventionStatus.toString(),
                                textScaler: TextScaler.noScaling,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Poppins-Bold",
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Image.asset(
                              iconPath,
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
