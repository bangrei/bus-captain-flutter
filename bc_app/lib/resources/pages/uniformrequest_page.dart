import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/controllers/home_controller.dart';
import 'package:bc_app/app/models/uniform_request.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/new_uniformrequest_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/custom_scaffold_widget.dart';
import 'package:bc_app/resources/widgets/safearea_widget.dart';
import 'package:bc_app/resources/widgets/shopping_cart_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter/material.dart';
import 'package:bc_app/resources/widgets/components/uniform_request_card_widget.dart';
import 'dart:convert';

class UniformRequestPage extends NyStatefulWidget<HomeController> {
  static const path = '/uniform-request';

  UniformRequestPage({super.key})
      : super(path, child: _UniformRequestPageState());
}

BoxDecoration myBoxDecoration(BuildContext context, double width) {
  return BoxDecoration(
    border: Border.all(color: ThemeColor.get(context).myBoxDecorationLine, width: width),
    borderRadius: BorderRadius.circular(10),
  );
}

// String truncateWithEllipsis(int maxLength, String text) {
//   return (text.length <= maxLength)
//       ? text
//       : '${text.substring(0, maxLength)}...';
// }

class _UniformRequestPageState extends NyState<UniformRequestPage> {
  String selectedStatus = "All";
  DateTime? _selectedDate;
  UniformRequest? _selectedList;
  List<UniformRequest> thelist = [];
  List<UniformRequest> cartlist = [];

  //For display purposes "Emailed" status will be displayed as "Processing"
  // Map<String, String> statusButtons = {};
  ApiController apiController = ApiController();
  bool onLoading = false;

  Future<void> _storeData(thedata) async {
    await NyStorage.storeJson("cart_list", thedata);
    updateState(ShoppingCart.state);
  }

