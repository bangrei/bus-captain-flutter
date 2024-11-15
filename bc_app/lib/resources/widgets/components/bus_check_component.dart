import 'dart:io';

import 'package:bc_app/app/controllers/api_controller.dart';
import 'package:bc_app/app/models/bus_check_response.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:bc_app/resources/widgets/components/input_text_area_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class BusCheckComponent extends StatefulWidget {
  final TextEditingController remarkController;
  final Function(bool) radioChanged;
  final Function(String) remarkChanged;
  final Function(File?, String? path) pickImage1;
  final Function(File?, String? path) pickImage2;
  final Function(bool) isLoadingImage1;
  final Function(bool) isLoadingImage2;
  final BusCheckResponse log;

  const BusCheckComponent({
    super.key,
    required this.remarkController,
    required this.radioChanged,
    required this.remarkChanged,
    required this.pickImage1,
    required this.pickImage2,
    required this.isLoadingImage1,
    required this.isLoadingImage2,
    required this.log,
  });

  @override
  State<BusCheckComponent> createState() => _BusCheckComponentState();
}

class _BusCheckComponentState extends State<BusCheckComponent> {
  bool _isLoading1 = false;
  bool _isLoading2 = false;
  ApiController apiController = ApiController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Radio<bool?>(
            value: true,
            groupValue: widget.log.checked,
            toggleable: true,
            onChanged: (bool? value) {
              widget.radioChanged(value ?? true);
            },
            visualDensity:
                const VisualDensity(horizontal: -4.0, vertical: -4.0),
          ),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        widget.log.description,
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: InputTextArea(
                        label: '',
                        placeholder: 'Enter your remarks',
                        textarea: true,
                        controller: widget.remarkController,
                        onChanged: (String rm) {
                          widget.remarkChanged(rm);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        _isLoading1
                            ? const Center(child: CircularProgressIndicator())
                            : widget.log.attachment1 != null
                                ? Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.blue,
                                          ),
                                        ),
                                        width: 60,
                                        height: 60,
                                        child:
                                            Image.file(widget.log.attachment1!),
                                      ),
                                      Positioned(
                                        right: -15,
                                        top: -10,
                                        child: IconButton(
                                          onPressed: () async {
                                            await apiController
                                                .removeBusCheckAttachment(
                                              context: context,
                                              path: widget.log.attachmentPath1!,
                                            );
                                            widget.pickImage1(null, null);
                                          },
                                          icon: const Icon(Icons.close),
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  )
                                : GestureDetector(
                                    onTap: () async {
                                      await showSourceOptions(context, 1,
                                          (File? file) async {
                                        if (file != null) {
                                          final path = await apiController
                                              .uploadBusCheckAttachment(
                                            context: context,
                                            attachment: file,
                                          );
                                          if (path.isEmpty) {
                                            widget.pickImage1(null, "");
                                          } else {
                                            widget.pickImage1(file, path);
                                          }
                                        } else {
                                          widget.pickImage1(file, "");
                                        }
                                      }, (bool isLoading1, bool isLoading2) {
                                        widget.isLoadingImage1(isLoading1);
                                        widget.isLoadingImage2(isLoading2);
                                      });
                                    },
                                    child: const SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: Icon(
                                        Icons.camera_alt,
                                      ),
                                    ),
                                  ),
                        const SizedBox(height: 8),
                        _isLoading2
                            ? const Center(child: CircularProgressIndicator())
                            : widget.log.attachment2 != null
                                ? Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.blue,
                                          ),
                                        ),
                                        width: 60,
                                        height: 60,
                                        child:
                                            Image.file(widget.log.attachment2!),
                                      ),
                                      Positioned(
                                        right: -15,
                                        top: -10,
                                        child: IconButton(
                                          onPressed: () async {
                                            await apiController
                                                .removeBusCheckAttachment(
                                              context: context,
                                              path: widget.log.attachmentPath2!,
                                            );
                                            widget.pickImage2(null, null);
                                          },
                                          icon: const Icon(Icons.close),
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  )
                                : GestureDetector(
                                    onTap: () async {
                                      await showSourceOptions(context, 2,
                                          (File? file) async {
                                        if (file != null) {
                                          final path = await apiController
                                              .uploadBusCheckAttachment(
                                            context: context,
                                            attachment: file,
                                          );
                                          if (path.isEmpty) {
                                            widget.pickImage2(null, "");
                                          } else {
                                            widget.pickImage2(file, path);
                                          }
                                        } else {
                                          widget.pickImage2(file, "");
                                        }
                                      }, (bool isLoading1, bool isLoading2) {
                                        widget.isLoadingImage1(isLoading1);
                                        widget.isLoadingImage2(isLoading2);
                                      });
                                    },
                                    child: const SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: Icon(Icons.camera_alt),
                                    ),
                                  ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pickImage(
      {required BuildContext context,
      required int componentNum,
      String source = "gallery",
      required Function(File?) callback,
      required Function(bool, bool) imageLoadingCallback}) async {
    try {
      setState(() {
        if (componentNum == 1) {
          _isLoading1 = true;
        }
        if (componentNum == 2) {
          _isLoading2 = true;
        }
      });
      imageLoadingCallback(_isLoading1, _isLoading2);
      await ImagePicker()
          .pickImage(
              source:
                  source == "camera" ? ImageSource.camera : ImageSource.gallery)
          .then((value) async {
        if (value == null) return callback(null);
        File imageTemp = File(value.path);
        imageTemp = await compute(compressImage, imageTemp);
        callback(imageTemp);
      });
      setState(() {
        if (componentNum == 1) {
          _isLoading1 = false;
        }
        if (componentNum == 2) {
          _isLoading2 = false;
        }
      });
      imageLoadingCallback(_isLoading1, _isLoading2);
    } on PlatformException catch (e) {
      final msg = 'Failed to pick image: $e';
      showSnackBar(context, msg);
      callback(null);
    }
  }

  Future showSourceOptions(
      BuildContext context,
      int componentNum,
      Function(File?) callbackResult,
      Function(bool, bool) isLoadingCallback) async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text(
              'Photo Gallery',
              textScaler: TextScaler.noScaling,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              pickImage(
                  context: context,
                  componentNum: componentNum,
                  callback: (File? file) {
                    callbackResult(file);
                  },
                  imageLoadingCallback: (bool isLoading1, bool isLoading2) {
                    isLoadingCallback(isLoading1, isLoading2);
                  });
            },
          ),
          CupertinoActionSheetAction(
            child: const Text(
              'Camera',
              textScaler: TextScaler.noScaling,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              pickImage(
                  context: context,
                  componentNum: componentNum,
                  source: 'camera',
                  callback: (File? file) {
                    callbackResult(file);
                  },
                  imageLoadingCallback: (bool isLoading1, bool isLoading2) {
                    isLoadingCallback(isLoading1, isLoading2);
                  });
            },
          ),
        ],
      ),
    );
  }
}
