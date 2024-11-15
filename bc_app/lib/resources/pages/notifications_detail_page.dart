import 'dart:io';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/notifications_message.dart';
import 'package:bc_app/app/networking/api_service.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationsDetailPage extends NyStatefulWidget {
  static const path = '/notifications-detail';

  NotificationsDetailPage({super.key})
      : super(path, child: _NotificationsDetailPageState());
}

class _NotificationsDetailPageState extends NyState<NotificationsDetailPage> {
  FilePickerResult? selectedFile;
  NotificationsMessage? message;
  Function(int)? onPressAcknowlege;
  bool isDownloading = false;
  double downloadProgress = 0;
  ApiController apiController = ApiController();
  File? uploadedFile;
  double uploadProgress = 0;
  bool isUploading = false;

  @override
  init() async {
    final data = widget.data();
    if (data.isNotEmpty) {
      NotificationsMessage msg = data['message'];
      File? file;
      if (msg.actionFiles.isNotEmpty) {
        file = File(msg.actionFiles[0]['url']);
      }
      setState(() {
        message = msg;
        onPressAcknowlege = data['_acknowledgeMessage'];
        uploadedFile = file;
      });

      if (message!.read == false) {
        await apiController.updateNotificationsMessageStatus(
          context,
          message!,
          'read',
        );
        setState(() => message!.read = true);
      }
    }
  }

  
  String baseUrl = ApiService().baseUrl;

