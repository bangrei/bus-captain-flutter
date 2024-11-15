import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/lms_page.dart';
import 'package:bc_app/resources/pages/message_page.dart';
import 'package:bc_app/resources/pages/notifications_page.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';
import 'package:bc_app/resources/widgets/custom_scaffold_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class MessageCategoryPage extends NyStatefulWidget {
  static const path = '/message-category';
  
  MessageCategoryPage({super.key}) : super(path, child: _MessageCategoryPageState());
}

class _MessageCategoryPageState extends NyState<MessageCategoryPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final TextEditingController _searchController = TextEditingController();
  ApiController apiController = ApiController();
  List<Map<String,dynamic>> messageCategoryListMap = [];

  @override
  init() async {

  }
  
  /// Use boot if you need to load data before the [view] is rendered.
  @override
  boot() async {
    await _retrieveData();
  }

   void _triggerRefresh() async {
    _refreshIndicatorKey.currentState?.show();
    await _onRefresh();
  }

  _retrieveData() async{
    List<Map<String,dynamic>> msgsCatList = [];
    
    // Get data from Broadcast Messages
    Map<String,dynamic> msgs1 = await retrieveMessages();
    msgsCatList.add(msgs1);

    // Get data from Notifications Messages
    Map<String,dynamic> msgs2 = await retrieveNotifications();
    msgsCatList.add(msgs2);

    Map<String,dynamic> msgs3 = await retrieveLmsNotifications();
    msgsCatList.add(msgs3);

    setState(() {
      messageCategoryListMap = msgsCatList;
    });

  }

  Future<Map<String,dynamic>> retrieveMessages() async {
    String query = "";
    String readStatus = "" ;
    final res =  await apiController.broadcastMessagesList(context, readStatus, query, null);
    return {
      "category": "message_page.category_screen.general".tr(),
      "categoryEn": "general",
      "path": MessagePage.path,
      "unreadCount": res.where((message) => message.read == false || message.acknowledge == false).length
    };
  }

  Future<Map<String,dynamic>> retrieveNotifications() async {
    String query = "";
    String readStatus = "" ;

    final res = await apiController.notificationMessagesList(context, readStatus, query);

    return {
      "category": "message_page.category_screen.license expiring".tr(),
      "categoryEn": "license expiring",
      "path": NotificationsPage.path,
      "unreadCount": res.where((message) => message.read == false || message.acknowledge == false).length
    };
  }

  Future<Map<String,dynamic>> retrieveLmsNotifications() async {
    // String query = "";
    // String readStatus = "" ;

    // final res = await apiController.notificationMessagesList(context, readStatus, query);

    return {
      "category": "message_page.category_screen.lms".tr(),
      "categoryEn": "lms",
      "path": LmsPage.path,
      "unreadCount": 1
    };
  }

  Future<void> _onRefresh() async{
    await _retrieveData();
  }

  @override
  Widget view(BuildContext context) {
    return CustomScaffold(
      body: SafeArea(
        child: Column (
          children: [
            MasterLayout(
              padding: const EdgeInsets.fromLTRB(20, 20, 10, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "message_page.list_screen.title".tr(),
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins-Bold',
                    ),
                  ),
                  IconButton(
                    onPressed: _triggerRefresh,
                    icon: Image.asset(
                      'public/assets/images/refresh.png',
                      width: 32,
                      height: 32,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "message_page.list_screen.search".tr(),
                  hintStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: nyHexColor('f5f5f5'),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                    color: ThemeColor.get(context).messageCategoryContainer
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    separatorBuilder: (context, index) =>
                      Divider(height: 0, color: ThemeColor.get(context).myBoxDecorationLine.withOpacity(0.09)), 
                    itemCount: messageCategoryListMap.length,
                    itemBuilder: (BuildContext context, int index) {
                      final item = messageCategoryListMap[index];
                      String category = item['category'];
                      String categoryEn = item['categoryEn'];
                      String unreadCount = item['unreadCount'].toString();
                      String path = item['path'];
              
                      return GestureDetector(
                        onTap: () {
                          routeTo(path, data: {'title': categoryEn});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            // Added to extend tap detection area
                            border: Border.all(width: 0, color: Colors.blue.withOpacity(0)) ,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    category,
                                    textScaler: TextScaler.noScaling,
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF0000),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 25,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      unreadCount, // Your badge count here
                                      textScaler: TextScaler.noScaling,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 15.0
                              )
                            ],
                          ),
                        ),
                      );
                    } 
                  ),
                )
              ),
            )
          ]
        ),
      )
    );
  }
}
