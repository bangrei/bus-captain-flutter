import 'dart:convert';
import 'dart:io';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/broadcast_message.dart';
import 'package:bc_app/app/networking/api_service.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:bc_app/resources/widgets/components/input_text_area_widget.dart';
import 'package:bc_app/resources/widgets/components/master_layout_widget.dart';
import 'package:bc_app/resources/widgets/components/titlebar_widget.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageDetailPage extends NyStatefulWidget {
  static const path = '/message-detail';

  MessageDetailPage({super.key})
      : super(path, child: _MessageDetailPageState());
}

class _MessageDetailPageState extends NyState<MessageDetailPage> {
  BroadcastMessage? message;
  Function(int)? onPressAcknowlege;
  Function? onLeave;
  bool isDownloading = false;
  double downloadProgress = 0;
  ApiController apiController = ApiController();
  File? uploadedFile;
  double uploadProgress = 0;
  bool isUploading = false;
  String baseUrl = ApiService().baseUrl;
  TextEditingController remarksController = TextEditingController();
  List<FilePickerResult> newFiles = [];
  int uploadingIndex = -1;
  List<int> doneUploaded = [];
  String pageHeader = "";

  @override
  init() async {}

  /// Use boot if you need to load data before the [view] is rendered.
  @override
  boot() async {
    final data = widget.data();
    if (data.isNotEmpty) {
      BroadcastMessage msg = data['message'];
      setState(() {
        message = msg;
        onPressAcknowlege = data['_acknowledgeMessage'];
        pageHeader = data['pageHeader'];
        onLeave = data['_onLeave'];
      });

      if (message!.read == false) {
        await apiController.updateBroadcastMessageStatus(
          context,
          message!,
          'read',
          message!.response,
        );
        setState(() => message!.read = true);
      }
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

  removeUploadedFile(String fileUrl, int fileIndex) async {
    final res = await apiController.removeBroadcastMessageFile(
      context,
      message!,
      fileUrl,
    );
    if (!res) return;
    setState(() {
      message!.actionFiles.removeAt(fileIndex);
    });
  }

  doAcknowledge() async {
    if (message!.acknowledge) return;
    if (message!.read == false) return;
    if (message!.type == "Actionable" &&
        newFiles.isNotEmpty &&
        doneUploaded.isEmpty) {
      showSnackBar(
        context,
        "message_page.details_screen.upload desc".tr(),
        isSuccess: false,
      );
      return;
    }
    final res = await apiController.updateBroadcastMessageStatus(
      context,
      message!,
      'acknowledge',
      remarksController.text,
    );
    if (!res) return;
    setState(() => message!.acknowledge = true);
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
      Directory? appDocDir = await (Platform.isAndroid
          ? getDownloadsDirectory()
          : getApplicationDocumentsDirectory());
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
    if (newFiles.isEmpty) return;
    File attachedFile = File(newFiles[uploadingIndex].paths[0]!);

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
      ).then((res) {
        if (res.data == null) {
          showSnackBar(
            context,
            "Something went wrong! Unable to upload file.",
            isSuccess: false,
          );
          return;
        }
        final json = jsonDecode(res.data);
        final success = json["success"] == true;
        if (success) {
          setState(() {
            doneUploaded.add(uploadingIndex);
            newFiles.removeAt(uploadingIndex);
            message!.actionFiles.add(json['attachment']);
          });
        } else {
          final resMessage = json['message'];
          showSnackBar(context, resMessage, isSuccess: false);
        }
      }).catchError((onError) {
        showSnackBar(
          context,
          "Something went wrong! $onError",
          isSuccess: false,
        );
      });
    } catch (e) {
      showSnackBar(
        context,
        "Upload file was failed! ${e.toString()}",
        isSuccess: false,
      );
    } finally {
      setState(() {
        uploadingIndex = -1;
        isUploading = false;
      });
    }
  }

