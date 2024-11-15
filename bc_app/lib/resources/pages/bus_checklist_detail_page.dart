import 'package:bc_app/app/models/bus_check_history.dart';
import 'package:bc_app/app/networking/api_service.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '/app/controllers/home_controller.dart';

class BusChecklistDetailPage extends NyStatefulWidget<HomeController> {
  static const path = '/checklist-detail';

  BusChecklistDetailPage({super.key})
      : super(path, child: _BusChecklistDetailPageState());
}

BoxDecoration myBoxDecoration(BuildContext context, double width) {
  return BoxDecoration(
    border: Border.all(color: ThemeColor.get(context).myBoxDecorationLine, width: width),
    borderRadius: BorderRadius.circular(10),
  );
}

class _BusChecklistDetailPageState extends NyState<BusChecklistDetailPage> {
  String? selected_type = "";
  String? selected_quantity = "";
  String? selected_size = "";
  String lang = '';

  List<String> label_list = [
    'Uniform Type',
    'Total Entitlement',
    'Used',
    'Remaining'
  ];

  bool entitlement = true;

  @override
  boot() async{
    lang = await NyStorage.read<String>('languagePref') ?? 'en';
  }

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse('$date-01');

    DateFormat formatter = DateFormat('MMM yyyy');

    String formattedDate = formatter.format(dateTime);

    return formattedDate;
  }


  String baseUrl = ApiService().baseUrl;

  /// The [view] method should display your page.
  @override
  Widget view(BuildContext context) {
    final BusCheckHistory selectedChecklist =
        ModalRoute.of(context)!.settings.arguments as BusCheckHistory;
    return Scaffold(
      appBar: TitleBar(title: "buscheck_page.checklist_details_screen.title".tr()),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.5, right: 15.5, top: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min, // This line is updated
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildRow(
                    "buscheck_page.checklist_details_screen.bus plate".tr(),
                    selectedChecklist.plate),
                const SizedBox(height: 10),
                Container(decoration: myBoxDecoration(context, 0.5)),
                const SizedBox(height: 10),
                buildRow("buscheck_page.checklist_details_screen.depot".tr(),
                    selectedChecklist.depot),
                const SizedBox(height: 10),
                Container(decoration: myBoxDecoration(context, 0.5)),
                const SizedBox(height: 10),
                buildRow(
                    "buscheck_page.checklist_details_screen.task type".tr(),
                    "buscheck_page.checklist_screen.${selectedChecklist.type.toLowerCase()}".tr()),
                const SizedBox(height: 10),
                // Container(decoration: myBoxDecoration(context, 0.5)),
                // const SizedBox(height: 10),
                // buildRow("buscheck_page.checklist_details_screen.action".tr(),
                //     selectedChecklist.bctAction),
                // const SizedBox(height: 10),
                Container(decoration: myBoxDecoration(context, 0.5)),
                const SizedBox(height: 10),
                buildRow(
                    "buscheck_page.checklist_details_screen.submitted date time"
                        .tr(),
                    selectedChecklist.submittedTime),
                const SizedBox(height: 10),
                Container(decoration: myBoxDecoration(context, 0.55)),
                const SizedBox(height: 10),
                buildStatusRow(
                    "buscheck_page.checklist_details_screen.status".tr(),
                    selectedChecklist.status,
                    selectedChecklist.status),
                const SizedBox(height: 10),
                Container(decoration: myBoxDecoration(context, 0.5)),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .start, // Ensures alignment to the start
                  children: [
                    Text(
                      'buscheck_page.checklist_details_screen.items'.tr(),
                      textScaler: TextScaler.noScaling,
                      textAlign: TextAlign.left, // Aligns the text to the start
                      style: TextStyle(
                        fontFamily: 'Poppins-SemiBold',
                        fontWeight: FontWeight.w400,
                        color: ThemeColor.get(context).primaryContent
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'buscheck_page.checklist_details_screen.items message'.tr(),
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    )
                    // Other children widgets can go here
                  ],
                ),
                const SizedBox(height: 10),
                Container(decoration: myBoxDecoration(context, 0.5)),
                const SizedBox(height: 10),
                Column(
                  children: selectedChecklist.checkResults.toList().map((cx) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 6.0),
                                child: Text(cx['description${lang.capitalize()}'], textScaler: TextScaler.noScaling,),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 16),
                              child: SizedBox(
                                width: 60,
                                height: cx['photos'] != null ? 60 : 0,
                                child: cx['photos'] != null
                                    ? Image.network(
                                        "$baseUrl${cx['photos'][0]['url']}", // Replace with your URL
                                        fit: BoxFit.cover,
                                      )
                                    : const SizedBox(),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 5.0,
                            left: 6.0,
                            top: 12.0,
                          ),
                          child: Text(
                            'buscheck_page.checklist_details_screen.remarks'
                                .tr(),
                            textScaler: TextScaler.noScaling,
                            style: const TextStyle(fontFamily: 'Poppins-bold'),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 6.0),
                                child: Text(cx['remarks'] == null
                                    ? '-'
                                    : cx['remarks'].toString(),
                                    textScaler: TextScaler.noScaling,),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 16),
                              child: SizedBox(
                                width: 60,
                                height: cx['photos'] != null &&
                                        cx['photos'].length > 1
                                    ? 60
                                    : 0,
                                child: cx['photos'] != null &&
                                        cx['photos'].length > 1
                                    ? Image.network(
                                        "$baseUrl${cx['photos'][1]['url']}", // Replace with your URL
                                        fit: BoxFit.cover,
                                      )
                                    : const SizedBox(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(decoration: myBoxDecoration(context, 0.25)),
                        const SizedBox(height: 10),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
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
          style: TextStyle(
            fontSize: 14,
            color: ThemeColor.get(context).primaryContent
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            value.isNotEmpty ? value : '-',
            textScaler: TextScaler.noScaling,
            textAlign: TextAlign.right,
            style: const TextStyle(fontFamily: 'Poppins-bold', fontSize: 13),
          ),
        )
      ],
    );
  }

  Widget buildStatusRow(String title, String status, String statusText) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Text(title, textScaler: TextScaler.noScaling,),
        ),
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: getBusChecklistStatusColor(status),
            ),
            padding: const EdgeInsets.only(top: 3, bottom: 3, left: 0),
            child: Text(
              "buscheck_page.checklist_screen.filter label ${statusText.toLowerCase()}".tr(),
              textScaler: TextScaler.noScaling,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontFamily: 'Poppins-bold'),
            ),
          ),
        ),
      ],
    );
  }

  bool get isThemeDark =>
      ThemeProvider.controllerOf(context).currentThemeId ==
      getEnv('DARK_THEME_ID');
}
