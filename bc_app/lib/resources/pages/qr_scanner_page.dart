import 'dart:async';
import 'dart:io' show Platform;

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/bus_check_item.dart';
import 'package:bc_app/resources/pages/choose_bus_page.dart';
import 'package:bc_app/resources/pages/end_of_trip_tasks_page.dart';
import 'package:bc_app/resources/pages/parade_tasks_page.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanner extends NyStatefulWidget {
  static const path = '/qrview';

  QRScanner({super.key}) : super(path, child: _QRScannerState());
}

class _QRScannerState extends NyState<QRScanner> with WidgetsBindingObserver {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? qrCodeResult;
  QRViewController? controller;
  bool isNavigated = false;
  ApiController apiController = ApiController();

  StreamSubscription<Object?>? _subscription;
  final MobileScannerController galleryController = MobileScannerController(
    autoStart: false,
  );
  String task = '';
  bool needReturnBack = false;

  @override
  init() async {
    super.init();
    WidgetsBinding.instance.addObserver(this);
    _subscription = galleryController.barcodes.listen(_handleBarcode);
  }

  @override
  boot() {
    final data = widget.data();
    setState((){
      task = data['task'];
      needReturnBack = data['needReturnBack'] ?? false;
    });
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!galleryController.value.isInitialized) {
      return;
    }
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        _subscription = galleryController.barcodes.listen(_handleBarcode);
        unawaited(galleryController.start());
      case AppLifecycleState.inactive:
        unawaited(galleryController.stop());
        unawaited(_subscription?.cancel());
        _subscription = null;
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
    unawaited(controller?.stopCamera());
    controller?.dispose();
    unawaited(
        galleryController.stop().then((value) => galleryController.dispose()));
  }

  void _handleBarcode(BarcodeCapture capture) async {
    if (mounted) {
      setState(() {
        qrCodeResult = capture.barcodes.firstOrNull!.rawValue;
      });
      await retrieveTasks();
    }
  }

  retrieveTasks() async {
    setLoading(true, name: 'retrieving_tasks');
    final res =
        await apiController.startBusCheck(context, "taskName", qrCodeResult);
    setLoading(false, name: 'retrieving_tasks');
  }

  scanGallery() async {
    if (isLoading(name: 'scanning')) return;
    unawaited(controller?.pauseCamera());
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );
    unawaited(controller?.resumeCamera());
    setLoading(true, name: 'scanning');
    if (image == null) {
      setLoading(false, name: 'scanning');
      return;
    }

    final BarcodeCapture? capture = await galleryController.analyzeImage(
      image.path,
    );
    if (capture != null) {
      setState(() {
        qrCodeResult = capture.barcodes.firstOrNull!.rawValue;
      });
      finishScan();
    } else {
      setLoading(false, name: 'scanning');
      showSnackBar(
        context,
        'qr_page.invalid qr'.tr(),
        isSuccess: false,
      );
    }
  }

  void finishScan() async {
    setLoading(false, name: 'scanning');
    if (qrCodeResult!.isNotEmpty && !isNavigated) {
      unawaited(controller?.stopCamera());
      isNavigated = true;
      // Navigator.pop(context, qrCodeResult);
      String value = qrCodeResult!;
      if (needReturnBack) {
        pop(result: qrCodeResult);
        return;
      }
      setLoading(true, name: 'onLoading');
      final res = await apiController.startBusCheck(
        context,
        task,
        value,
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
      String path = ParadeTasksPage.path;
      if (task == "End of Trip Tasks") {
        path = EndOfTripTasksPage.path;
      }
      final List<BusCheckItem> checklist = res['checklist'] ?? [];
      Navigator.pushReplacementNamed(
        context,
        path,
        arguments: {
          "result": value,
          "taskName": task,
          "checklist": checklist.toList(),
          "bus": res['bus']
        },
      );
    }
  }

  void _onQRViewCreated(QRViewController controller) async {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrCodeResult = scanData.code;
      });
      finishScan();
    });
  }

  // 

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: screenHeight,
            width: screenWidth,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.white,
                borderWidth: 8.0,
                borderRadius: 8.0,
              ),
            ),
          ),
          SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: Padding(
              padding: const EdgeInsets.only(top: 48.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                        iconSize: 24.0,
                        onPressed: () {
                          dispose();
                          Navigator.of(context).pop();
                        },
                      ),
                      Visibility(
                        visible: true,
                        child: IconButton(
                          icon: const Icon(Icons.create_rounded),
                          color: Colors.white,
                          iconSize: 20.0,
                          onPressed: () async{
                            // Ensure the camera is properly stopped before navigating
                            dispose();
                            routeTo(
                              ChooseBusPage.path, 
                              navigationType: NavigationType.popAndPushNamed,
                              data: {'task': task}
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 24.0),
                        child: GestureDetector(
                          onTap: scanGallery,
                          child: Text(
                            'qr_page.album'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: "Poppins",
                              fontSize: 16.0,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 48.0),
                    child: Text(
                      isLoading(name: 'scanning') ? "" : "qr_page.scan qr".tr(),
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
