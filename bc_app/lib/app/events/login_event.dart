import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/broadcast_message.dart';
import 'package:bc_app/app/models/notifications_message.dart';
import 'package:bc_app/resources/widgets/components/appbar_widget.dart';
import 'package:bc_app/resources/widgets/components/popup_message_slider.dart';
import 'package:bc_app/resources/widgets/components/popup_notifications_message_slider.dart';
import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LoginEvent implements NyEvent {
  @override
  final listeners = {
    DefaultListener: DefaultListener(),
  };
}

final cron = Cron();
bool paused = false;
bool delayNotif = false;
bool delayBroadcast = false;
ApiController apiController = ApiController();

retrieveBroadcastMessages() async {
  if (paused) return;
  if (delayBroadcast) return;
  List<BroadcastMessage> messages = [];
  BuildContext currentContext =
      NyNavigator.instance.router.navigatorKey!.currentState!.context;
  final res =
      await apiController.broadcastMessagesList(currentContext, "unread", "", null);
  messages = res;
  if (messages.isEmpty) return;
  messages.sort((a, b) {
    return b.broadcastTime.compareTo(a.broadcastTime);
  });

  final unreadMessages = messages.where(
      (message) => message.read == false || message.acknowledge == false);
  final popupMessages = messages.where((msg) => msg.popup);

  final existing = await NyStorage.readCollection("popupMessages");
  List<BroadcastMessage> newMessages = [];
  for (final msg in popupMessages) {
    final index = existing.indexWhere((it) => it['id'] == msg.id);
    if (index == -1) newMessages.add(msg);
  }
  newMessages.sort((a, b) {
    return b.broadcastTime.compareTo(a.broadcastTime);
  });
  final existingMessages =
      existing.map((it) => BroadcastMessage.fromMap(it)).where((it) {
    final index = unreadMessages.toList().indexWhere((m) => m.id == it.id);
    return index >= 0;
  });
  final allMessages = [
    ...newMessages.map((it) {
      return it.toMap();
    }),
    ...existingMessages.map((it) {
      return it.toMap();
    })
  ].toList();
  List<BroadcastMessage> messagesList =
      [...newMessages, ...existingMessages].toList();

  updateState(CustomAppBar.state, data: {
    "messageCount": unreadMessages.length,
  });
  await NyStorage.saveCollection("popupMessages", allMessages);
  if (newMessages.isNotEmpty) {
    showPopupMessages(currentContext, messagesList);
  }
}

retrieveNotificationsMessages() async {
  if (paused) return;
  if (delayNotif) return;
  BuildContext currentContext =
      NyNavigator.instance.router.navigatorKey!.currentState!.context;
  List<NotificationsMessage> messages = await apiController
      .notificationMessagesList(currentContext, "unread", "");

  if (messages.isEmpty) return;
  messages.sort((a, b) {
    return b.broadcastTime.compareTo(a.broadcastTime);
  });
  final unreadMessages = messages.where(
      (message) => message.read == false || message.acknowledge == false);
  final existing = await NyStorage.readCollection("popupNotificationMessages");
  final popupMessages = messages.where((msg) => msg.popup);

  List<NotificationsMessage> newMessages = [];
  for (final msg in popupMessages) {
    final index = existing.indexWhere((it) => it['id'] == msg.id);
    if (index == -1) newMessages.add(msg);
  }
  newMessages.sort((a, b) {
    return b.broadcastTime.compareTo(a.broadcastTime);
  });

  final existingMessages =
      existing.map((it) => NotificationsMessage.fromMap(it)).where((it) {
    final index = unreadMessages.toList().indexWhere((m) => m.id == it.id);
    return index >= 0;
  });

  final allMessages = [
    ...newMessages.map((it) {
      return it.toMap();
    }),
    ...existingMessages.map((it) {
      return it.toMap();
    })
  ].toList();

  final combinedMessages = [...newMessages, ...existingMessages].toList();
  updateState(CustomAppBar.state, data: {
    "notifCount": unreadMessages.length,
  });
  await NyStorage.saveCollection("popupNotificationMessages", allMessages);
  if (newMessages.isNotEmpty) {
    showPopupNotificationMessages(currentContext, combinedMessages);
  }
}

showPopupMessages(BuildContext context, List<BroadcastMessage> popups) {
  paused = true;
  delayNotif = true;
  delayBroadcast = false;
  Future.delayed(
    const Duration(seconds: 1),
    () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            LayoutBuilder(builder: (context, constraints) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
            child: SizedBox(
              height: constraints.maxHeight * 0.5,
              width: constraints.maxWidth,
              child: PopupMessageSlider(
                popups: popups,
                onClosed: () {
                  paused = false;
                  Navigator.of(context).pop();
                },
              ),
            ),
          );
        }),
      );
    },
  );
}

showPopupNotificationMessages(
    BuildContext context, List<NotificationsMessage> popups) {
  paused = true;
  delayNotif = false;
  delayBroadcast = true;
  Future.delayed(
    const Duration(seconds: 1),
    () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => LayoutBuilder(
          builder: (context, constraints) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: SizedBox(
                height: constraints.maxHeight * 0.5,
                width: constraints.maxWidth,
                child: PopupNotificationMessageSlider(
                  popups: popups,
                  onClosed: () {
                    paused = false;
                    Navigator.of(context).pop();
                  },
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

class DefaultListener extends NyListener {
  @override
  handle(dynamic event) async {
    bool runCronJob = event['runCronJob'] == true;
    if (!runCronJob) {
      cron.close();
    } else {
      try {
        print('INIT CRON');
        cron.schedule(Schedule.parse("*/15 * * * * *"), () async {
          print('CRON IS RUNNING every 15 seconds');
          await retrieveBroadcastMessages();
          retrieveNotificationsMessages();
        });
        await retrieveBroadcastMessages();
        retrieveNotificationsMessages();
      } on ScheduleParseException {
        print('CRON IS STOPPED');
        cron.close();
      } catch (e) {
        cron.close();
      }
    }
  }
}
