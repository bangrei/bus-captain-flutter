import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final VoidCallback? onOpenDrawer;
  final VoidCallback? onOpenMessage;
  final VoidCallback? onOpenNotification;

  const CustomAppBar({
    super.key,
    required this.scaffoldKey,
    required this.onOpenDrawer,
    required this.onOpenMessage,
    required this.onOpenNotification,
  });

  static String state = "custom_app_bar";

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends NyState<CustomAppBar> {
  int messageCount = 0;
  int notifCount = 0;

  _CustomAppBarState() {
    stateName = CustomAppBar.state;
  }

  @override
  init() async {
    if (stateData != null) {
      messageCount = stateData['messageCount'] ?? messageCount;
      notifCount = stateData['notifCount'] ?? notifCount;
    } else {
      ApiController apiController = ApiController();
      final messages =
          await apiController.broadcastMessagesList(context, 'unread', '',null);
      setState(() => messageCount = messages.length);
    }
  }

  @override
  stateUpdated(dynamic data) async {
    if (data['messageCount'] != null) {
      messageCount = int.parse(data['messageCount'].toString());
    }
    if (data['notifCount'] != null) {
      notifCount = int.parse(data['notifCount'].toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1570EF),
      title: Image.asset('public/assets/images/SMRT_logo.png', height: 45.0),
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: widget.onOpenDrawer,
      ),
      actions: <Widget>[
        Stack(
          children: <Widget>[
            IconButton(
              icon: SizedBox(
                width: 25,
                child: Image.asset('public/assets/images/icons/message.png'),
              ),
              onPressed: widget.onOpenMessage,
            ),
            messageCount == 0
                ? const SizedBox()
                : Positioned(
                    right: 5,
                    top: 5,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0000),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        messageCount.toString(), // Your badge count here
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
          ],
        ),
        // Stack(
        //   children: <Widget>[
        //     IconButton(
        //       icon: const Icon(Icons.notifications),
        //       onPressed: widget.onOpenNotification,
        //     ),
        //     notifCount == 0
        //         ? const SizedBox()
        //         : Positioned(
        //             right: 5,
        //             top: 5,
        //             child: Container(
        //               padding: const EdgeInsets.all(2),
        //               decoration: BoxDecoration(
        //                 color: const Color(0xFFFF0000),
        //                 borderRadius: BorderRadius.circular(10),
        //               ),
        //               constraints: const BoxConstraints(
        //                 minWidth: 16,
        //                 minHeight: 16,
        //               ),
        //               child: Text(
        //                 notifCount.toString(), // Your badge count here
        //                 textScaler: TextScaler.noScaling,
        //                 style: const TextStyle(
        //                   color: Colors.white,
        //                   fontSize: 10,
        //                 ),
        //                 textAlign: TextAlign.center,
        //               ),
        //             ),
        //           ),
        //   ],
        // )
      ],
    );
  }
}
