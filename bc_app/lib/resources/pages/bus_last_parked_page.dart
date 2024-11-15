import 'package:bc_app/app/networking/api_service.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '/app/controllers/home_controller.dart';

class BuslastParkedLocationPage extends NyStatefulWidget<HomeController> {
  static const path = '/bus-last-parked';

  BuslastParkedLocationPage({super.key})
      : super(path, child: _BusLastParkedLocationPageState());
}

class _BusLastParkedLocationPageState
    extends NyState<BuslastParkedLocationPage> {
  WebViewController _webViewController = WebViewController();
  List<String>? DepotList = ['Depot 1', 'Depot2'];
  String selectedDepot = "";
  bool submitted = false;

  String stage = '-stage';

  @override
  boot() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _webViewController = WebViewController.fromPlatformCreationParams(params);

    String baseUrl = ApiService().baseUrl;
    if (baseUrl ==  getEnv('STAGE_API_BASE_URL')) {
      stage = '-stage';
    } else if (baseUrl ==  getEnv('PROD_API_BASE_URL')) {
      stage = '';
    } else if (baseUrl ==  getEnv('TEST_API_BASE_URL')) {
      stage = '-apitest';
    }
    
    // Init WebviewController
    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
          Uri.parse('https://bcms$stage.solo-cloud.com/ext/buslocation.php'))
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          debugPrint('WebView is loading (progress : $progress%)');
        },
        onPageStarted: (String url) {
          debugPrint('Page started loading: $url');
        },
        onPageFinished: (String url) {
          debugPrint('Page finished loading: $url');
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('''
            Page resource error:
            code: ${error.errorCode}
            description: ${error.description}
            errorType: ${error.errorType}
            isForMainFrame: ${error.isForMainFrame}
            ''');
        },
        onNavigationRequest: (NavigationRequest request) async {
          debugPrint("I am going to ${request.url}");

          // if (request.url.startsWith('blob')) {
          //   final status = await Permission.storage.request();
          //   if (status.isGranted) {
          //     // Get the external storage directory
          //     final dir = await getExternalStorageDirectory();
          //     if (dir != null) {
          //       // Enqueue the download task
          //       final taskId = await FlutterDownloader.enqueue(
          //         url: request.url,
          //         savedDir: dir.path,
          //         saveInPublicStorage: true,
          //         showNotification:
          //             true, // Show download progress in status bar
          //         openFileFromNotification:
          //             true, // Click on notification to open downloaded file
          //       );
          //       debugPrint('Download task id: $taskId');
          //     }
          //   } else {
          //     debugPrint('Permission denied');
          //   }
          //   return NavigationDecision.prevent;
          // }

          // Handle other URLs normally
          return NavigationDecision.navigate;
        },
      ));
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: TitleBar(title: "buscheck_page.buslastpark_screen.title".tr()),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 15.5, right: 15.5, top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min, // This line is updated
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: (MediaQuery.of(context).size.height) / 1.35,
                  child: WebViewWidget(controller: _webViewController),
                ),
                // Visibility(
                //   visible: !submitted,
                //   child: Column(
                //     children: [
                //       InputDropdown(
                //         required: true,
                //         label: 'Depot',
                //         items: DepotList!,
                //         value: selectedDepot.isEmpty ? null : selectedDepot,
                //         placeholder: 'Select Depot',
                //         onChanged: (String? newValue) {
                //           setState(() {
                //             selectedDepot = newValue ?? "";
                //           });
                //         },
                //       ),
                //       InputText(
                //         label: 'Bus Plate Number',
                //         controller: _plateController,
                //         value: _plateController.text,
                //         placeholder: "Enter Bus Plate Number",
                //         type: TextInputType.text,
                //         required: true,
                //       ),
                //       SizedBox(height: 20),
                //       Container(
                //         width: double.infinity,
                //         child: ElevatedButton(
                //           onPressed: () {
                //             setState(() {
                //               submitted = true;
                //             });
                //           },
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: const Color(0xFF1570EF),
                //             textStyle: const TextStyle(
                //               fontSize: 16,
                //               fontWeight: FontWeight.bold,
                //               color: Color.fromRGBO(255, 255, 255, 1),
                //             ),
                //             shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(
                //                   10.0), // Rounded corners
                //             ),
                //           ),
                //           child: Text("Submit"),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get isThemeDark =>
      ThemeProvider.controllerOf(context).currentThemeId ==
      getEnv('DARK_THEME_ID');
}