  isAcknowledgeButtonDisable() {
    bool disable = message!.acknowledge == true;
    if (message!.type == "Actionable") {
      if (message!.acknowledge != true) {
        disable = message!.actionFiles.isEmpty;
      }
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

  beforeLeave() {
    bool allowLeave = true;
    if (message!.acknowledge != true) {
      if (newFiles.isNotEmpty) {
        allowLeave = false;
      }
      if (remarksController.text != "") {
        allowLeave = false;
      }
    }
    if (allowLeave) {
      onLeave!();
    } else {
      showLeavePageConfirmation(context);
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: TitleBar(
        title: "message_page.details_screen.title".tr(),
        callback: () {
          beforeLeave();
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: MasterLayout(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
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
                    Text(
                      '${"message_page.list_screen.posted by".tr()} ${message!.authorDisplay}',
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(
                        fontSize: 12.41,
                        color: Color(0xFFA5ACB8),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 40),
                    message!.read && message!.type == 'Actionable'
                        ? Column(
                            children: [
                              InputTextArea(
                                label:
                                    'message_page.details_screen.response'.tr(),
                                placeholder: '',
                                textarea: true,
                                controller: remarksController,
                                readOnly: message!.acknowledge,
                                value: message!.response,
                              ),
                              message!.acknowledge
                                  ? const SizedBox()
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 14),
                                            child: OutlinedButton(
                                              onPressed: () async {
                                                final file = await FilePicker
                                                    .platform
                                                    .pickFiles(
                                                  type: FileType.custom,
                                                  allowMultiple: false,
                                                  allowedExtensions: [
                                                    'jpg',
                                                    'pdf',
                                                    'png'
                                                  ],
                                                );
                                                if (file != null) {
                                                  setState(() {
                                                    newFiles = [
                                                      ...[file],
                                                      ...newFiles
                                                    ];
                                                  });
                                                }
                                              },
                                              style: ButtonStyle(
                                                foregroundColor:
                                                    WidgetStatePropertyAll<
                                                            Color>(
                                                        ThemeColor.get(context)
                                                            .background),
                                                backgroundColor:
                                                    const WidgetStatePropertyAll<
                                                        Color>(Colors.blue),
                                                side:
                                                    const WidgetStatePropertyAll<
                                                        BorderSide>(
                                                  BorderSide(
                                                      color: Colors.blue),
                                                ),
                                                padding: WidgetStateProperty
                                                    .resolveWith<
                                                            EdgeInsetsGeometry>(
                                                        (Set<WidgetState>
                                                            states) {
                                                  return const EdgeInsets
                                                      .symmetric(
                                                    vertical: 0,
                                                    horizontal: 16,
                                                  );
                                                }),
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "message_page.details_screen.add file"
                                                        .tr(),
                                                    textScaler:
                                                        TextScaler.noScaling,
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                  ),
                                                  const SizedBox(width: 2),
                                                  const Icon(
                                                    Icons.add_outlined,
                                                    size: 18,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                              _uploadFile()
                            ],
                          )
                        : const SizedBox(),
                  ],
                ),
                GeneralButton(
                  disabled: isAcknowledgeButtonDisable(),
                  text: "message_page.details_screen.acknowledge".tr(),
                  onPressed: () async {
                    await doAcknowledge();
                  },
                )
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
    bool tobeUploaded = false,
    int fileIndex = -1,
    Function? removeCallback,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: nyHexColor("F8FAFE"),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'public/assets/images/icons/$icon.png',
                height: 33,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
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
                      overflow: TextOverflow.ellipsis,
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
                        isUploading && fileIndex == uploadingIndex
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
              ),
              fileIndex == -1
                  ? IconButton(
                      onPressed: () {
                        if (isUploading) return;
                        downloadFile(filePath);
                      },
                      icon: Image.asset(
                        "public/assets/images/icons/download.png",
                        width: 16,
                        height: 16,
                      ),
                    )
                  : const SizedBox(),
              message!.acknowledge == true
                  ? const SizedBox()
                  : IconButton(
                      onPressed: () {
                        if (removeCallback != null) removeCallback();
                      },
                      icon: Image.asset(
                        "public/assets/images/icons/close_circle.png",
                        width: 16,
                        height: 16,
                      ),
                    )
            ],
          ),
          fileIndex == uploadingIndex && isUploading && tobeUploaded
              ? Padding(
                  padding: const EdgeInsets.only(top: 12.0, right: 16.0),
                  child: LinearProgressIndicator(
                    value: uploadProgress,
                    backgroundColor: Colors.grey,
                    color: Colors.blue,
                  ),
                )
              : const SizedBox(),
          const SizedBox(height: 8),
          tobeUploaded
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 26,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: OutlinedButton(
                          onPressed: () async {
                            if (isUploading) return;
                            setState(() => uploadingIndex = fileIndex);
                            await uploadAcknowledgeFile();
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll<Color>(
                                ThemeColor.get(context).background),
                            foregroundColor:
                                const WidgetStatePropertyAll<Color>(
                                    Colors.blue),
                            side: const WidgetStatePropertyAll<BorderSide>(
                              BorderSide(color: Colors.blue),
                            ),
                            padding: WidgetStateProperty.resolveWith<
                                EdgeInsetsGeometry>((Set<WidgetState> states) {
                              return const EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 16,
                              );
                            }),
                          ),
                          child: Text(
                            "message_page.details_screen.upload".tr(),
                            textScaler: TextScaler.noScaling,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox()
        ],
      ),
    );
  }

  Widget _uploadFile() {
    return Column(
      children: [
        ...newFiles.asMap().entries.map((entry) {
          var index = entry.key;
          var file = newFiles[index].files[0];
          var filename = file.name.split('.');
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
            fileIndex: index,
            tobeUploaded: true,
            removeCallback: () {
              setState(() => newFiles.removeAt(index));
            },
          );
        }),
        ...message!.actionFiles.asMap().entries.map((entry) {
          int index = entry.key;
          int len = message!.actionFiles.length - 1;
          int ix = len - index; // sort DESC
          final file = message!.actionFiles[ix];
          if (file == null) return const SizedBox();
          String name = file['name'].toString();
          double size = double.parse(file['size'].toString());
          final ext = name.split(".").last;
          String icon = 'upload_$ext';
          if (ext == 'jpg' || ext == 'jpeg') {
            icon = 'upload_jpg';
          }
          return uploadedActionFile(
            icon,
            name,
            size,
            file['url'],
            fileIndex: -1,
            removeCallback: () {
              removeUploadedFile(file['url'], ix);
            },
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  void showLeavePageConfirmation(BuildContext context) {
    Future.delayed(
      const Duration(seconds: 1),
      () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => LayoutBuilder(
            builder: (context, constraints) {
              return Dialog(
                backgroundColor: ThemeColor.get(context).background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              "Confirm?",
                              textScaler: TextScaler.noScaling,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      Text(
                        "Are you sure you want to exit this page without saving your progress?",
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          color: ThemeColor.get(context).primaryContent,
                          fontSize: 14.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          GeneralButton(
                            text: "no".tr(),
                            color: Colors.grey.withOpacity(0.3),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 24),
                          GeneralButton(
                            text: "yes".tr(),
                            onPressed: () async {
                              Navigator.pop(context);
                              onLeave!();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
