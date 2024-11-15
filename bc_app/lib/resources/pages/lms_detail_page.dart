import 'dart:io';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/lms_notifications.dart';
import 'package:bc_app/app/networking/api_service.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class LmsDetailPage extends NyStatefulWidget {
  static const path = '/lms-detail';
  
  LmsDetailPage({super.key}) : super(path, child: _LmsDetailPageState());
}

class _LmsDetailPageState extends NyState<LmsDetailPage> {

  FilePickerResult? selectedFile;
  LmsNotifications? message;
  Function(int)? onPressAcknowlege;
  bool isDownloading = false;
  double downloadProgress = 0;
  ApiController apiController = ApiController();
  File? uploadedFile;
  double uploadProgress = 0;
  bool isUploading = false;
  String baseUrl = ApiService().baseUrl;

  @override
  init() async {
    
  }
  
  /// Use boot if you need to load data before the [view] is rendered.
  @override
  boot() async {
    final data = widget.data();
    if (data.isNotEmpty) {
      LmsNotifications msg = data['message'];
      File? file;
      setState(() {
        message = msg;
        onPressAcknowlege = data['_acknowledgeMessage'];
        uploadedFile = file;
      });

      // if (message!.read == false) {
      //   await apiController.updateBroadcastMessageStatus(
      //     context,
      //     message!,
      //     'read',
      //   );
      //   setState(() => message!.read = true);
      // }
    }
  }

  Future<bool> _requestPermissions() async {
    PermissionStatus status = await Permission.storage.request();
    if (Platform.isAndroid) {
      final plugin = DeviceInfoPlugin();
      final android = await plugin.androidInfo;
      status = android.version.sdkInt < 33
          ? await Permission.storage.request()
          : PermissionStatus.granted;
    }
    if (status.isDenied || status.isPermanentlyDenied) {
      showSnackBar(
        context,
        "payslip_page.pdf_view_page.storage permission".tr(),
        isSuccess: false,
      );
      return false;
    } else {
      return true;
    }
  }

  doAcknowledge() async {
    if (message!.acknowledge) return;
    if (message!.read == false) return;
    // final res = await apiController.updateBroadcastMessageStatus(
    //   context,
    //   message!,
    //   'acknowledge',
    // );
    // if (!res) return;
    onPressAcknowlege!(message!.id);
    Navigator.pop(context);
  }

