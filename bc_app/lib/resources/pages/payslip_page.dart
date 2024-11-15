import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/controllers/home_controller.dart';
import 'package:bc_app/app/models/payslip.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/config/constants.dart';
import 'package:bc_app/resources/pages/webview_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/payslip_empty_widget.dart';
import 'package:bc_app/resources/widgets/custom_scaffold_widget.dart';
import 'package:bc_app/resources/widgets/safearea_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bc_app/resources/widgets/components/date_input_widget.dart';
import 'package:bc_app/resources/widgets/components/payslip_card_widget.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class PayslipPage extends NyStatefulWidget<HomeController> {
  static const path = '/payslip';

  PayslipPage({super.key}) : super(path, child: _PayslipPageState());
}

BoxDecoration myBoxDecoration(double width) {
  return BoxDecoration(
    border: Border.all(color: Colors.black26, width: width),
    borderRadius: BorderRadius.circular(10),
  );
}

class _PayslipPageState extends NyState<PayslipPage> {
  bool isSF = true;

  TextEditingController preStartDate = TextEditingController();
  TextEditingController preEndDate = TextEditingController();
  TextEditingController startDate = TextEditingController();
  TextEditingController endDate = TextEditingController();
  List<Payslip> payslipList = [];
  List<Payslip> ir8eForms = [];
  List<Payslip> awsBonusPaylipsLists = [];
  List<Payslip> correctionPaylipsLists = [];
  String selectedType = "Payslip";
  ApiController apiController = ApiController();
  bool onLoading = false;

  @override
  boot() async {
    String langPref = await NyStorage.read<String>('languagePref') ?? 'en';
    changeLanguage(langPref);
    DateTime now = DateTime.now();
    DateTime beginDate = DateTime(now.year, now.month - 6, 1);
    DateTime lastDate = DateTime(now.year, now.month + 1, 0);

    preStartDate.text = stringifyDate(beginDate, format: 'MMM yyyy');
    preEndDate.text = stringifyDate(lastDate, format: 'MMM yyyy');

    await retrievePayslips();
  }

  changeSelectedType(String type) async {
    if (type == selectedType) return;
    setState(() => selectedType = type);
    switch (type) {
      case "IR8E":
        await retrieveIR8eForms();
        break;
      case "Payslip":
        await retrievePayslips();
        break;
      case "AWS / Bonus":
        await retrieveAWSBonusPayslips();
        break;
      case "Correction":
        await retrieveCorrectionPaysips();
        break;
    }
  }

