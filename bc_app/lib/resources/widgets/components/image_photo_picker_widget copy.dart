import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nylo_framework/nylo_framework.dart';


class ImagePhotoPicker extends StatefulWidget {
  final String label;
  final bool? required;
  final String? value;

  const ImagePhotoPicker({
    Key? key,
    required this.label,
    this.required = false,
    this.value = '',
  }) : super(key: key);

  @override
  _ImagePhotoPickerState createState() => _ImagePhotoPickerState();
}

class _ImagePhotoPickerState extends State<ImagePhotoPicker> {
  List<XFile>? _mediaFileList;

  void _setImageFileListFromFile(XFile? value) {
    _mediaFileList = value == null ? null : <XFile>[value];
  }

  dynamic _pickImageError;

  final ImagePicker _picker = ImagePicker();


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              textScaler: TextScaler.noScaling,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Builder(builder: (context) {
              if (widget.required!) {
                return Text(
                  "*${"user_profile.driving_license_screen.required".tr()}",
                  textScaler: TextScaler.noScaling,
                  style:
                      const TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
                );
              }
              return const SizedBox();
            })
          ],
        ),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            color: nyHexColor("F4F5F6"),
            border: Border.all(
              color: Colors.grey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                GestureDetector(
                  child: Column(
                    children: [
                      Icon(Icons.photo_library_rounded,
                          color: nyHexColor("#9E9E9E")),
                      Text("user_profile.driving_license_screen.photo lib".tr(),
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                              color: nyHexColor("#9E9E9E"),
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                        child:
                            Container(height: 1, color: nyHexColor("#EEEEEE"))),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 20, 16, 20),
                      child: Text("or", textScaler: TextScaler.noScaling,),
                    ),
                    Expanded(
                        child:
                            Container(height: 1, color: nyHexColor("#EEEEEE"))),
                  ],
                ),
                GestureDetector(
                  child: Column(
                    children: [
                      Icon(Icons.photo_camera_rounded,
                          color: nyHexColor("#9E9E9E")),
                      Text(
                          "user_profile.driving_license_screen.take photo".tr(),
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                              color: nyHexColor("#9E9E9E"),
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20.0)
      ],
    );
  }
}
