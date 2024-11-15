import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/bus_check_item.dart';
import 'package:bc_app/resources/pages/end_of_trip_tasks_page.dart';
import 'package:bc_app/resources/pages/parade_tasks_page.dart';
import 'package:bc_app/resources/pages/qr_scanner_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/input_text_widget.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ChooseBusPage extends NyStatefulWidget {
  static const path = '/choose-bus';
  
  ChooseBusPage({super.key}) : super(path, child: _ChooseBusPageState());
}

class _ChooseBusPageState extends NyState<ChooseBusPage> {
  ApiController apiController = ApiController();
  TextEditingController plateController = TextEditingController();
  
  //State
  String task = '';
  @override
  init() async {

  }
  
  /// Use boot if you need to load data before the [view] is rendered.
  @override
  boot() async {
    Map data = widget.data();

    setState(() {
      task = data['task'] ?? "";
    });

  }

  _onSubmit() async{
    if (plateController.text == '') {
      showSnackBar(
        context, 
        "buscheck_page.endoftrip_screen.bus plate number alert message".tr(),
        isSuccess: false
      );
      return;
    }

    String value = plateController.text;

    setLoading(true, name: 'onLoading');
    final res = await apiController.startBusCheck(
      context,
      task,
      value.toUpperCase(),
    );
    setLoading(false, name: 'onLoading');
    if (!res['success']) {
      showSnackBar(
        context, 
        res['message'] ?? 'An error has occured',
        isSuccess: false
      );
      return;
    }
    setLoading(false, name: 'onLoading');
    String path = ParadeTasksPage.path;
    if (task == "End of Trip Tasks") {
      path = EndOfTripTasksPage.path;
    }
    final List<BusCheckItem> checklist = res['checklist'] ?? [];
    Navigator.pushReplacementNamed(
      context,
      path,
      arguments: {
        "result": value.toUpperCase(),
        "taskName": task,
        "checklist": checklist.toList(),
        "bus": res['bus']
      },
    );
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: TitleBar(
        title: "buscheck_page.endoftrip_screen.bus plate number hint".tr()
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InputText(
                label:
                    'buscheck_page.endoftrip_screen.bus plate number'
                        .tr(),
                controller: plateController,
                value: '',
                placeholder:
                    "buscheck_page.endoftrip_screen.bus plate number hint"
                        .tr(),
                type: TextInputType.text,
                readOnly: false,
                required: true,
                capitalized: true,
              ),
              const SizedBox(height: 8.0),
              GestureDetector(
                onTap: () {
                  routeTo(
                    QRScanner.path, 
                    navigationType: NavigationType.popAndPushNamed,
                    data: {'task': task});
                },
                child: Text(
                  "qr_page.scan qr".tr(),
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              ElevatedButton(
                onPressed: _onSubmit,
                child: Text("buscheck_page.endoftrip_screen.button submit".tr(), textScaler: TextScaler.noScaling,)
              )
            ],
          ),
        ),
      ),
    );
  }
}