  downloadFile(String filePath) async {
    if (isDownloading) return;
    bool isAllowed = await _requestPermissions();
    if (!isAllowed) return;

    setState(() {
      isDownloading = true;
    });

    Dio dio = Dio();
    try {
      String url = "$baseUrl$filePath";
      Uri uri = Uri.parse(url);
      String fileName = uri.pathSegments.last;
      // Get the external storage directory for the app.
      Directory? appDocDir =
          await (Platform.isAndroid ? getDownloadsDirectory() : getApplicationDocumentsDirectory());
      String savePath = "${appDocDir!.path}/$fileName";
      // Download the file and save it to the path.
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              downloadProgress =
                  double.parse((received / total * 100).toStringAsFixed(0));
            });
          }
        },
      );
      setState(() {
        downloadProgress = 100;
      });
      OpenFile.open(savePath);
    } catch (e) {
      showSnackBar(
        context,
        "payslip_page.pdf_view_page.download failed".tr(),
        isSuccess: false,
      );
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  uploadAcknowledgeFile() async {
    if (selectedFile == null) return;
    File attachedFile = File(selectedFile!.paths[0]!);

    try {
      setState(() {
        uploadProgress = 0;
        isUploading = true;
      });
      Dio dio = Dio();
      String? myAuthToken = await NyStorage.read('authToken') ?? '';
      final file = await MultipartFile.fromFile(attachedFile.path);
      final formData = FormData.fromMap({
        'id': message!.id,
        '_method': 'bc.uploadMessageAcknowledgeFile',
      });
      formData.files.addAll([
        MapEntry("attachment", file),
      ]);

      await dio.post(
        "$baseUrl/mobile-api/",
        data: formData,
        options: Options(headers: {"Authorization": "Bearer $myAuthToken"}),
        onSendProgress: (int sent, int total) {
          double percent = double.parse((sent / total).toStringAsFixed(2));
          setState(() => uploadProgress = percent);
        },
      );
      setState(() => uploadedFile = attachedFile);
    } catch (e) {
      showSnackBar(
        context,
        "Upload file was failed! ${e.toString()}",
        isSuccess: false,
      );
    } finally {
      setState(() {});
    }
  }

  isAcknowledgeButtonDisable() {
    // bool disable = message!.acknowledge;
    // if (message!.type == "Actionable" && uploadedFile == null) disable = true;
    // if (message!.actionFiles.isNotEmpty && message!.acknowledge != true) {
    //   disable = false;
    // }
    // return disable;
  }

  // _launchUrl() async {
  //   final urlString = message!.hyperlink;
  //   Uri url;

  //   // Ensure URL has a scheme
  //   if (!Uri.parse(urlString).hasScheme) {
  //     url = Uri.parse('https://$urlString');
  //   } else {
  //     url = Uri.parse(urlString);
  //   }

  //   // Check if the URL is valid and uses the correct scheme
  //   if (!url.isScheme('http') && !url.isScheme('https')) {
  //     showSnackBar(
  //       context,
  //       "Unsupported URL link!",
  //       isSuccess: false,
  //     );
  //     return;
  //   }
    
  //   if (!await launchUrl(
  //     url,
  //     mode: LaunchMode.inAppBrowserView,
  //     browserConfiguration: const BrowserConfiguration(showTitle: true),
  //   )) {
  //     throw Exception('Could not launch $url');
  //   }
  // }

  Widget _buildRow(String label, String data) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: "Poppins-Bold",
              fontWeight: FontWeight.bold
            ),
          ),
          TextSpan(
            text: data,
            style: const TextStyle(
                fontSize: 14,
            ),
          )
        ]
      )
    );
  }
  // Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         label ,
  //         textScaler: TextScaler.noScaling,
  //         style: const TextStyle(
  //           fontSize: 14,
  //           fontFamily: "Poppins-Bold",
  //           fontWeight: FontWeight.bold
  //         ),
  //       ),
  //       Expanded(
  //         child: Text(
  //           data,
  //           textScaler: TextScaler.noScaling,
  //           style: const TextStyle(
  //             fontSize: 14,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: TitleBar(title: "message_page.details_screen.title".tr()),
      body: SafeArea(
        child: SingleChildScrollView(
          child: MasterLayout(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  message!.courseName,
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins-SemiBold',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                _buildRow(
                  "Date: ",
                  dateFormatString(message!.dateTime, fromFormat: 'yyyy-MM-dd HH:mm', toFormat: 'dd/MM/yyyy'),
                ),
                _buildRow(
                  "Time: ",
                  dateFormatString(message!.dateTime, fromFormat: 'yyyy-MM-dd HH:mm', toFormat: 'HH:mm a'),
                ),
                 _buildRow(
                  "Location: ",
                  message!.venue
                ),
                const SizedBox(height: 5),
                _buildRow(
                  "Remarks: ",
                  message!.remarks
                ),
                const SizedBox(height: 20),
                Text(
                  dateFormatString(
                    message!.broadcastTime,
                    fromFormat: 'yyyy-MM-dd HH:mm',
                    toFormat: 'dd/MM/yyyy, HH:mm a',
                  ),
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(
                    fontSize: 12.41,
                    color: Color(0xFFA5ACB8),
                  ),
                ),
                const SizedBox(height: 5),
                // Text(
                //   '${"message_page.list_screen.posted by".tr()} ${message!.authorDisplay}',
                //   textScaler: TextScaler.noScaling,
                //   style: const TextStyle(
                //     fontSize: 12.41,
                //     color: Color(0xFFA5ACB8),
                //   ),
                // ),
                GeneralButton(
                  disabled: false,
                  text: "message_page.details_screen.acknowledge".tr(),
                  onPressed: () async {
                    await doAcknowledge();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
