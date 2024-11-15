import 'dart:async';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/broadcast_message.dart';
import 'package:bc_app/app/models/lms_notifications.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/lms_detail_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/appbar_widget.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';
import 'package:bc_app/resources/widgets/components/page_button_widget.dart';
import 'package:bc_app/resources/widgets/custom_scaffold_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LmsPage extends NyStatefulWidget {
  static const path = '/lms';
  static String stat = "lms_page";
  
  LmsPage({super.key}) : super(path, child: _LmsPageState());

   @override
  _LmsPageState createState() => _LmsPageState();
}

class _LmsPageState extends NyState<LmsPage> with WidgetsBindingObserver {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final TextEditingController _searchController = TextEditingController();
  bool bottomnavhide = false;
  String pageSelected = 'all';
  String langPref = 'en';
  List<LmsNotifications> lmsMessages = [];
  Timer? _debounce;
  ApiController apiController = ApiController();
  String? title;

  
  _LmsPageState() {
    stateName = LmsPage.stat;
  }

  @override
  init() async {
    super.init();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_onSearchChanged);
    if (stateData != null && stateData.runtimeType == List<LmsNotifications>) {
      setState(() => lmsMessages = stateData);
    } else {
      await retrieveMessages();
    }
  }
  
  /// Use boot if you need to load data before the [view] is rendered.
  @override
  boot() async {
    await retrieveMessages();
    // updateState(
    //   CustomAppBar.state,
    //   data: {
    //     "messageCount": broadcastMessages
    //         .where((message) =>
    //             message.read == false || message.acknowledge == false)
    //         .length
    //   },
    // );

    final data = widget.data();
    setState(() {
      title = data['title'] ?? 'messages';
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  stateUpdated(dynamic data) {
    lmsMessages = data;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App is in the foreground
      _checkPageFocus();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void didChangeMetrics() {
    _checkPageFocus();
    super.didChangeMetrics();
  }

  retrieveMessages() async {
    // final query = _searchController.text.toLowerCase();
    // final readStatus = pageSelected == "all" ? "" : pageSelected;
    // _triggerRefresh();
    // final res =
    //     await apiController.broadcastMessagesList(context, readStatus, query, null);
    // setState(() {
    //   broadcastMessages = res;
    //   broadcastMessages.sort((a, b) {
    //     return b.broadcastTime.compareTo(a.broadcastTime);
    //   });
    // });
    // if (readStatus != "read") {
    //   updateState(
    //     CustomAppBar.state,
    //     data: {
    //       "messageCount": broadcastMessages
    //           .where((message) =>
    //               message.read == false || message.acknowledge == false)
    //           .length
    //     },
    //   );
    // }

    final res = [
      LmsNotifications(id: 1, courseName: "Course 1", sessionCode: "123123", dateTime: "2024-10-01 10:00:00", venue: "Room 1", remarks: "This is a remarks This is a remarks This is a remarks This is a remarksThis is a remarksThis is a remarksThis is a remarksThis is a remarksThis is a remarksThis is a remarksThis is a remarksThis is a remarksThis is a remarksThis is a remarksThis is a remarksThis is a remarks",
                      broadcastTime: "2024-10-01 00:00:00", selected: false, read: false, acknowledge: false, closed: false, popup: true),
      LmsNotifications(id: 2, courseName: "Course 2", sessionCode: "123124", dateTime: "2024-10-01 22:00:00", venue: "Room 1", remarks: "Shorter remarks",
                      broadcastTime: "2024-10-01 00:00:00", selected: false, read: false, acknowledge: false, closed: false, popup: true)
    ];

    setState(() {
      lmsMessages = res;
    });
  }

  void _checkPageFocus() async {
    var language =
        await NyStorage.read<String>('languagePref') == 'en' ? 'en' : 'zh';
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      setState(() {
        langPref = language;
      });
    }
  }

  void _triggerRefresh() {
    _refreshIndicatorKey.currentState?.show();
  }

  Future<void> _refreshMessage() async {
    retrieveMessages();
  }

  void _selectMessage(LmsNotifications message) {
    message.selected = !message.selected;
    var selectedMessages = lmsMessages.where((item) => item.selected);
    if (selectedMessages.isNotEmpty) {
      bottomnavhide = true;
    } else {
      bottomnavhide = false;
    }
    setState(() {});
  }

  void _acknowledgeMessage(int id) async {
    var index = lmsMessages.indexWhere((message) => message.id == id);
    setState(() {
      lmsMessages[index].acknowledge = true;
    });
    _refreshMessage();
  }

  void _deleteMessage() async {
    List<int> idsToRemoved = lmsMessages
        .where((message) => message.selected)
        .map((it) => it.id)
        .toList();
   
    if (idsToRemoved.isNotEmpty) {
      final res =
          await apiController.removeBroadcastMessages(context, idsToRemoved);
      setState(() {
        if (res) {
          lmsMessages.removeWhere((message) => message.selected);
        }
        bottomnavhide = false;
      });
    }
    updateState(
      CustomAppBar.state,
      data: {
        "messageCount": lmsMessages
            .where((message) =>
                message.read == false || message.acknowledge == false)
            .length
      },
    );
    Navigator.pop(context);
  }

  void _selectButton(String page) async {
    setState(() {
      pageSelected = page;
    });
    retrieveMessages();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _onSearchSubmitted();
    });
  }

  void _onSearchSubmitted() async {
    await retrieveMessages();
  }

  readMessage(LmsNotifications message) async {
    // if (message.read == false) {
    //   await apiController.updateBroadcastMessageStatus(
    //     context,
    //     message,
    //     'read',
    //   );
      int index = lmsMessages.indexWhere((m) => m.id == message.id);
    //   lmsMessages[index].read = true;
    //   updateState(
    //     CustomAppBar.state,
    //     data: {
    //       "messageCount": lmsMessages
    //           .where((message) =>
    //               message.read == false || message.acknowledge == false)
    //           .length
    //     },
    //   );
    // }
    message.read = true;
    routeTo(LmsDetailPage.path, data: {
      'message' : lmsMessages[index],
       "_acknowledgeMessage": _acknowledgeMessage
    });
  }

  @override
  Widget view(BuildContext context) {
    final buttons = [
      {'label': "message_page.list_screen.filter all".tr(), 'page': 'all'},
      {
        'label': "message_page.list_screen.filter unread".tr(),
        'page': 'unread'
      },
      {'label': "message_page.list_screen.filter read".tr(), 'page': 'read'},
    ];

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return CustomScaffold(
      bottomnavhide: bottomnavhide,
      bottomcenterhide: bottomInset > 0.0,
      body: Column(
        children: [
          MasterLayout(
            padding: const EdgeInsets.fromLTRB(30, 20, 15, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 18.0,
                      ),
                    ),
                    Text(
                      "message_page.category_screen.$title".tr(),
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins-Bold',
                      ),
                    ),
                  ],
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
            padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
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
            padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
            child: Row(
              children: buttons.map((button) {
                return PageButton(
                  label: button['label']!,
                  page: button['page']!,
                  pageSelected: pageSelected,
                  onPressed: _selectButton,
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: lmsMessages.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 150),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "No $pageSelected messages",
                          textScaler: TextScaler.noScaling,
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const Text(
                          "View all chats",
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF1570EF),
                            decorationColor: Color(0xFF1570EF),
                            decoration: TextDecoration.underline,
                          ),
                        ).onTap(
                          () => _selectButton('all'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: _refreshMessage,
                    child: ListView.separated(
                      separatorBuilder: (context, index) =>
                          const Divider(height: 0, color: Colors.black12),
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 120),
                      shrinkWrap: true,
                      itemCount: lmsMessages.length,
                      itemBuilder: (BuildContext context, int index) {
                        final message = lmsMessages[index];
                        return GestureDetector(
                          onLongPress: () => _selectMessage(message),
                          onTap: () => {
                            if (bottomnavhide == true)
                              {_selectMessage(message)}
                            else
                              {readMessage(message)}
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                            child: Row(
                              children: [
                                Builder(
                                  builder: (context) {
                                    if (bottomnavhide == true) {
                                      return Container(
                                        padding: const EdgeInsets.all(4),
                                        width: 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: message.selected
                                                ? nyHexColor("1570EF")
                                                : Colors.black12,
                                            width: 3,
                                          ),
                                          color: Colors.transparent,
                                        ),
                                        child: message.selected
                                            ? Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: message.selected
                                                      ? nyHexColor("1570EF")
                                                      : Colors.transparent,
                                                ),
                                              )
                                            : null,
                                      );
                                    }
                                    return Container(
                                      padding: const EdgeInsets.all(8),
                                      width: 25,
                                      height: 25,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: message.acknowledge
                                              ? Colors.transparent
                                              : Colors.red,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Expanded(
                                  child: ListTile(
                                    title: Text(
                                      message.courseName,
                                      textScaler: TextScaler.noScaling,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "Poppins-SemiBold",
                                        fontWeight: FontWeight.bold,
                                        color: message.acknowledge
                                            ? Colors.grey
                                            : ThemeColor.get(context)
                                                .primaryContent,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildRow(
                                            "Date: ", 
                                            dateFormatString(message.dateTime, fromFormat: 'yyyy-MM-dd HH:mm', toFormat: 'dd/MM/yyyy')
                                          ),
                                          _buildRow(
                                            "Time: ",
                                            dateFormatString(message.dateTime, fromFormat: 'yyyy-MM-dd HH:mm', toFormat: 'HH:mm a'),
                                          ),
                                          _buildRow(
                                            "Location: ",
                                            message.venue
                                          ),
                                          const SizedBox(height: 5),
                                          _buildRow(
                                            "Remarks: ",
                                            message.remarks
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            dateFormatString(
                                              message.broadcastTime,
                                              fromFormat: 'yyyy-MM-dd HH:mm',
                                              toFormat: 'dd/MM/yyyy, HH:mm a',
                                            ),
                                            textScaler: TextScaler.noScaling,
                                            style: const TextStyle(
                                              fontSize: 12.41,
                                              color: Color(0xFFA5ACB8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    isThreeLine: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 70,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => _showBottomSheet(context, _deleteMessage),
              icon: const Icon(
                Icons.delete_outline,
                color: Color(0xFF007AFF),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                for (var element in lmsMessages) {
                  element.selected = false;
                }
                bottomnavhide = false;
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              child: Text(
                "message_page.list_screen.cancel".tr(),
                textScaler: TextScaler.noScaling,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF007AFF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildRow(String label, String data) {
  return Row(
    children: [
      Text(
        label ,
        textScaler: TextScaler.noScaling,
        style: const TextStyle(
          fontSize: 12.41,
          fontFamily: "Poppins-Bold",
          fontWeight: FontWeight.bold
        ),
      ),
      Expanded(
        child: Text(
          data,
          textScaler: TextScaler.noScaling,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12.41,
          ),
        ),
      ),
    ],
  );
}

void _showBottomSheet(BuildContext context, VoidCallback deleteMessage) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SizedBox(
        height: 180,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "message_page.list_screen.delete label".tr(),
                textScaler: TextScaler.noScaling,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black45,
                ),
              ),
            ),
            const Divider(height: 0, color: Colors.black12),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                onPressed: deleteMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.red,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                  ),
                ),
                child: Text("message_page.list_screen.delete message".tr(), textScaler: TextScaler.noScaling,),
              ),
            ),
            const Divider(height: 0, color: Colors.black12),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.blue,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                child: Text("message_page.list_screen.cancel".tr(), textScaler: TextScaler.noScaling,),
              ),
            ),
          ],
        ),
      );
    },
  );
}