  buildFilterButton(String text, String value) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
              backgroundColor: selectedType == value ? Colors.blue :Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              foregroundColor: ThemeColor.get(context).primaryContent),
      onPressed: () {
        setState(() async {
          await changeSelectedType(value);
        });
      },
      child: Text(text, textScaler: TextScaler.noScaling,)
    );
  }

  retrievePayslips() async {
    final dateFrom =
        toDatetime("01 ${preStartDate.text}", format: 'dd MMM yyyy');
    final dt = toDatetime("01 ${preEndDate.text}", format: 'dd MMM yyyy');
    final dateTo = DateTime(dt!.year, dt.month + 1, 0);
    setState(() {
      startDate.text = preStartDate.text;
      endDate.text = preEndDate.text;
      onLoading = true;
    });
    final items = await apiController.getPayslips(
      context: context,
      startDate: stringifyDate(dateFrom, format: 'yyyy-MM-dd'),
      endDate: stringifyDate(dateTo, format: 'yyyy-MM-dd'),
    );
    setState(() {
      payslipList = items;
      onLoading = false;
    });
  }

  retrieveAWSBonusPayslips() async {
    setState(() {
      onLoading = true;
    });
    final items = await apiController.getAWSBonusPayslips(context: context);
    setState(() {
      awsBonusPaylipsLists = items;
      onLoading = false;
    });
  }

  retrieveCorrectionPaysips() async {
    setState(() {
      onLoading = true;
    });
    final items = await apiController.getCorrectionPayslips(context: context);
    setState(() {
      correctionPaylipsLists = items;
      onLoading = false;
    });
  }

  retrieveIR8eForms() async {
    setState(() {
      onLoading = true;
    });
    final items = await apiController.getIR8eForm(context: context);
    setState(() {
      ir8eForms = items;
      onLoading = false;
    });
  }

  Future<void> openWebView(url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(
      uri,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: const WebViewConfiguration(
        enableJavaScript: true,
      ),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  void _handleLinkToSF() {
    String uriLink =
        'https://performancemanager10.successfactors.com//sf/latestpayperiod/login?company=smrtcorpD';
    Navigator.pushNamed(context, WebviewPage.path, arguments: {'url': uriLink});
  }

  /// The [view] method should display your page.
  @override
  Widget view(BuildContext context) {
    return CustomScaffold(
      body: SafeAreaWidget(
        child: SingleChildScrollView(
          child: Constants.isSfUser
              ? Center(
                  child: ElevatedButton(
                    onPressed: _handleLinkToSF,
                    child: const Text("Link to SF Payslip", textScaler: TextScaler.noScaling,),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(12.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "payslip_page.title".tr(),
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          fontFamily: "Poppins-Bold",
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            buildFilterButton("payslip_page.filter label payslip".tr(), 'Payslip'),
                            buildFilterButton("IR8E", "IR8E"),
                            buildFilterButton("AWS / Bonus", "AWS / Bonus"),
                            buildFilterButton("Correction", "Correction"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Visibility(
                        visible: selectedType == 'Payslip',
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DateInput(
                                  label: "payslip_page.start date".tr(),
                                  onTap: () => _showBottomSheet(context),
                                  dateController: startDate,
                                  width: 140),
                              Text(
                                "payslip_page.to".tr(),
                                textScaler: TextScaler.noScaling,
                              ),
                              DateInput(
                                  label: "payslip_page.end date".tr(),
                                  onTap: () => _showBottomSheet(context),
                                  dateController: endDate,
                                  width: 140),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: selectedType == 'Payslip',
                        child: const SizedBox(height: 20.0),
                      ),
                      Visibility(
                        visible: selectedType == 'Payslip',
                        child: onLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                                children: payslipList.isEmpty
                                    ? [const PayslipEmpty()]
                                    : payslipList
                                        .map((i) => PayslipCard(data: i, type: selectedType))
                                        .toList(), // Create a list of widgets
                              ),
                      ),
                      Visibility(
                        visible: selectedType == 'IR8E',
                        child: onLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                                children: ir8eForms.isEmpty
                                    ? [const PayslipEmpty()]
                                    : ir8eForms
                                        .map((i) => PayslipCard(data: i, type: selectedType))
                                        .toList(), // Create a list of widgets
                              ),
                      ),
                      Visibility(
                        visible: selectedType == 'AWS / Bonus',
                        child: onLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                                children: awsBonusPaylipsLists.isEmpty
                                    ? [const PayslipEmpty()]
                                    : awsBonusPaylipsLists
                                        .map((i) => PayslipCard(data: i, type: selectedType))
                                        .toList(), // Create a list of widgets
                              ),
                      ),
                      Visibility(
                        visible: selectedType == 'Correction',
                        child: onLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                                children: correctionPaylipsLists.isEmpty
                                    ? [const PayslipEmpty()]
                                    : correctionPaylipsLists
                                        .map((i) => PayslipCard(data: i, type: selectedType))
                                        .toList(), // Create a list of widgets
                              ),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 500,
          child: Padding(
            padding: const EdgeInsets.all(25.5),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "payslip_page.date_selection_modal.title".tr(),
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins-Bold",
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(decoration: myBoxDecoration(0.5)),
                const SizedBox(height: 20.0),
                Text(
                  "payslip_page.date_selection_modal.subtitle1".tr(),
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  "payslip_page.date_selection_modal.subtitle2".tr(),
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DateInput(
                      label: "payslip_page.start date".tr(),
                      onTap: () => _selectStartDate(),
                      dateController: preStartDate,
                      width: 140,
                    ),
                    Text("payslip_page.to".tr(), textScaler: TextScaler.noScaling,),
                    DateInput(
                      label: "payslip_page.end date".tr(),
                      onTap: () => _selectEndDate(),
                      dateController: preEndDate,
                      width: 140,
                    ),
                  ],
                ),
                const Spacer(),
                Container(decoration: myBoxDecoration(0.5)),
                ElevatedButton(
                  onPressed: () async {
                    await retrievePayslips();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(241, 245, 251, 255),
                    foregroundColor: Colors.blue,
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  child: const Text("show", textScaler: TextScaler.noScaling,),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectStartDate() async {
    String lang = await NyStorage.read<String>('languagePref') ?? 'en';
    DateTime initialDate = DateTime.now();
    DateTime firstDate =
        DateTime(initialDate.year, initialDate.month - 6, initialDate.day);
    DateTime lastDate =
        DateTime(initialDate.year, initialDate.month + 6, initialDate.day);
    DateTime? picked = await showMonthPicker(
        context: context,
        locale: Locale(lang),
        initialDate: firstDate,
        firstDate: firstDate,
        lastDate: lastDate,
        headerColor: Colors.white,
        headerTextColor: Colors.black);

    if (picked != null) {
      setState(() {
        String dateText = stringifyDate(picked, format: 'MMM yyyy');
        // formatDate(_picked.toString().split(" ")[0].substring(0, 7));
        preStartDate.text = dateText;
      });
    }
  }

  Future<void> _selectEndDate() async {
    String lang = await NyStorage.read<String>('languagePref') ?? 'en';
    DateTime initialDate = DateTime.now();
    DateTime firstDate =
        DateTime(initialDate.year, initialDate.month - 6, initialDate.day);
    DateTime lastDate =
        DateTime(initialDate.year, initialDate.month + 6, initialDate.day);
    DateTime? picked = await showMonthPicker(
        context: context,
        locale: Locale(lang),
        initialDate: DateTime.now(),
        firstDate: firstDate,
        lastDate: lastDate,
        headerColor: Colors.white,
        headerTextColor: Colors.black);

    if (picked != null) {
      setState(() {
        String dateText = stringifyDate(picked, format: 'MMM yyyy');
        // formatDate(_picked.toString().split(" ")[0].substring(0, 7));
        preEndDate.text = dateText;
      });
    }
  }

  bool get isThemeDark =>
      ThemeProvider.controllerOf(context).currentThemeId ==
      getEnv('DARK_THEME_ID');
}
