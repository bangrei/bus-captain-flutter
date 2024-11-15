import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/uniform_request.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';



class UniformRequestCard extends StatefulWidget {
  final UniformRequest data;
  final Function handler;
  final BuildContext context;
  final Function onRefresh;

  const UniformRequestCard({
    Key? key,
    required this.data,
    required this.handler,
    required this.context,
    required this.onRefresh,
  }) : super(key: key);

  @override
  _PayslipCardState createState() => _PayslipCardState();
}

BoxDecoration myBoxDecoration(BuildContext context,double width) {
  return BoxDecoration(
    color: ThemeColor.get(context).cardBg,
    border: Border.all(color: Colors.black26, width: width),
    borderRadius: BorderRadius.circular(10),
  );
}



class _PayslipCardState extends State<UniformRequestCard> {
  ApiController apiController = ApiController();

  void _handleCancel() async {
    return _showConfirmation(context, 
      (bool confirmed) async {
        if (!confirmed) return;
        await apiController.cancelUniformRequest(context: context, requestId: widget.data.id);
        widget.onRefresh();
      }
    );
  }

  void _showConfirmation(BuildContext context, Function(bool) response) {
    showDialog(
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
                        "uniform_request_page.cancel_screen.title".tr(),
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        response(false);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'uniform_request_page.cancel_screen.confirmation message'.tr(),
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: ThemeColor.get(context).primaryContent,
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${'uniform_request_page.bottom_sheet.order no'.tr()} ${widget.data.orderno}',
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: ThemeColor.get(context).primaryContent,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins-Bold",
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${'uniform_request_page.bottom_sheet.item requested'.tr()} ${widget.data.name}',
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: ThemeColor.get(context).primaryContent,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins-Bold",
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${'uniform_request_page.bottom_sheet.item size'.tr()} ${widget.data.size}',
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: ThemeColor.get(context).primaryContent,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins-Bold",
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${'uniform_request_page.bottom_sheet.quantity'.tr()} ${widget.data.qty}',
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: ThemeColor.get(context).primaryContent,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins-Bold",
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GeneralButton(
                      text: "no".tr(),
                      color: Colors.black.withOpacity(0.1),
                      onPressed: () {
                        response(false);
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 24),
                    GeneralButton(
                      text: "yes".tr(),
                      onPressed: () {
                        response(true);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.handler(widget.context, widget.data);
      },
      child: Container(
        decoration: myBoxDecoration(context, 1),
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.all(15.0), //
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${"uniform_request_page.list_screen.order no".tr()} ${widget.data.orderno}",
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          color: ThemeColor.get(context).primaryContent,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins-Bold",
                        ),
                      ),
                      Text(
                        widget.data.name,
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(fontFamily: "Poppins"),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.data.submittedTime,
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  constraints:
                      const BoxConstraints(minWidth: 110, maxWidth: 110),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                        backgroundColor: getUniformStatusColor(widget.data.status)),
                    onPressed: () {},
                    child: Text(
                      "uniform_request_page.list_screen.filter label ${widget.data.status.toLowerCase()}".tr(),
                      textScaler: TextScaler.noScaling,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(
                            color: ThemeColor.get(context).appBarPrimaryContent,
                            fontFamily: "Poppins", 
                            fontSize: 13,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Spacer(),
                widget.data.status == "Pending"
                ? GestureDetector(
                  onTap: _handleCancel,
                  child: Container(
                      padding: const EdgeInsets.all(9.5),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.red
                      ),
                      child: Text(
                        'uniform_request_page.cancel_screen.button label cancel'.tr(),
                        style: TextStyle(
                          color: ThemeColor.get(context).appBarPrimaryContent,
                          fontSize: 12
                        ),
                      ),
                    ),
                  )
                : const SizedBox()
              ],
            )
          ],
        ),
      ),
    );
  }
}

// Future<void> _launchUrl(url) async {
//   if (!await launchUrl(url)) {
//     throw Exception('Could not launch $url');
//   }
// }