  /// Use boot if you need to load data before the [view] is rendered.
  // @override
  // boot() async {
  //
  // }
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
    if (message!.type == "Actionable" && uploadedFile == null) {
      showSnackBar(
        context,
        "notifications_page.details_screen.upload desc".tr(),
        isSuccess: false,
      );
      return;
    }
    final res = await apiController.updateNotificationsMessageStatus(
      context,
      message!,
      'acknowledge',
    );
    if (!res) return;
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
    bool disable = message!.acknowledge;
    if (message!.type == "Actionable" && uploadedFile == null) disable = true;
    if (message!.actionFiles.isNotEmpty && message!.acknowledge != true) {
      disable = false;
    }
    return disable;
  }

  _launchUrl() async {
    final urlString = message!.hyperlink;
    Uri url;

    // Ensure URL has a scheme
    if (!Uri.parse(urlString).hasScheme) {
      url = Uri.parse('https://$urlString');
    } else {
      url = Uri.parse(urlString);
    }

    // Check if the URL is valid and uses the correct scheme
    if (!url.isScheme('http') && !url.isScheme('https')) {
      showSnackBar(
        context,
        "Unsupported URL link!",
        isSuccess: false,
      );
      return;
    }
    
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppBrowserView,
      browserConfiguration: const BrowserConfiguration(showTitle: true),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: TitleBar(title: "notifications_page.details_screen.title".tr()),
      body: SafeArea(
        child: SingleChildScrollView(
          child: MasterLayout(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  message!.title,
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins-SemiBold',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                message!.type == "Notification"
                    ? HtmlWidget(
                        message!.content,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins-Medium',
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    : Text(
                  message!.content,
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins-Medium',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),
                message!.hyperlink.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message!.hyperlink,
                            textScaler: TextScaler.noScaling,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              fontFamily: 'Poppins-Medium',
                              fontWeight: FontWeight.w400,
                            ),
                          ).onTap(() => _launchUrl()),
                          const SizedBox(height: 20)
                        ],
                      )
                    : const SizedBox(height: 0),
                Text(
                  dateFormatString(
                    message!.broadcastTime,
                    fromFormat: 'yyyy-MM-dd HH:mm',
                    toFormat: 'dd MMMM y, HH:mm a',
                  ),
                  textScaler: TextScaler.noScaling,
                  style: const TextStyle(
                    fontSize: 12.41,
                    color: Color(0xFFA5ACB8),
                  ),
                ),
                const SizedBox(height: 30),
                Builder(
                  builder: (context) {
                    if (message!.attachments.isNotEmpty) {
                      List<Widget> attachments = message!.attachments
                          .map((it) => _attachment(it))
                          .toList();
                      attachments.add(const SizedBox(height: 30));
                      return Column(
                        children: attachments,
                      );
                    }
                    return const SizedBox();
                  },
                ),
                GeneralButton(
                  disabled: isAcknowledgeButtonDisable(),
                  text: "notifications_page.details_screen.acknowledge".tr(),
                  onPressed: () async {
                    await doAcknowledge();
                  },
                ),
                const SizedBox(height: 40),
                message!.read && message!.type == 'Actionable'
                    ? _uploadFile()
                    : const SizedBox()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _attachment(dynamic attachment) {
    final size = double.parse(attachment['size']) / 1024;
    final names = attachment['name'].split('.');
    final ext = names[names.length - 1];
    String icon = 'upload_$ext';
    if (ext == 'jpg' || ext == 'jpeg') {
      icon = 'upload_jpg';
    }
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
          decoration: BoxDecoration(
            color: ThemeColor.get(context).fileContainer,
            border: Border.all(
              color: nyHexColor("E4ECF5"),
            ),
          ),
          child: Row(
            children: [
              Image.asset(
                'public/assets/images/icons/$icon.png',
                height: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attachment['name'],
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(
                        fontFamily: 'Inter-Regular',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "${size.toStringAsFixed(2)} KB",
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: ThemeColor.get(context).fileSize,
                        fontSize: 12,
                        fontFamily: 'Inter-Light',
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  await downloadFile(attachment['url']);
                },
                icon: Image.asset(
                  color: ThemeColor.get(context).primaryContent,
                  'public/assets/images/icons/download.png',
                  width: 16,
                  height: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget uploadedActionFile(
    String icon,
    String filename,
    double filesize,
    String filePath, {
    bool downloadable = false,
  }) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
          decoration: BoxDecoration(
            color: nyHexColor("F8FAFE"),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset(
                    'public/assets/images/icons/$icon.png',
                    height: 33,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        filename,
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          fontSize: 11.28,
                          fontFamily: 'Inter-Regular',
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF292D32),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '${(filesize / 1024).round()} KB',
                            textScaler: TextScaler.noScaling,
                            style: const TextStyle(
                              color: Color(0xFFA9ACB4),
                              fontSize: 9.4,
                              fontFamily: 'Inter-Light',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          isUploading
                              ? Row(
                                  children: [
                                    uploadProgress < 1.0
                                        ? const SizedBox(
                                            width: 8.0,
                                            height: 8.0,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1.0,
                                            ),
                                          )
                                        : const SizedBox(),
                                    const SizedBox(width: 6.0),
                                    Text(
                                      uploadProgress < 1.0
                                          ? 'Uploading...'
                                          : 'Done',
                                      textScaler: TextScaler.noScaling,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 10.0,
                                        fontFamily: 'Inter-Light',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              isUploading
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12.0, right: 16.0),
                      child: LinearProgressIndicator(
                        value: uploadProgress,
                        backgroundColor: Colors.grey,
                        color: Colors.blue,
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
        Positioned(
          right: 0,
          child: IconButton(
            onPressed: () {
              if (downloadable) {
                downloadFile(filePath);
              } else {
                setState(() {
                  selectedFile = null;
                  uploadedFile = null;
                  isUploading = false;
                });
              }
            },
            icon: Image.asset(
              "public/assets/images/icons/${downloadable ? 'download' : 'close_circle'}.png",
              width: 16,
              height: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _uploadFile() {
    return Column(
      children: [
        Builder(builder: (context) {
          if (message!.actionFiles.isNotEmpty) {
            final file = message!.actionFiles[0];
            String name = file['name'].toString();
            double size = double.parse(file['size'].toString());
            final ext = name.split(".").last;
            String icon = 'upload_$ext';
            if (ext == 'jpg' || ext == 'jpeg') {
              icon = 'upload_jpg';
            }
            return uploadedActionFile(icon, name, size, file['url'],
                downloadable: true);
          }
          if (selectedFile != null) {
            var file = selectedFile?.files[0];
            var filename = file!.name.split('.');
            var type = filename[filename.length - 1];
            String icon = 'upload_$type';
            if (type == 'jpg' || type == 'jpeg') {
              icon = 'upload_jpg';
            }
            return uploadedActionFile(
              icon,
              file.name.toString(),
              double.parse(file.size.toString()),
              file.path!,
              downloadable: false,
            );
          }
          return DottedBorder(
            strokeWidth: 1.5,
            dashPattern: const [5],
            color: nyHexColor("CBD0DC"),
            borderType: BorderType.RRect,
            padding: const EdgeInsets.all(16),
            radius: const Radius.circular(9.77),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'public/assets/images/icons/upload.png',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(height: 8),
                Text(
                  "notifications_page.details_screen.upload desc".tr(),
                  textScaler: TextScaler.noScaling,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11.28,
                    fontFamily: 'Inter-Regular',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "notifications_page.details_screen.upload rule".tr(),
                  textScaler: TextScaler.noScaling,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 9.77,
                    color: Color(0xFFA9ACB4),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: SizedBox(
                    height: 30,
                    child: OutlinedButton(
                      onPressed: () async {
                        selectedFile = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowMultiple: false,
                          allowedExtensions: ['jpg', 'pdf', 'png'],
                        );
                        if (selectedFile != null) {
                          setState(() {});
                        }
                      },
                      style: OutlinedButton.styleFrom(
                          side:
                              BorderSide(width: 1, color: nyHexColor("CBD0DC")),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(horizontal: 16)),
                      child: Text(
                        "notifications_page.details_screen.browse file".tr(),
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          fontSize: 11.28,
                          fontFamily: 'Inter-Regular',
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF54575C),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        }),
        const SizedBox(height: 20),
        message!.actionFiles.isNotEmpty
            ? const SizedBox()
            : Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedFile = null;
                          uploadedFile = null;
                          isUploading = false;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                          side:
                              BorderSide(width: 1, color: nyHexColor("CBD0DC")),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(horizontal: 16)),
                      child: Text(
                        "notifications_page.details_screen.cancel".tr(),
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          fontFamily: 'Poppins-Regular',
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF54575C),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GeneralButton(
                      disabled:
                          uploadedFile != null ? true : (selectedFile == null),
                      text: "notifications_page.details_screen.upload".tr(),
                      onPressed: () async {
                        await uploadAcknowledgeFile();
                      },
                    ),
                  )
                ],
              ),
      ],
    );
  }
}
