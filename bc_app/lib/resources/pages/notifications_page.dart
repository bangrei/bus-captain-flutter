import 'dart:async';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/broadcast_message.dart';
import 'package:bc_app/app/models/notifications_message.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/notifications_detail_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/appbar_widget.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';
import 'package:bc_app/resources/widgets/components/page_button_widget.dart';
import 'package:bc_app/resources/widgets/custom_scaffold_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:nylo_framework/nylo_framework.dart';

class NotificationsPage extends NyStatefulWidget {
  static const path = '/notifications';
  
  NotificationsPage({super.key}) : super(path, child: _NotificationsPageState());
}

class _NotificationsPageState extends NyState<NotificationsPage> with WidgetsBindingObserver {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final TextEditingController _searchController = TextEditingController();
  bool bottomnavhide = false;
  String pageSelected = 'all';
  String langPref = 'en';
  List<NotificationsMessage> notificationsMessages = [];
  Timer? _debounce;
  ApiController apiController = ApiController();
  int charsLimit = 100;
  String? title;
  
  @override
  init() async {
    super.init();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_onSearchChanged);
    if (stateData != null && stateData.runtimeType == List<BroadcastMessage>) {
      setState(() => notificationsMessages = stateData);
    } else {
      await retrieveMessages();
    }
  }
  
  /// Use boot if you need to load data before the [view] is rendered.
  @override
  boot() async {
    await retrieveMessages();
    updateState(
      CustomAppBar.state,
      data: {
        "notifCount": notificationsMessages
            .where((message) =>
                message.read == false || message.acknowledge == false)
            .length
      },
    );
    final data = widget.data();
    setState(() {
      title = data['title'] ?? 'messages';
    });
  }

  retrieveMessages() async {
    final query = _searchController.text.toLowerCase();
    final readStatus = pageSelected == "all" ? "" : pageSelected;
    _triggerRefresh();
    final res =
        await apiController.notificationMessagesList(context, readStatus, query);
    setState(() {
      notificationsMessages = res;
      notificationsMessages.sort((a, b) {
        return b.broadcastTime.compareTo(a.broadcastTime);
      });
    });
    if (readStatus != "read") {
      updateState(
        CustomAppBar.state,
        data: {
          "notifCount": notificationsMessages
              .where((message) =>
                  message.read == false || message.acknowledge == false)
              .length
        },
      );
    }
  }

  void _triggerRefresh() {
    _refreshIndicatorKey.currentState?.show();
  }

   void _selectButton(String page) async {
    setState(() {
      pageSelected = page;
    });
    retrieveMessages();
  }

  Future<void> _refreshMessage() async {
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

  void _selectMessage(NotificationsMessage message) {
    message.selected = !message.selected;
    var selectedMessages = notificationsMessages.where((item) => item.selected);
    if (selectedMessages.isNotEmpty) {
      bottomnavhide = true;
    } else {
      bottomnavhide = false;
    }
    setState(() {});
  }

  void _acknowledgeMessage(int id) async {
    var index = notificationsMessages.indexWhere((message) => message.id == id);
    setState(() {
      notificationsMessages[index].acknowledge = true;
    });
    _refreshMessage();
  }

  readMessage(NotificationsMessage message) async {
    if (message.read == false) {
      await apiController.updateNotificationsMessageStatus(
        context,
        message,
        'read',
      );
      int index = notificationsMessages.indexWhere((m) => m.id == message.id);
      notificationsMessages[index].read = true;
      message.read = true;
      updateState(
        CustomAppBar.state,
        data: {
          "notifCount": notificationsMessages
              .where((message) =>
                  message.read == false || message.acknowledge == false)
              .length
        },
      );
    }
    message.read = true;
    routeTo(NotificationsDetailPage.path, data: {
      "title": message.title,
      "messageBody": message.content,
      "message": message,
      "_acknowledgeMessage": _acknowledgeMessage
    });
  }

  void _deleteMessage() async {
    List<int> idsNotifications = notificationsMessages
        .where((message) => message.selected && message.type == "Notification")
        .map((it) => it.id)
        .toList();
    if (idsNotifications.isNotEmpty) {
      final res2 =
          await apiController.removeNotifications(context, idsNotifications);
      setState(() {
        if (res2) {
          notificationsMessages.removeWhere((message) => message.selected);
        }
        bottomnavhide = false;
      });
    }
    updateState(
      CustomAppBar.state,
      data: {
        "notifCount": notificationsMessages
            .where((message) =>
                message.read == false || message.acknowledge == false)
            .length
      },
    );
    Navigator.pop(context);
  }

  truncateText(String text, int charsLimit) {
    return text.length > charsLimit ? '${text.substring(0, charsLimit)}...' : text;
  }

  @override
  Widget view(BuildContext context) {
    final buttons = [
      {'label': "notifications_page.list_screen.filter all".tr(), 'page': 'all'},
      {
        'label': "notifications_page.list_screen.filter unread".tr(),
        'page': 'unread'
      },
      {'label': "notifications_page.list_screen.filter read".tr(), 'page': 'read'},
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
                hintText: "notifications_page.list_screen.search".tr(),
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
            child: notificationsMessages.isEmpty
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
                      itemCount: notificationsMessages.length,
                      itemBuilder: (BuildContext context, int index) {
                        final message = notificationsMessages[index];
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
                                      message.title,
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
                                          HtmlWidget(
                                            truncateText(message.content, charsLimit),
                                            textStyle: TextStyle(
                                              fontSize: 14,
                                              color: message.acknowledge
                                                  ? Colors.grey
                                                  : ThemeColor.get(
                                                          context)
                                                      .primaryContent,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
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
                                Builder(
                                  builder: (context) {
                                    if (message.attachments.isNotEmpty) {
                                      return const Icon(Icons.attach_file);
                                    }
                                    return const SizedBox();
                                  },
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
                for (var element in notificationsMessages) {
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
                "notifications_page.list_screen.cancel".tr(),
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
                "notifications_page.list_screen.delete label".tr(),
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
                child: Text("notifications_page.list_screen.delete message".tr(), textScaler: TextScaler.noScaling,),
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
                child: Text("notifications_page.list_screen.cancel".tr(), textScaler: TextScaler.noScaling,),
              ),
            ),
          ],
        ),
      );
    },
  );
}
