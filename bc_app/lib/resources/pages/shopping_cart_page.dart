import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/uniform_request.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/home_page.dart';
import 'package:bc_app/resources/pages/uniformrequest_page.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:bc_app/resources/widgets/shopping_cart_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter/material.dart';
import 'package:bc_app/resources/widgets/components/input_dropdown_widget.dart';
import '/app/controllers/home_controller.dart';
import 'dart:convert';
import 'package:bc_app/resources/utils.dart';

class ShoppingCartPage extends NyStatefulWidget<HomeController> {
  static const path = '/shopping-cart';

  ShoppingCartPage({super.key}) : super(path, child: _ShoppingCartPageState());
}

BoxDecoration myBoxDecoration(double width) {
  return BoxDecoration(
    border: Border.all(color: Colors.black26, width: width),
    borderRadius: BorderRadius.circular(10),
  );
}

class _ShoppingCartPageState extends NyState<ShoppingCartPage> {
  List<String> pickupLocations = [
    'Soon Lee Depot',
    'Kranji Depot',
    'Woodlands Depot'
  ];
  String? selectedLocation;
  List<UniformRequest> carts = [];
  // TextEditingController reasonController = TextEditingController();
  ApiController apiController = ApiController();
  bool onLoading = false;

  Future<void> _storeData(thedata) async {
    await NyStorage.storeJson("cart_list", thedata);
  }

  String convertListToJson(List<UniformRequest> thelist) {
    // Convert each Request in the list to a Map and then encode the list of Maps as a JSON string.
    return jsonEncode(thelist.map((request) => request.toJson()).toList());
  }

  List<UniformRequest> convertJsonToList(String jsonString) {
    List<dynamic> jsonData = jsonDecode(jsonString);
    return jsonData.map((item) => UniformRequest.fromJson(item)).toList();
  }

  bool _validateForm() {
    if (carts.isEmpty) {
      showSnackBar(context, "uniform_request_page.shopping_cart_screen.shopping cart field alert message".tr(), isSuccess: false);
      return false;
    }
    if (selectedLocation == null) {
      showSnackBar(context, "uniform_request_page.shopping_cart_screen.selected location field alert message".tr(), isSuccess: false);
      return false;
    }
    return true;
  }

  Future<void> submit() async {
    if (onLoading) return;
    if(!_validateForm()) return;

    bool showDialog = false;

    setState(() => onLoading = true);
    final json = convertListToJson(carts);
    final res = await apiController.onSubmitUniformRequest(
      context: context,
      carts: carts.map((item) {
        if (item.size == "MTM") showDialog = true;
        return item.toJson();
      }).toList(),
      pickupLocation: selectedLocation!,
      // reason: reasonController.text,
    );
    setState(() => onLoading = false);

    if (!res) return;
    
    print("Show dialog = $showDialog");

    await NyStorage.storeJson("cart_list", []);
    
    if (showDialog) {
      await _showConfirmation(context); 
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      UniformRequestPage.path,
      ModalRoute.withName(HomePage.path),
    );
  }

