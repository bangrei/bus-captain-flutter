import 'dart:io';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/controllers/home_controller.dart';
import 'package:bc_app/app/models/payslip.dart';
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

class PdfViewPage extends NyStatefulWidget<HomeController> {
  static const path = '/pdfview';

  PdfViewPage({super.key}) : super(path, child: _PdfViewPageState());
}

class _PdfViewPageState extends NyState<PdfViewPage> {
  /// The [view] method should display your page.
  bool isDownloading = false;
  List<String> filePath = [];
  List<String> filenames = [];
  int selectedPayslip = 0;
  Payslip? payslip;
  ApiController apiController = ApiController();
  bool inited = false;
  List<Map<String, dynamic>> pdfFiles = [];
  String? token = '';
  String deviceOsVersion = '';
  String appVersion = '';
  bool showFilter = true;

  String baseUrl = ApiService().baseUrl;

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
      payslip = args['payslip'];
      showFilter = args['showFilter'] ?? true;
      filenames = payslip!.filenames;
      token = mytoken!;
    });
    _checkAllFilesExistence();

    String tmpGetDeviceOsVersion = await getDeviceOsVersion();
    String tmpAppVersion = await getAppVersion();

    setState(() {
      deviceOsVersion = tmpGetDeviceOsVersion;
      appVersion = tmpAppVersion;
    });
  }

  Map<String, dynamic> currentFile() {
    return pdfFiles.firstWhere((it) => it['index'] == selectedPayslip,
        orElse: () => {});
  }

  Future<void> _checkAllFilesExistence() async {
    Directory? appDocDir = await (Platform.isAndroid
        ? getDownloadsDirectory()
        : getApplicationDocumentsDirectory());

    for (int i = 0; i < filenames.length; i++) {
      String filename = filenames[i];
      // Skip empty filename
      if (filename.isEmpty) continue;
      String savedPath = "${appDocDir!.path}/$filename";
      File file = File(savedPath);
      String type = 'url';
      if (await file.exists()) {
        type = 'directory';
      }
      setState(() {
        pdfFiles.add({
          "filename": type == 'url' ? filename : savedPath,
          "action": "Download",
          "type": type,
          "index": i,
        });
      });
    }
    setState(() {
      inited = true;
    });
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
    if (pdfFiles.isEmpty) {
      return Container(
        color: ThemeColor.get(context).cardBg,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Unable to load payslip...",
                textScaler: TextScaler.noScaling,
                style: TextStyle(color: Colors.black45, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2675EC),
                  padding: const EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 16.0,
                  ),
                ),
                onPressed: () async {
                  await _checkAllFilesExistence();
                },
                child: const Text(
                  "Try again",
                  textScaler: TextScaler.noScaling,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      color: ThemeColor.get(context).cardBg,
      child: Column(
        children: [
          Visibility(
            visible: showFilter,
            child: SizedBox(
              width: double.infinity,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: Wrap(
                  spacing: 10.0, // Horizontal space between items
                  runSpacing: 10.0, // Vertical space between lines
                  children: List.generate(
                    pdfFiles.length,
                    (index) {
                      final num = index + 1;
                      return InkWell(
                        onTap: () async {
                          if (!isDownloading) {
                            setState(() {
                              selectedPayslip = index;
                            });
                          }
                        },
                        child: Text(
                          "${"payslip_page.title".tr()} $num",
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                            fontWeight: selectedPayslip == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: selectedPayslip == index
                                ? Colors.blue
                                : Colors.black38,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: currentFile().isNotEmpty,
            child: Expanded(
              child: currentFile().isNotEmpty && currentFile()['type'] == 'url'
                  ? SfPdfViewer.network(
                      '$baseUrl/mobile-api/?_method=bc.viewPayslip&filename=${currentFile()['filename']}&_version=$appVersion',
                      headers: {
                        "Authorization": "Bearer $token",
                        "User-Agent": deviceOsVersion
                      },
                    )
                  : SfPdfViewer.file(
                      File(currentFile()['filename']),
                      key: Key("$selectedPayslip"),
                      onDocumentLoadFailed: (details) {
                        showSnackBar(
                          context,
                          "File is unable to load!",
                          isSuccess: false,
                        );
                      },
                    ),
            ),
          ),
          Visibility(
            visible: pdfFiles.isEmpty,
            child: const Center(
              child: Text(
                "File does not exist yet and cannot be displayed.",
                textScaler: TextScaler.noScaling,
              ),
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
          payslip!.month.tr(),
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
            margin: const EdgeInsets.only(top: 19, left: 5.0),
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
          if (isDownloading)
            Text(
              "payslip_page.pdf_view_page.right action label downloading".tr(),
              textScaler: TextScaler.noScaling,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            Visibility(
              visible: currentFile().isNotEmpty,
              child: InkWell(
                onTap: () {
                  if (currentFile().isNotEmpty &&
                      currentFile()['type'] != 'url') {
                    _openFile(selectedPayslip);
                  } else {
                    _downloadFile();
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 2.5, right: 5.0),
                  child: Text(
                    currentFile()['type'] != 'url'
                        ? "payslip_page.pdf_view_page.right action label view file"
                            .tr()
                        : "payslip_page.pdf_view_page.right action label download"
                            .tr(),
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      shadows: [
                        Shadow(color: Colors.blue, offset: Offset(0, -2))
                      ],
                      color: Colors.transparent,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
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

  void _openFile(no) async {
    if (pdfFiles[no].isNotEmpty) {
      bool validFile = true;
      final readFile =
          File(pdfFiles[no]['filename']).openRead().handleError((e) {
        validFile = false;
      });
      await for (final _ in readFile) {}
      if (!validFile) {
        return showDownloadConfirmation(context);
      }
      OpenFile.open(pdfFiles[no]['filename']);
    }
  }

  Future<void> _downloadFile({redownload = false}) async {
    if (!inited) return;
    if (isDownloading) return;
    if (pdfFiles.isEmpty) return;
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
      final cFile = currentFile();
      if (cFile.isEmpty) return;
      String fileName = cFile['filename'];
      // Get the external storage directory for the app.
      Directory? appDocDir = await (Platform.isAndroid
          ? getDownloadsDirectory()
          : getApplicationDocumentsDirectory());
      String savePath = "${appDocDir!.path}/$fileName";
      if (redownload) {
        savePath = fileName;
        fileName = fileName.replaceAll("${appDocDir.path}/", "");
        File f = File(savePath);
        if (await f.exists()) {
          f.rename("${appDocDir.path}/tmp_$fileName");
        }
      }
      // Download the file and save it to the path.
      bool success = true;
      await dio.download(
        "$baseUrl/mobile-api/",
        savePath,
        queryParameters: {
          "_method": "bc.downloadPayslip",
          "filename": fileName,
          "_version": appVersion
        },
        options: Options(
          headers: Map.from({
            'Authorization': "Bearer $token",
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
      );

      if (!success) {
        if (redownload) {
          // revert filename
          File f = File("${appDocDir.path}/tmp_$fileName");
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
            File f = File("${appDocDir.path}/tmp_$fileName");
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
        List<Map<String, dynamic>> newFiles = pdfFiles.map((it) {
          if (it['index'] == selectedPayslip) {
            it['type'] = 'directory';
            it['filename'] = savePath;
          }
          return it;
        }).toList();
        setState(() {
          pdfFiles = newFiles;
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
