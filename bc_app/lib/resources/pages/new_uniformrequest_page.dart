import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/uniform_request.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/home_page.dart';
import 'package:bc_app/resources/pages/uniformrequest_page.dart';
import 'package:bc_app/resources/widgets/components/input_dropdown_widget.dart';
import 'package:bc_app/resources/widgets/shopping_cart_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter/material.dart';
import '/app/controllers/home_controller.dart';
import 'dart:convert';
import 'package:bc_app/resources/utils.dart';

class NewUniformRequestPage extends NyStatefulWidget<HomeController> {
  static const path = '/new-uniformrequest';

  NewUniformRequestPage({super.key})
      : super(path, child: _NewUniformRequestPageState());
}


class _NewUniformRequestPageState extends NyState<NewUniformRequestPage> {
  String? selectedItem = "";
  String? selectedQty = "";
  String? selectedSize = "";
  String? selectedGender = "";

  List<UniformRequest> cartList = [];

  bool entitlement = true;
  bool inLoading = false;
  List<dynamic>? uniformItems;
  List<String>? uniformSizes;
  List<String>? uniformType;
  List<String>? uniformDroplist;
  Map? entitlementGuide;
  List<Map> selectedEntitlement = [];
  List<int> entitlementRemaining = [];
  ApiController apiController = ApiController();

  @override
  boot() async {
    // String langPref = await NyStorage.read<String>('languagePref') ?? '';
    // changeLanguage(langPref);

    setState(() => inLoading = true);
    final res = await apiController.getUniformItems(context);
    final items = res['items'];
    setState(() => inLoading = false);
    List<dynamic> listItems = [];
    for (final it in items) {
      final one = {
        "name": it['itemName'],
        "material": it['materialNo'],
        "items": []
      } as Map;
      one['items'].add(it);

      final idx = listItems.indexWhere((m) {
        return one['name'] == m['name'];
      });
      if (idx >= 0) {
        listItems[idx]['items'].add(it);
        continue;
      }
      listItems.add(one);
    }
    List<String> dropList = listItems.map((it) {
      String name = it['name'];
      return name;
    }).toList();
    setState(() {
      uniformItems = listItems;
      uniformDroplist = dropList;
      entitlementGuide = res['entitlementGuide'];
    });

    List<dynamic>? storedCartList = await NyStorage.readJson("cart_list");
    if (storedCartList == null) {
      // String stored_list = convertListToJson(theList);
      // await _storeData(cartList);
    } else {
      String jsonString = jsonEncode(storedCartList);
      List<UniformRequest> newList = convertJsonToList(jsonString);
      setState(() {
        cartList = newList;
      });
    }
  }