  List<UniformRequest> convertJsonToList(String jsonString) {
    List<dynamic> jsonData = jsonDecode(jsonString);
    return jsonData.map((item) => UniformRequest.fromJson(item)).toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    String lang = await NyStorage.read<String>('languagePref') ?? 'en';
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: Locale(lang),
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      List<UniformRequest>? reqList = await apiController.getUniformRequests(
        context,
        selectedStatus == "All" ? "" : selectedStatus,
        stringifyDate(picked),
      );
      setState(() {
        _selectedDate = picked;
        thelist = reqList;
      });
    }
  }

  changeStatus(String status) async {
    if (status == selectedStatus) return;
    List<UniformRequest>? reqList = await apiController.getUniformRequests(
      context,
      status == "All" ? "" : status,
      stringifyDate(_selectedDate),
    );
    setState(() {
      selectedStatus = status;
      thelist = reqList;
    });
  }

  Future<void> _refresh() async {
    List<UniformRequest>? reqList = await apiController.getUniformRequests(
      context,
      selectedStatus == "All" ? "" : selectedStatus,
      stringifyDate(_selectedDate),
    );
    setState(() {
      thelist = reqList;
    });
  }
  
  double addHeight(String type, String remarks) {
    double total = 0;
    if (type.length > 30) total += 10;
    if (remarks.length > 30) total += 21;
    return total;
  }

  List<UniformRequest> getFilteredRequests() {
    if (selectedStatus == 'All') return thelist;
    return thelist
        .where((request) => request.status == selectedStatus)
        .toList();
  }

  @override
  boot() async {
    // String langPref = await NyStorage.read<String>('languagePref') ?? '';
    // changeLanguage(langPref);

    //initial status buttons first

    List<UniformRequest>? reqList = await apiController.getUniformRequests(
      context,
      selectedStatus == "All" ? "" : selectedStatus,
      null,
    );
    List<dynamic>? storedCartList = await NyStorage.readJson("cart_list");
    
    if (storedCartList != null) {
      String jsonString = jsonEncode(storedCartList);
      List<UniformRequest> newList = convertJsonToList(jsonString);
      setState(() {
        cartlist = newList;
      });
    }
    
    if (reqList.isEmpty) {
      // _storeData(thelist);
    } else {
      setState(() {
        thelist = reqList;
      });
    }
  }

  buildFilterButton(String text, String value) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
              backgroundColor: selectedStatus == value ? Colors.blue :Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              foregroundColor: ThemeColor.get(context).primaryContent),
      onPressed: () {
        setState(() async {
          await changeStatus(value);
        });
      },
      child: Text(text, textScaler: TextScaler.noScaling,)
    );
  }

  /// The [view] method should display your page.
  @override
  Widget view(BuildContext context) {
    List<UniformRequest> filteredList = getFilteredRequests();
    return CustomScaffold(
      body: SafeAreaWidget(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "uniform_request_page.list_screen.title".tr(),
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(
                    fontFamily: "Poppins-Bold",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, NewUniformRequestPage.path);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1570EF),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(255, 255, 255, 1),
                              ),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(0.0),
                                  topLeft: Radius.circular(0.0),
                                ),
                              ),
                            ),
                            child: Text(
                              "+ ${"uniform_request_page.list_screen.button".tr()}",
                              textScaler: TextScaler.noScaling,
                              style: TextStyle(
                                color: ThemeColor.get(context).appBarPrimaryContent
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(
                      child: ShoppingCart()
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  height: 35,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        buildFilterButton(
                          "uniform_request_page.list_screen.filter label all".tr(), 
                          "All"
                        ),
                        buildFilterButton(
                          "uniform_request_page.list_screen.filter label pending".tr(), 
                          "Pending"
                        ),
                        buildFilterButton(
                          "uniform_request_page.list_screen.filter label ready for collection".tr(),
                          "Ready for Collection"
                        ),
                        buildFilterButton(
                          "uniform_request_page.list_screen.filter label emailed".tr(),
                          "Emailed"
                        ),
                        buildFilterButton(
                          "uniform_request_page.list_screen.filter label collected".tr(),
                          "Collected"
                        ),
                         buildFilterButton(
                          "uniform_request_page.list_screen.filter label cancelled".tr(),
                          "Cancelled"
                        ),    
                      ]
                    )
                  ),
                ),
                const SizedBox(height: 20.0),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF9F9F9),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14.0, vertical: 4.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_selectedDate == null
                              ? 'uniform_request_page.list_screen.submitted date'.tr()
                              : stringifyDate(_selectedDate),
                              textScaler: TextScaler.noScaling,
                          ),
                          const SizedBox(width: 8),
                          _selectedDate == null
                          ? const Icon(Icons.arrow_drop_down)
                          : GestureDetector(
                            onTap:() {
                              setState(() {
                                _selectedDate = null;
                              });
                              _refresh();
                            },
                            child: const Icon(Icons.close, size: 15)
                          )
                        ],
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        _refresh();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(0), // Remove all padding
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                filteredList.isEmpty
                ? Center(child: Text("no data".tr(), textScaler: TextScaler.noScaling,),)
                : Column(
                  children: [
                    ...filteredList.map((i) =>
                      UniformRequestCard(
                        data: i,
                        handler: _showBottomSheet,
                        context: context,
                        onRefresh: _refresh,
                      )
                    )
                  ]
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, UniformRequest data) {
    setState(() {
      _selectedList = data;
    });
    String remark =
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi lobortis felis nunc, non tincidunt lectus varius pretium. Ut tempor lobortis blandit. Sed sed aliquam nibh. Aliquam sagittis ligula elit, dignissim pulvinar odio venenatis ut. Sed placerat leo a condimentum bibendum. Nullam bibendum tempor ex, eu convallis tellus dapibus id. Nunc eu ipsum in lectus facilisis efficitur";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: 370 + addHeight(_selectedList!.name, remark),
          child: Padding(
            padding: const EdgeInsets.all(25.5),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "${"uniform_request_page.bottom_sheet.order no".tr()} ${_selectedList!.orderno}",
                      textScaler: TextScaler.noScaling,
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontFamily: 'Poppins-bold'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(decoration: myBoxDecoration(context, 0.35)),
                const SizedBox(height: 10),
                buildRow("uniform_request_page.bottom_sheet.submitted time".tr(), _selectedList!.submittedTime),
                const SizedBox(height: 10),
                Container(decoration: myBoxDecoration(context, 0.35)),
                buildRow("uniform_request_page.bottom_sheet.item requested".tr(), _selectedList!.name),
                const SizedBox(height: 10),
                Container(decoration: myBoxDecoration(context, 0.35)),
                buildRow("uniform_request_page.bottom_sheet.item size".tr(), _selectedList!.size),
                const SizedBox(height: 10),
                Container(decoration: myBoxDecoration(context, 0.35)),
                buildRow("uniform_request_page.bottom_sheet.quantity".tr(), _selectedList!.qty.toString()),
                const SizedBox(height: 10),
                Container(decoration: myBoxDecoration(context, 0.35)),
                buildRow("uniform_request_page.bottom_sheet.request type".tr(),  _selectedList!.requestType.toString()),
                const SizedBox(height: 10),
                Container(decoration: myBoxDecoration(context, 0.35)),
                buildRow("uniform_request_page.bottom_sheet.pickup location".tr(), _selectedList!.pickupLocation!),
                const SizedBox(height: 10),
                Container(decoration: myBoxDecoration(context, 0.35)),
                buildStatusRow(
                    "uniform_request_page.bottom_sheet.status".tr(), _selectedList!.status, _selectedList!.status),
                const SizedBox(height: 10),
                Container(decoration: myBoxDecoration(context, 0.35)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColor.get(context).surfaceBackground,
                    foregroundColor: Colors.blue,
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  child: Text("uniform_request_page.bottom_sheet.button".tr(), textScaler: TextScaler.noScaling,),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          textScaler: TextScaler.noScaling,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textScaler: TextScaler.noScaling,
            textAlign: TextAlign.right,
            style: const TextStyle(fontFamily: 'Poppins-bold', fontSize: 13),
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            maxLines: 3,
          ),
        ),
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
              color: getUniformStatusColor(status),
            ),
            padding: const EdgeInsets.only(top: 3, bottom: 3, left: 0),
            child: Text(
              "uniform_request_page.list_screen.filter label ${statusText.toLowerCase()}".tr(),
              textScaler: TextScaler.noScaling,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'Poppins-bold',
              ),
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
