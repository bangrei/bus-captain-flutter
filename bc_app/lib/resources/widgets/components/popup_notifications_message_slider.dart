import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/notifications_message.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/driving_license_page.dart';
import 'package:bc_app/resources/pages/notifications_detail_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:nylo_framework/nylo_framework.dart';

class PopupNotificationMessageSlider extends StatefulWidget {
  final List<NotificationsMessage> popups;
  final Function onClosed;
  const PopupNotificationMessageSlider({
    super.key,
    required this.popups,
    required this.onClosed,
  });

  @override
  State<PopupNotificationMessageSlider> createState() =>
      _PopupNotificationMessageSliderState();
}

class _PopupNotificationMessageSliderState
    extends State<PopupNotificationMessageSlider> {
  int currentSlide = 0;
  final PageController slideController = PageController();
  ApiController apiController = ApiController();
  List<NotificationsMessage> popups = [];

  isMessageExpiryReminder(NotificationsMessage msg) {
    return msg.type == "Notification";
  }

  doAcknowledge() async {
    final msg = popups[currentSlide];
    final isExpiryReminder = isMessageExpiryReminder(msg);
    if (isExpiryReminder) {
      widget.onClosed();
      return routeTo(DrivingLicensePage.path);
    }
    routeTo(NotificationsDetailPage.path, data: {
      "title": msg.title,
      "messageBody": msg.content,
      "message": msg,
      "_acknowledgeMessage": (int id) async {
        final idx = popups.indexWhere((it) => it.id == id);
        setState(() {
          popups[idx].acknowledge = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      popups = widget.popups;
    });
    return Container(
      color: ThemeColor.get(context).buttonPrimaryContent,
      // decoration: BoxDecoration(
      //   borderRadius: Border
      // ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                popups.length > 1
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16.0,
                        ),
                        child: Wrap(
                          spacing: 8,
                          alignment: WrapAlignment.center,
                          runAlignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            InkWell(
                              child: Icon(
                                Icons.chevron_left,
                                color: currentSlide == 0
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                              onTap: () {
                                if (currentSlide == 0) return;
                                slideController.animateToPage(currentSlide - 1,
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeIn);
                              },
                            ),
                            Text(
                              "${currentSlide + 1}/${popups.length}",
                              textScaler: TextScaler.noScaling,
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            InkWell(
                              child: Icon(
                                Icons.chevron_right,
                                color: currentSlide == popups.length - 1
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                              onTap: () {
                                if (currentSlide == popups.length - 1) return;
                                slideController.animateToPage(currentSlide + 1,
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeIn);
                              },
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(),
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.close,
                    color: nyHexColor("#D8D8D8"),
                  ),
                  onPressed: () async {
                    widget.onClosed();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: slideController,
              onPageChanged: (index) async {
                if (popups[index].read == false) {
                  await apiController.updateNotificationsMessageStatus(
                    context,
                    popups[index],
                    'read',
                  );
                }
                setState(() {
                  popups[index].read = true;
                  currentSlide = index;
                });
              },
              children: popups.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  popups[currentSlide].title,
                                  textScaler: TextScaler.noScaling,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  dateFormatString(
                                    popups[currentSlide].broadcastTime,
                                    fromFormat: 'yyyy-MM-dd HH:mm',
                                    toFormat: 'dd MMMM y, HH:mm a',
                                  ),
                                  textScaler: TextScaler.noScaling,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                HtmlWidget(
                                  popups[currentSlide].content,
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            )
                        ),
                      ),
                      const SizedBox(height: 8.0),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                ),
                child: GeneralButton(
                  borderRadius: 0.0,
                  disabled: popups.isNotEmpty
                      ? popups[currentSlide].acknowledge == true
                      : true,
                  text: "Go to Driving License",
                  onPressed: () async {
                    await doAcknowledge();
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}