  changeUniformItem(String itemName) async {
    final one = uniformItems?.firstWhere((it) => it['name'] == itemName);
    List<String> sizes = [];
    String oneType = "";
    String labelType = "";
    if (one != null) {
      final items = one['items'];
      oneType = items[0]['type'];
      labelType = items[0]['type'];
      for (final item in items) {
        if (sizes.indexWhere((size) => size == item['size']) == -1) {
          sizes.add(item['size']);
        }
      }
      sizes.sort((a, b) =>
          a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
    }

    if (oneType != '') oneType = oneType.toLowerCase();
    int entitled = 0;
    int used = 0;
    int remaining = 0;
    switch (oneType) {
      case "shirt":
        entitled = entitlementGuide!['shirtEntitled'];
        used = entitlementGuide!['shirtUsed'];
        break;
      case "shoes":
        entitled = entitlementGuide!['shoesEntitled'];
        used = entitlementGuide!['shoesUsed'];
        break;
      case "pants":
        entitled = entitlementGuide!['pantsEntitled'];
        used = entitlementGuide!['pantsUsed'];
        break;
    }
    remaining = entitled - used;
    List<dynamic> newList = await NyStorage.readJson("cart_list") ?? [];
    for (final n in newList) {
      if (n['type'] == labelType) {
        remaining -= int.parse(n['qty'].toString());
      }
    }
    List<Map> labels = [
      {"label": "uniform_request_page.new_uniform_screen.uniform type".tr(), "number": labelType},
      {"label": "uniform_request_page.new_uniform_screen.total entitlement".tr(), "number": entitled},
      {"label": "uniform_request_page.new_uniform_screen.used".tr(), "number": used},
      {"label": "uniform_request_page.new_uniform_screen.remaining".tr(), "number": remaining}
    ];
    List<int> remains = [];
    if (remaining > 0) {
      for (int i = 1; i <= remaining; i++) {
        remains.add(i);
      }
    }
    setState(() {
      uniformSizes = sizes;
      selectedItem = itemName;
      selectedSize = "";
      selectedGender = "";
      selectedEntitlement = labels;
      entitlementRemaining = remains;
      entitlement = remaining > 0;
    });
  }

  String convertListToJson(List<UniformRequest> theList) {
    return jsonEncode(theList.map((request) => request.toJson()).toList());
  }

  List<UniformRequest> convertJsonToList(String jsonString) {
    List<dynamic> jsonData = jsonDecode(jsonString);
    return jsonData.map((item) => UniformRequest.fromJson(item)).toList();
  }

  Future<void> _storeData(thedata) async {
    await NyStorage.storeJson("cart_list", thedata);
  }

  Future<void> addToCart() async {
    if (selectedItem == "" || selectedQty == "" || selectedSize == "") {
      showSnackBar(context, "uniform_request_page.new_uniform_screen.field alert message".tr(), isSuccess: false);
      return;
    }

    List<dynamic> newList = await NyStorage.readJson("cart_list") ?? [];
    final one = uniformItems?.firstWhere((it) => it['name'] == selectedItem);
    final item = one['items'].firstWhere((it) {
      return it['size'] == selectedSize;
    });
    // Add a new Request object to the list
    int reqno = newList.length;
    if (reqno == 0) reqno = 1;
    final req = UniformRequest(
      id: item['id'],
      orderno: reqno.toString(),
      qty: int.parse(selectedQty!),
      size: selectedSize!,
      name: selectedItem!,
      type: item['type'],
      status: 'Pending',
      submittedTime: "",
    );
    newList.add(req);

    setState(() {
      cartList.add(req);
    });

    // Store the JSON data back to storage
    await NyStorage.storeJson("cart_list", newList);
    updateState(ShoppingCart.state);

    Navigator.pushReplacementNamed(context, NewUniformRequestPage.path);
  }

  /// The [view] method should display your page.
  @override
  Widget view(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (value) async {
        routeTo(UniformRequestPage.path,
          navigationType: NavigationType.pushAndRemoveUntil,
            removeUntilPredicate: ModalRoute.withName(HomePage.path),
            pageTransition: PageTransitionType.leftToRight
        );
        return Future.value(false);
      } ,
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
                pageTransition: PageTransitionType.leftToRight
              );
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.5, right: 15.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            "uniform_request_page.new_uniform_screen.title".tr(),
                            textScaler: TextScaler.noScaling,
                            style: const TextStyle(
                                fontFamily: 'Poppins-bold', fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        uniformDroplist!.isEmpty
                            ? const SizedBox()
                            : InputDropdown(
                                required: true,
                                label: 'uniform_request_page.new_uniform_screen.uniform item'.tr(),
                                items: uniformDroplist!,
                                value: null,
                                placeholder: 'uniform_request_page.new_uniform_screen.uniform item hint'.tr(),
                                editable: true,
                                onChanged: (String? newValue) async {
                                  await changeUniformItem(newValue!);
                                },
                              ),
                        selectedItem!.isEmpty
                            ? const SizedBox()
                            : Container(
                                decoration: BoxDecoration(
                                  color: ThemeColor.get(context).entitlementBox, // Background color
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Border radius
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 15),
                                    Text(
                                      "uniform_request_page.new_uniform_screen.uniform entitlement".tr(),
                                      textScaler: TextScaler.noScaling,
                                      textAlign: TextAlign.center,
                                      style:
                                          TextStyle(
                                            color: ThemeColor.get(context).primaryContent,
                                            fontFamily: 'Poppins-bold'
                                          ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        ...selectedEntitlement.map((item) {
                                          return Expanded(
                                            flex: 1,
                                            child: Column(
                                              children: [
                                                Text(
                                                  item['label'],
                                                  textScaler: TextScaler.noScaling,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: ThemeColor.get(context).primaryContent,
                                                      fontSize: 12,
                                                      fontFamily:
                                                          'Poppins-SemiBold'),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  item['number'].toString(),
                                                  textScaler: TextScaler.noScaling,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF1570EF),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        })
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                  ],
                                ),
                              ),
                        const SizedBox(height: 20),
                        selectedItem!.isEmpty
                            ? const SizedBox()
                            :  Column(
                                children: [
                                  entitlement
                                  ? InputDropdown(
                                    required: true,
                                    label: 'uniform_request_page.new_uniform_screen.uniform size'.tr(),
                                    items: uniformSizes,
                                    value: null,
                                    placeholder: 'uniform_request_page.new_uniform_screen.uniform size hint'.tr(),
                                    editable: true,
                                    onChanged: (String? newValue) {
                                      debugPrint('Selected size: $newValue');
                                      setState(() {
                                        selectedSize = newValue;
                                      });
                                    },
                                  )
                                : const SizedBox(),
                                  entitlement
                                      ? InputDropdown(
                                          required: true,
                                          label: 'uniform_request_page.new_uniform_screen.quantity'.tr(),
                                          items: entitlementRemaining.map((n) {
                                            return n.toString();
                                          }).toList(),
                                          value: null,
                                          placeholder: 'uniform_request_page.new_uniform_screen.quantity hint'.tr(),
                                          editable: true,
                                          onChanged: (String? newValue) {
                                            debugPrint('Selected qty: $newValue');
                                            setState(() {
                                              selectedQty = newValue;
                                            });
                                          },
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                        Visibility(
                          visible: !entitlement,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'public/assets/images/trailing.png',
                                height: 25.0,
                              ),
                              const SizedBox(width: 5),
                              Column(
                                children: [
                                  Text(
                                    "uniform_request_page.new_uniform_screen.warning 1".tr(),
                                    textScaler: TextScaler.noScaling,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins-bold',
                                      color: Colors.red,
                                    ),
                                  ),
                                  Text(
                                    "uniform_request_page.new_uniform_screen.warning 2".tr(),
                                    textScaler: TextScaler.noScaling,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 15.5,
                ),
                child: Row(
                  children: [
                    const ShoppingCart(),
                    const SizedBox(width: 15),
                    Visibility(
                      visible: !entitlement,
                      child: Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            routeTo(UniformRequestPage.path,
                                removeUntilPredicate:
                                    ModalRoute.withName(HomePage.path),
                                pageTransition: PageTransitionType.leftToRight);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColor.get(context).background,
                            foregroundColor: ThemeColor.get(context).uniformCancelButton,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF566789),
                            ),
                            shape: const RoundedRectangleBorder(
                              side: BorderSide(color: Color(0xFF566789)),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                          ),
                          child: Text("uniform_request_page.new_uniform_screen.cancel button".tr(), textScaler: TextScaler.noScaling,),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: entitlement,
                      child: Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            addToCart();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1570EF),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                          ),
                          child: Text(
                            "uniform_request_page.new_uniform_screen.add button".tr(),
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                              color: ThemeColor.get(context).appBarPrimaryContent 
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get isThemeDark =>
      ThemeProvider.controllerOf(context).currentThemeId ==
      getEnv('DARK_THEME_ID');
}
