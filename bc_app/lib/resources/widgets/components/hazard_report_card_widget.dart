import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/hazard_report.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/hazard_report_detail_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class HazardReportCard extends StatefulWidget {
  final HazardReport data;
  final BuildContext context;

  const HazardReportCard({
    super.key,
    required this.data,
    required this.context,
  });

  @override
  _HazardReportCardState createState() => _HazardReportCardState();
}

BoxDecoration myBoxDecoration(BuildContext context, double width) {
  return BoxDecoration(
    color: ThemeColor.get(context).cardBg,
    border: Border.all(color: Colors.black26, width: width),
    borderRadius: BorderRadius.circular(10),
  );
}

class _HazardReportCardState extends State<HazardReportCard> {
  ApiController apiController = ApiController();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, HazardReportDetailPage.path, arguments: {
          'data': widget.data,
        });
      },
      child: Container(
        decoration: myBoxDecoration(context, 1),
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.data.caseId,
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                              color: ThemeColor.get(context).primaryContent,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins-Bold",
                            ),
                          ),
                          Container(
                            // width: 150, // Fixed width
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                            decoration: BoxDecoration(
                              color: getHazardReportStatusColor(widget.data.status.toLowerCase()),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            alignment: Alignment.center, // Center the text
                            child: Text(
                              "hazard_report_page.filter label ${widget.data.status.toLowerCase()}".tr(),
                              textScaler: TextScaler.noScaling,
                              textAlign: TextAlign.center, // Center the text horizontally
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.data.description,
                        textScaler: TextScaler.noScaling,
                        maxLines: 2,
                        style: const TextStyle(fontFamily: "Poppins"),
                      ),
                      const SizedBox(width: 5),
                      const SizedBox(height: 5),
                      Text(
                        dateFormatString(
                          widget.data.timeReported,
                          fromFormat: 'yyyy-MM-dd HH:mm',
                          toFormat: 'dd/MM/yyyy, HH:mm',
                        ),
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
