import 'package:bc_app/app/models/bus_check_history.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nylo_framework/nylo_framework.dart';

class BusChecklistCard extends StatefulWidget {
  final BusCheckHistory data;
  final Function handler;
  final BuildContext context;

  const BusChecklistCard({
    super.key,
    required this.data,
    required this.handler,
    required this.context,
  });

  @override
  _PayslipCardState createState() => _PayslipCardState();
}

BoxDecoration myBoxDecoration(BuildContext context,double width) {
  return BoxDecoration(
    border: Border.all(color: ThemeColor.get(context).myBoxDecorationLine, width: width),
    borderRadius: BorderRadius.circular(10),
  );
}

class _PayslipCardState extends State<BusChecklistCard> {
  //TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.handler();
      },
      child: Container(
        decoration: myBoxDecoration(context, 1),
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.all(15.0), //
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "buscheck_page.checklist_screen.${widget.data.type.toLowerCase()}".tr(),
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          color: ThemeColor.get(context).primaryContent,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins-Bold",
                        ),
                      ),
                      Text(
                        widget.data.plate.isNotEmpty ? widget.data.plate : '-',
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(fontFamily: "Poppins"),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${"buscheck_page.checklist_screen.submitted on".tr()} ${widget.data.submittedTime}',
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
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  constraints:
                      const BoxConstraints(minWidth: 110, maxWidth: 140),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getBusChecklistStatusColor(widget.data.status)
                    ),
                    onPressed: () {},
                    child: Text(
                      "buscheck_page.checklist_screen.filter label ${widget.data.status.toLowerCase()}".tr(),
                      textScaler: TextScaler.noScaling,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(fontFamily: "Poppins", fontSize: 13),
                    ),
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

Future<void> _launchUrl(url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