  Future<void> _showConfirmation(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "uniform_request_page.shopping_cart_screen.submission alert".tr(),
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Text(
                  'uniform_request_page.shopping_cart_screen.submission alert message'.tr(),
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    color: ThemeColor.get(context).primaryContent,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  boot() async {
    // String langPref = await NyStorage.read<String>('languagePref') ?? '';
    // changeLanguage(langPref);

    List<dynamic>? storedCartList = await NyStorage.readJson("cart_list");

    if (storedCartList != null) {
      String jsonString = jsonEncode(storedCartList);
      List<UniformRequest> newCarts = convertJsonToList(jsonString);
      setState(() {
        carts = newCarts;
      });
    }
  }

  /// The [view] method should display your page.
  @override
  Widget view(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (value) async {
        // Prevent default back button behavior
        routeTo(UniformRequestPage.path,
          navigationType: NavigationType.pushAndRemoveUntil,
            removeUntilPredicate: ModalRoute.withName(HomePage.path),
            pageTransition: PageTransitionType.leftToRight
        );
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('', textScaler: TextScaler.noScaling,),
          backgroundColor: ThemeColor.get(context).background,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: ThemeColor.get(context).backButtonIcon,
              size: 30.0,
            ),
            onPressed: () {
              routeTo(UniformRequestPage.path,
                  navigationType: NavigationType.pushAndRemoveUntil,
                  removeUntilPredicate: ModalRoute.withName(HomePage.path),
                  pageTransition: PageTransitionType.leftToRight);
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.5, right: 15.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      "uniform_request_page.shopping_cart_screen.title".tr(),
                      textScaler: TextScaler.noScaling,
                      style:const TextStyle(fontFamily: 'Poppins-bold', fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  carts.isEmpty
                  ? Center(
                    child: Text(
                      "uniform_request_page.shopping_cart_screen.shopping cart empty".tr(),
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: ThemeColor.get(context).primaryContent
                      )
                    ), 
                    
                  )
                  : const SizedBox(),
                  ...carts.map((item) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(height: 70),
                            Expanded(
                              flex: 3,
                              child: Text(
                                item.type,
                                textScaler: TextScaler.noScaling,
                                style: const TextStyle(
                                  fontFamily: 'Poppins-bold',
                                  height: 1.2,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                item.qty.toString(),
                                textScaler: TextScaler.noScaling,
                                textAlign: TextAlign.center,
                                style:
                                    const TextStyle(fontFamily: 'Poppins-bold'),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  List<UniformRequest> newList = carts;
                                  final index = newList.indexWhere((it) {
                                    return it.orderno == item.orderno;
                                  });
                                  newList.removeAt(index);
                                  setState(() {
                                    carts = newList;
                                  });
                                  await _storeData(newList);
                                  updateState(ShoppingCart.state);
                                },
                                child: const Image(
                                  width: 30,
                                  height: 30,
                                  image: AssetImage(
                                      'public/assets/images/trash-bin.png'),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            item.size,
                            textScaler: TextScaler.noScaling,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontFamily: 'Poppins-bold',
                              color: Color(0xFF1570EF),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(decoration: myBoxDecoration(0.25)),
                      ],
                    );
                  }),
                  const SizedBox(height: 20),
                  carts.isNotEmpty
                      ? InputDropdown(
                          label: 'uniform_request_page.shopping_cart_screen.collection location'.tr(),
                          items: pickupLocations,
                          value: null,
                          placeholder: 'uniform_request_page.shopping_cart_screen.collection location hint'.tr(),
                          editable: true,
                          onChanged: (String? newValue) {
                            setState(() => selectedLocation = newValue);
                          },
                        )
                      : const SizedBox(),
                  // carts.isNotEmpty 
                  //   ? InputTextArea(
                  //       label: 'uniform_request_page.shopping_cart_screen.remarks'.tr(),
                  //       placeholder: 'uniform_request_page.shopping_cart_screen.remarks hint'.tr(),
                  //       textarea: true,
                  //       controller: reasonController,
                  //     )
                  //   : Center(child:Text("uniform_request_page.shopping_cart_screen.no item".tr())),
                  // const SizedBox(height: 20),
                  carts.isNotEmpty 
                  ? Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  UniformRequestPage.path,
                                  ModalRoute.withName(HomePage.path),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ThemeColor.get(context).background, // Set background color to transparent
                                foregroundColor: const Color(
                                    0xFF566789), // Set primary color to transparent
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(
                                      0xFF566789), // Set text color to component's bg color
                                ),
                                shape: const RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Color(
                                        0xFF566789), // Set border color to component's bg color
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                              ),
                              child: Text(
                                "uniform_request_page.shopping_cart_screen.button cancel".tr(),
                                textScaler: TextScaler.noScaling,
                                style: TextStyle(
                                  color: ThemeColor.get(context).drivingLicenseLabel,
                                  fontFamily: 'Poppins-bold'
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: GeneralButton(
                              text:"uniform_request_page.shopping_cart_screen.button submit".tr(),
                              disabled: onLoading,
                              showLoading: onLoading,
                              onPressed: () async {
                                await submit();
                              },
                            )
                          ),
                        ),
                      ],
                    )
                  : const SizedBox(),
                  const SizedBox(height: 25)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get isThemeDark =>
      ThemeProvider.controllerOf(context).currentThemeId ==
      getEnv('DARK_THEME_ID');
}
