import 'dart:io';

import 'package:bc_app/app/controllers/home_controller.dart';
import 'package:bc_app/app/models/document_file.dart';
import 'package:bc_app/app/networking/api_service.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:bc_app/resources/widgets/loader_widget.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentViewPage extends NyStatefulWidget<HomeController> {
  static const path = '/document-view';

  DocumentViewPage({super.key}) : super(path, child: _DocumentViewPageState());
}

class _DocumentViewPageState extends NyState<DocumentViewPage> {
  bool isFileExists = false;
  bool isDownloading = false;
  bool inited = false;
  DocumentFile? doc;
  String deviceOsVersion = '';
  String appVersion = '';
  String baseUrl = ApiService().baseUrl;
  Directory? appDocDir;
  String savePath = "";
  String? token = '';

  @override
  void init() {
    super.init();
  }

  @override
  boot() async {
    String? mytoken = await NyStorage.read('authToken') ?? '';
    Map args =
        (ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>);
    setState(() {
      doc = args['doc'];
    });
    String tmpGetDeviceOsVersion = await getDeviceOsVersion();
    String tmpAppVersion = await getAppVersion();

    Directory? localDir = await (Platform.isAndroid
        ? getDownloadsDirectory()
        : getApplicationDocumentsDirectory());

    setState(() {
      deviceOsVersion = tmpGetDeviceOsVersion;
      appVersion = tmpAppVersion;
      appDocDir = localDir;
      savePath = "${appDocDir!.path}/${doc!.name}";
      token = mytoken!;
    });
    _checkAllFilesExistence();
  }

  Future<void> _checkAllFilesExistence() async {
    File file = File(savePath);
    if (await file.exists()) {
      setState(() => isFileExists = true);
    }
    setState(() => inited = true);
  }

  Widget scaffoldBody() {
    if (!inited) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Loader(),
        ],
      );
    }
    return Container(
      color: ThemeColor.get(context).cardBg,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 16.0,
              ),
              color: Colors.white,
              child: InkWell(
                onTap: () async {},
                child: Text(
                  doc!.name,
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: isFileExists
                ? SfPdfViewer.file(
                    File(savePath),
                    key: Key("${doc!.id}"),
                    onDocumentLoadFailed: (details) {
                      showSnackBar(
                        context,
                        "File is unable to load!",
                        isSuccess: false,
                      );
                    },
                  )
                : SfPdfViewer.network(
                    '$baseUrl/mobile-api/?_method=bc.viewDocument&dir=${doc!.folderName}&filename=${doc!.name}',
                    headers: {
                      "Authorization": "Bearer $token",
                      "User-Agent": deviceOsVersion,
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          doc!.folderName,
          textScaler: TextScaler.noScaling,
          style: TextStyle(
            color: ThemeColor.get(context).primaryContent,
          ),
        ),
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            margin: const EdgeInsets.only(top: 19, left: 8.0),
            child: Text(
              "payslip_page.pdf_view_page.left action label".tr(),
              textScaler: TextScaler.noScaling,
              style: const TextStyle(
                shadows: [Shadow(color: Colors.blue, offset: Offset(0, -2))],
                color: Colors.transparent,
                decoration: TextDecoration.underline,
                decorationColor: Colors.blue,
              ),
            ),
          ),
        ),
        backgroundColor: ThemeColor.get(context).background,
        leadingWidth: 100,
        actions: [
          InkWell(
            onTap: () {
              if (isFileExists) {
                _openFile(savePath);
              } else {
                _downloadFile();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(top: 2.5, right: 8.0),
              child: Text(
                isFileExists
                    ? "payslip_page.pdf_view_page.right action label view file"
                        .tr()
                    : "payslip_page.pdf_view_page.right action label download"
                        .tr(),
                textScaler: TextScaler.noScaling,
                style: const TextStyle(
                  shadows: [Shadow(color: Colors.blue, offset: Offset(0, -2))],
                  color: Colors.transparent,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.blue,
                ),
              ),
            ),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: scaffoldBody(),
      ),
    );
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

  void _openFile(filename) async {
    bool validFile = true;
    final readFile = File(filename).openRead().handleError((e) {
      validFile = false;
    });
    await for (final _ in readFile) {}
    if (!validFile) {
      return showDownloadConfirmation(context);
    }
    OpenFile.open(filename);
  }

  Future<void> _downloadFile({redownload = false}) async {
    if (!inited) return;
    if (isDownloading) return;
    bool isAllowed = await _requestPermissions();
    if (!isAllowed) return;
    setState(() => isDownloading = true);

    Dio dio = Dio();
    try {
      showSnackBar(
        context,
        "payslip_page.pdf_view_page.right action label downloading".tr(),
        isSuccess: true,
      );
      String fileName = savePath;
      if (redownload) {
        fileName = fileName.replaceAll("${appDocDir!.path}/", "");
        File f = File(savePath);
        if (await f.exists()) {
          f.rename("${appDocDir!.path}/tmp_$fileName");
        }
      }
      // Download the file and save it to the path.
      bool success = true;
      await dio.download(
        '$baseUrl/mobile-api/',
        savePath,
        queryParameters: {
          "_method": "bc.downloadDocument",
          "dir": doc!.folderName,
          "filename": doc!.name,
          "_version": appVersion
        },
        options: Options(
          headers: Map.from({
            "Authorization": "Bearer $token",
            "User-Agent": deviceOsVersion
          }),
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
        onReceiveProgress: (received, total) {
          if (total < 0) {
            success = false;
          }
        },
      ).then((onValue) {
        setState(() => isDownloading = false);
      });

      if (!success) {
        if (redownload) {
          // revert filename
          File f = File("${appDocDir!.path}/tmp_$fileName");
          if (await f.exists()) {
            f.rename(savePath);
          }
        }
        showSnackBar(
          context,
          "${"payslip_page.pdf_view_page.download failed".tr()} Try again.",
          isSuccess: false,
        );
      } else {
        bool validFile = true;
        final readFile = File(savePath).openRead().handleError((e) {
          validFile = false;
        });
        await for (final _ in readFile) {}
        if (!validFile) {
          File(savePath).delete();
          if (redownload) {
            // revert filename
            File f = File("${appDocDir!.path}/tmp_$fileName");
            if (await f.exists()) {
              f.rename(savePath);
            }
          }
          return showSnackBar(
            context,
            "Corrupted downloaded file! Please try again.",
            isSuccess: false,
          );
        }
        setState(() {
          isFileExists = true;
        });
        showSnackBar(
          context,
          "payslip_page.pdf_view_page.download complete".tr(),
          isSuccess: true,
        );
      }
    } catch (e) {
      debugPrint(e.toString());
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

  void showDownloadConfirmation(BuildContext context) {
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
                          Expanded(
                            child: Text(
                              "buscheck_page.busdeclaration_screen.confirmation"
                                  .tr(),
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
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      Text(
                        "payslip_page.pdf_view_page.re-download text".tr(),
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
                            text: "payslip_page.pdf_view_page.cancel".tr(),
                            color: Colors.grey.withOpacity(0.3),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 24),
                          GeneralButton(
                            text: "payslip_page.pdf_view_page.download".tr(),
                            onPressed: () async {
                              await _downloadFile(redownload: true);
                              Navigator.pop(context);
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
