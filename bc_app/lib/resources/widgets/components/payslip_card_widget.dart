import 'package:bc_app/app/models/payslip.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/pdf_view_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:url_launcher/url_launcher.dart';

class PayslipCard extends StatefulWidget {
  final Payslip data;
  final String type;

  const PayslipCard({
    Key? key,
    required this.data,
    required this.type
  }) : super(key: key);

  @override
  _PayslipCardState createState() => _PayslipCardState();
}

BoxDecoration myBoxDecoration(BuildContext context,double width) {
  return BoxDecoration(
    color: ThemeColor.get(context).cardBg,
    border: Border.all(color: Colors.black26, width: width),
    borderRadius: BorderRadius.circular(10),
  );
}



class _PayslipCardState extends State<PayslipCard> {
  String _langPref = '';

  _init() async {
    String langPref = await NyStorage.read<String>('languagePref') ??'en';

    setState(() {
      _langPref = langPref;
    });
  }
  
  getTitleText() {
    switch(widget.type) {
      case "Payslip":
        return  getFormattedDate(parsedDate('MMM yyyy', widget.data.month), 'MMM yyyy', 'M月 yyyy年', _langPref);
      case "IR8E":
        return widget.data.type;
      case "AWS / Bonus":
        return widget.data.payslipCodeName;
      case "Correction":
        return widget.data.payslipCodeName;
    }
  }

  getSubtitleText() {
    switch(widget.type) {
      case "Payslip":
        return  reformatDateDisplay(widget.data.range);
      case "IR8E":
        return getFormattedDate(parsedDate('MMM yyyy', widget.data.month), 'MMM yyyy', 'M月 yyyy年', _langPref);
      case "AWS / Bonus":
        return getFormattedDate(parsedDate('MMM yyyy', widget.data.month), 'MMM yyyy', 'M月 yyyy年', _langPref);
      case "Correction":
        return getFormattedDate(parsedDate('MMM yyyy', widget.data.month), 'MMM yyyy', 'M月 yyyy年', _langPref);
    }
  }

  reformatDateDisplay(String dateRange) {
    List<String> splitString = dateRange.split(" - ");
    String startDate = splitString[0];
    String endDate = splitString[1];

    String formattedStartDate = getFormattedDate(parsedDate('dd MMM yyyy', startDate), 'dd MMM yyyy', 'dd日 M月 yyyy年', _langPref);
    String formattedEndDate = getFormattedDate(parsedDate('dd MMM yyyy', endDate), 'dd MMM yyyy', 'dd日 M月 yyyy年',  _langPref);

    return "$formattedStartDate - $formattedEndDate";
  }

 

  @override
  Widget build(BuildContext context) {
    //Initialize variable
    _init();

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          PdfViewPage.path,
          arguments: {'payslip': widget.data, 'type': 'payslip'},
        );
      },
      child: Container(
        decoration: myBoxDecoration(context, 1),
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.all(15.0), //
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'public/assets/images/file_dock.png',
              width: 25.0,
              height: 25.0,
            ),
            const SizedBox(width: 10),
            Container(
              width: MediaQuery.of(context).size.width / 2,
              // decoration: BoxDecoration(
              //   border: Border.all(width: 1)
              // ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    getTitleText(),
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    getSubtitleText(),
                    maxLines: 3,
                    textScaler: TextScaler.noScaling,
                  )
                ],
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: ThemeColor.get(context).primaryContent,
              size: 20,
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
