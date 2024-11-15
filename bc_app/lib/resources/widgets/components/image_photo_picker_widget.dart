import 'dart:async';
import 'dart:io';

import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter/foundation.dart';


class PhotoPicker extends StatefulWidget {
  const PhotoPicker({
    super.key,
    this.label,
    this.preImage,
    this.required = false,
    required this.callback,
  });

  final String? label;
  final String? preImage;
  final bool? required;
  final Future<void> Function(File?)? callback;

  @override
  State<PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  File? image;
  String? preImage;
  bool _isLoading= false;

  Future pickImage(BuildContext context) async {
    try {
      setState(() => _isLoading = true);
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image == null) {
        setState(() => _isLoading = false);
        return;
      }

      File imageTemp = File(image.path);
      imageTemp = await compute(compressImage, imageTemp);

      await widget.callback!(imageTemp);

      setState(() => this.image = imageTemp);
      setState(() => _isLoading = false);
    } on PlatformException catch (e) {
      final msg = 'Failed to pick image: $e';
      showSnackBar(context, msg);
    }
  }

  Future pickImageCamera(BuildContext context) async {
    try {
      setState(() => _isLoading = true);
      final image = await ImagePicker().pickImage(source: ImageSource.camera);

      if (image == null) {
        setState(() => _isLoading = false);
        return;
      }

      File imageTemp = File(image.path);
      imageTemp = await compute(compressImage, imageTemp);

      await widget.callback!(imageTemp);

      setState(() => this.image = imageTemp);
      setState(() => _isLoading = false);
    } on PlatformException catch (e) {
      final msg = 'Failed to pick image: $e';
      showSnackBar(context, msg);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.preImage != null) {
      setState(() {
        preImage = widget.preImage!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label!,
                textScaler: TextScaler.noScaling,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Builder(builder: (context) {
                if (widget.required!) {
                  return Text(
                    "*${"user_profile.driving_license_screen.required".tr()}",
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  );
                }
                return const SizedBox();
              })
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            color: ThemeColor.get(context).photoPickerBox,
            border: Border.all(
              color: Colors.grey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Builder(builder: (context) {
            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (image != null || preImage != null) {
              return Stack(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: preImage != null
                      ? Image.network(preImage!)
                      : Image.file(image!),
                ),
                Positioned(
                  right: -5,
                  child: IconButton(
                    onPressed: () async{
                      await widget.callback!(null);
                      setState(() {
                        image = null;
                        preImage = null;
                      });
                    },
                    icon: const Icon(Icons.close),
                    color: Colors.grey,
                  ),
                )
              ]);
            } else {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        pickImage(context);
                      },
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_library_rounded,
                            color: nyHexColor("#9E9E9E"),
                          ),
                          Text(
                            "user_profile.driving_license_screen.photo lib"
                                .tr(),
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                              color: nyHexColor("#9E9E9E"),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: nyHexColor("#EEEEEE"),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 20, 16, 20),
                          child: Text("or", textScaler: TextScaler.noScaling,),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: nyHexColor("#EEEEEE"),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        pickImageCamera(context);
                      },
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_camera_rounded,
                            color: nyHexColor("#9E9E9E"),
                          ),
                          Text(
                            "user_profile.driving_license_screen.take photo"
                                .tr(),
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                              color: nyHexColor("#9E9E9E"),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
        ),
        const SizedBox(height: 20.0)
      ],
    );
  }
}
