import 'dart:async';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/broadcast_message.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/message_detail_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/appbar_widget.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';
import 'package:bc_app/resources/widgets/components/page_button_widget.dart';
import 'package:bc_app/resources/widgets/custom_scaffold_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nylo_framework/nylo_framework.dart';

class MessagePage extends NyStatefulWidget {
  static const path = '/message';
  static String stat = "message_page";

  MessagePage({super.key}) : super(path, child: _MessagePageState());

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends NyState<MessagePage>
    with WidgetsBindingObserver {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final TextEditingController _searchController = TextEditingController();
  bool bottomnavhide = false;
  String pageSelected = 'all';
  String langPref = 'en';
  List<BroadcastMessage> broadcastMessages = [];
  Timer? _debounce;
  ApiController apiController = ApiController();
  bool _isAscending = false;
  DateTimeRange? filterDate;
  String? title;

  _MessagePageState() {
    stateName = MessagePage.stat;
  }

  @override
  init() async {
    super.init();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(_onSearchChanged);
    if (stateData != null && stateData.runtimeType == List<BroadcastMessage>) {
      setState(() => broadcastMessages = stateData);
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
        "messageCount": broadcastMessages
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  stateUpdated(dynamic data) {
    broadcastMessages = data;
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
    final query = _searchController.text.toLowerCase();
    final readStatus = pageSelected == "all" ? "" : pageSelected;
    _triggerRefresh();
    final res =
        await apiController.broadcastMessagesList(context, readStatus, query, stringifyDate(filterDate));
    setState(() {
      broadcastMessages = res;
      broadcastMessages.sort((a, b) {
        return _isAscending ? a.broadcastTime.compareTo(b.broadcastTime): b.broadcastTime.compareTo(a.broadcastTime);
      }); 
    });
    if (readStatus != "read") {
      updateState(
        CustomAppBar.state,
        data: {
          "messageCount": broadcastMessages
              .where((message) =>
                  message.read == false || message.acknowledge == false)
              .length
        },
      );
    }
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

  void _selectMessage(BroadcastMessage message) {
    message.selected = !message.selected;
    var selectedMessages = broadcastMessages.where((item) => item.selected);
    if (selectedMessages.isNotEmpty) {
      bottomnavhide = true;
    } else {
      bottomnavhide = false;
    }
    setState(() {});
  }

  void _acknowledgeMessage(int id) async {
    var index = broadcastMessages.indexWhere((message) => message.id == id);
    setState(() {
      broadcastMessages[index].acknowledge = true;
    });
    _refreshMessage();
  }

  void _deleteMessage() async {
    List<int> idsToRemoved = broadcastMessages
        .where((message) => message.selected)
        .map((it) => it.id)
        .toList();
   
    if (idsToRemoved.isNotEmpty) {
      final res =
          await apiController.removeBroadcastMessages(context, idsToRemoved);
      setState(() {
        if (res) {
          broadcastMessages.removeWhere((message) => message.selected);
        }
        bottomnavhide = false;
      });
    }
    updateState(
      CustomAppBar.state,
      data: {
        "messageCount": broadcastMessages
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

  readMessage(BroadcastMessage message) async {
    if (message.read == false) {
      await apiController.updateBroadcastMessageStatus(
        context,
        message,
        'read',
        message.response
      );
      int index = broadcastMessages.indexWhere((m) => m.id == message.id);
      broadcastMessages[index].read = true;
      updateState(
        CustomAppBar.state,
        data: {
          "messageCount": broadcastMessages
              .where((message) =>
                  message.read == false || message.acknowledge == false)
              .length
        },
      );
    }
    message.read = true;
    routeTo(MessageDetailPage.path, data: {
      "pageHeader": title,
      "title": message.title,
      "messageBody": message.content,
      "message": message,
      "_acknowledgeMessage": _acknowledgeMessage,
      "_onLeave": () async {
        Navigator.pop(context);
        reboot();
      }
    });
  }

  Future<void> _selectDateRange(BuildContext context, String label) async {
    String lang = await NyStorage.read<String>('languagePref') ?? 'en';
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      locale: Locale(lang),
      // initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: label,
    );
    if (picked != null) {
      setState(() {
        filterDate = picked;
      });

      await retrieveMessages();
    }
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
    

    // Sort messages before showing
    broadcastMessages.sort((a, b) {
      return _isAscending ? a.broadcastTime.compareTo(b.broadcastTime): b.broadcastTime.compareTo(a.broadcastTime);
    }); 

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
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFC4C4C4).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: GestureDetector(
                    onTap: () =>  _selectDateRange(context, "message_page.list_screen.select filter date".tr()),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.calendar_today,
                          color: Colors.grey, size: 15.0
                        ),
                        filterDate != null
                            ? Text(
                                "${DateFormat('dd/MM/yyyy').format(filterDate!.start)} - ${DateFormat('dd/MM/yyyy').format(filterDate!.end)}",
                                textScaler: TextScaler.noScaling,
                              )
                            : Text(
                                "message_page.list_screen.filter by date".tr(),
                                textScaler: TextScaler.noScaling,
                              ),
                        filterDate == null
                        ? const SizedBox()
                        : GestureDetector(
                          onTap: () {
                            setState(() {
                              filterDate = null;
                            });
                            _refreshMessage();
                          },
                          child: const Icon(Icons.close, color: Colors.blue, size: 15.0)
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 138,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC4C4C4).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isAscending = !_isAscending;
                      });
                      // _triggerRefresh();
                    },
                    child: Row(
                      children: [
                        Text(
                            'message_page.list_screen.sort date'.tr(),
                            textScaler: TextScaler.noScaling,),
                        const SizedBox(width: 8),
                        if (_isAscending)
                          const Icon(
                            Icons.arrow_drop_up,
                            color: Colors.blue,
                          ),
                        if (!_isAscending)
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.blue,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: broadcastMessages.isEmpty
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
                      itemCount: broadcastMessages.length,
                      itemBuilder: (BuildContext context, int index) {
                        final message = broadcastMessages[index];
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
                                          Text(
                                            message.content,
                                            textScaler: TextScaler.noScaling,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: message.acknowledge
                                                ? Colors.grey
                                                : ThemeColor.get(context).primaryContent,
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
                                          Text(
                                            '${"message_page.list_screen.posted by".tr()} ${message.authorDisplay}',
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
                for (var element in broadcastMessages) {
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
