import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bc_app/app/events/login_event.dart';
import 'package:bc_app/app/models/bus_check_response.dart';
import 'package:bc_app/bootstrap/helpers.dart';
import 'package:bc_app/resources/pages/login_page.dart';
import 'package:bc_app/resources/widgets/components/button_widget.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:upgrader/upgrader.dart';


Future<String> getAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

getDeviceOsVersion() async {
  String ret = '';
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    var androidInfo = await DeviceInfoPlugin().androidInfo;

    var release = androidInfo.version.release;
    var sdkInt = androidInfo.version.sdkInt;

    ret = 'Android $release (SDK $sdkInt)';
  }

  if (Platform.isIOS) {
    var iosInfo = await DeviceInfoPlugin().iosInfo;

    var systemName = iosInfo.systemName;
    var version = iosInfo.systemVersion;

    ret = '$systemName $version';
  }

  // debugPrint(ret);
  return ret;
}

void showSnackBar(BuildContext context, String content,
    {bool isSuccess = true}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      backgroundColor: isSuccess ? Colors.green[300] : Colors.red[300],
      content: ListTile(
        contentPadding: const EdgeInsets.all(3.0),
        leading: isSuccess
            ? const Icon(Icons.check_circle_outline, color: Colors.white)
            : const Icon(Icons.warning_amber, color: Colors.white),
        title: Text(
          content,
          textScaler: TextScaler.noScaling,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            // fontFamily: 'Poppins-Bold'
          ),
        ),
      ),
    ),
  );
}

void displayDialog(
    {required BuildContext context,
    required Widget? headerWidget,
    required Widget? bodyWidget,
    String? buttonLabel,
    Function? buttonOnPressed}) {
  showDialog(
    useSafeArea: true,
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: ThemeColor.get(context).background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.0),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0,
                  0.0), // Adjust padding to reduce space around the "X" button
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align content to start
                children: <Widget>[
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      padding: EdgeInsets
                          .zero, // Remove additional padding around the icon
                      icon: Icon(Icons.close, color: nyHexColor("#D8D8D8")),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 14.0, right: 14.0, bottom: 14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        headerWidget!,
                        const SizedBox(
                            height:
                                16.0), // Space between the title and content
                        bodyWidget!,
                      ],
                    ),
                  ),
                  if (buttonLabel != null)
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: GeneralButton(
                            text: buttonLabel,
                            onPressed: () {
                              if (buttonOnPressed != null) {
                                buttonOnPressed();
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 20)
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<String> convertFileToStringBase64(File? file) async {
  if (file == null) return "";
  List<int> bytes = await file.readAsBytes();
  String base64String = base64.encode(bytes);
  return base64String;
}

Future<File?> convertUrlToFile(String url) async {
  if (url.isNotEmpty) {
    Directory? appDocDir = await getDownloadsDirectory();
    Uri uri = Uri.parse(url);
    String fileName = uri.pathSegments.last;
    String savePath = "${appDocDir!.path}/$fileName";
    File file = File(savePath);
    if (await file.exists()) {
      return file;
    }
  }
  return null;
}

String dateFormatString(
  String date, {
  String fromFormat = 'dd MMM yyyy',
  String toFormat = 'yyyy-MM-dd',
}) {
  if (date.isEmpty) return "";
  // Added 'en' because intl.dart check for locale settings
  // This app uses customized local settings
  // To avoid error, set date format to follow English formatting
  DateTime r = DateFormat(fromFormat).parse(date);
  return DateFormat(toFormat).format(r);
}

DateTime? toDatetime(String date, {String format = 'yyyy-MM-dd'}) {
  if (date.isEmpty) return null;
  return DateFormat(format).parse(date);
}

selectLeaveStatusColor(String? status) {
  if (status == "Pending") return const Color(0xFFF59F00);
  if (status == "Approved") return const Color(0xFF2FB344);
  if (status == "Rejected") return const Color(0xFF667382);
  if (status == "Cancelled") return const Color(0xFF182433);
  return const Color(0xFFCCCCCC);
}

Color getUniformStatusColor(type) {
  if (type == 'Pending') return const Color.fromRGBO(245, 159, 0, 1);
  if (type == 'Ready for Collection') {
    return const Color.fromRGBO(66, 153, 225, 1);
  }
  if (type == 'Collected') return const Color.fromRGBO(47, 179, 68, 1);
  if (type == 'Cancelled') return const Color.fromRGBO(24, 36, 51, 1);
  if (type == 'Emailed') return const Color.fromRGBO(174, 62, 201, 1);
  return const Color.fromRGBO(245, 159, 0, 1);
}

Color getBusChecklistStatusColor(type) {
  if (type == 'Pending') {
    return const Color(0xFFFD9843);
  }
  if (type == 'Acknowledged') {
    return const Color(0xFF479F76);
  }
  if (type == 'Approved') {
    return const Color(0xFF479F76);
  }
  return const Color(0xFFFD9843);
}

Color getHazardReportStatusColor(String status) {
    switch (status) {
      case "open":
        return const Color(0xFFD63939);
      case "in progress":
        return const Color(0xFFF59f00);
      case "completed":
        return const Color(0XFF74B816);
      case "closed":
        return const Color(0xFF0CA678);
      default:
        return Colors.grey;
    }
  }

String datesWithDuration(String from, String to, {bool withDuration = true, String format = 'dd MMM yyyy'}) {
  DateTime? f = toDatetime(from);
  DateTime? t = toDatetime(to);
  if (f == null || t == null) return "-";
  final diff = t.difference(f).abs().inDays + 1;
  String days = "day";
  if (diff > 1) days += "s";
  final ds = diff.toString();
  final d1 = dateFormatString(
    from,
    fromFormat: 'yyyy-MM-dd',
    toFormat: format,
  );
  final d2 = dateFormatString(
    to,
    fromFormat: 'yyyy-MM-dd',
    toFormat: format,
  );
  if (withDuration) return "$d1 - $d2 ($ds $days)";
  return "$d1 - $d2";
}

  DateTime parsedDate(String format, String dateString) {
    return DateFormat(format).parse(dateString);
  }

  String getFormattedDate(DateTime date, String enFormat, String zhFormat, String langPref) {
    if (langPref == 'en') {
      return DateFormat(enFormat, langPref).format(date);
    } else if (langPref == 'zh') {
      return  DateFormat(zhFormat, langPref).format(date);
    }
    return DateFormat(enFormat).format(date); // Fallback for other locales
  }

String stringifyDate(dynamic date, {format = 'yyyy-MM-dd'}) {
  if (date == null) return "";

  // Create a DateFormat with the specified format and set locale to 'en'
  if (date is DateTime) {
    return DateFormat(format).format(date);
  } else if (date is DateTimeRange) {
    return "${DateFormat(format).format(date.start)} , ${DateFormat(format).format(date.end)}";
  }

  throw ArgumentError(
      "Invalid type for parameter 'time'. Must be of type DateTime or DateTimeRange.");
}

Future<bool> apiResHandler(BuildContext ctx, dynamic json) async {
  if (json.isEmpty) {
    showSnackBar(
      ctx,
      'snackbar.network issue'.tr(),
      isSuccess: false,
    );
    return Future.value(false);
  }
  bool res = json['success'] == true;
  if (json['error'] == 102) {
    await NyStorage.delete('authToken');
    await Auth.remove();
    // Stop Cron :
    await event<LoginEvent>(data: {"runCronJob": false});
    Navigator.pushNamedAndRemoveUntil(
      ctx,
      LoginPage.path,
      (route) => false,
    );
  }
  if (!res) {
    showSnackBar(
      ctx,
      json['message'] ?? 'Something went wrong!',
      isSuccess: false,
    );
  }
  return Future.value(res);
}

String requestTypeToString(dynamic requestType) {
  final Map<int, String> requestTypeMap = {
    0: 'Entitlement',
    1: 'Line Manager Approved',
    2: 'BC Pay',
  };
  return requestTypeMap[requestType]!;
}

Future<File> compressImage(File image) async {
  img.Image rotatedImg = await fixOrientation(image);

  int fileSizeLimit = 1024 * 1024 * 2;
  int quality = 100;

  List<int> encodedBytes = img.encodeJpg(rotatedImg, quality: 100);

  while (encodedBytes.length > fileSizeLimit && quality > 0) {
    quality -= 5;
    encodedBytes = img.encodeJpg(rotatedImg, quality: quality);
  }

  File compressedImageFile = File(image.path);
  compressedImageFile.writeAsBytesSync(encodedBytes);

  return compressedImageFile;
}

Future<img.Image> fixOrientation(File imageFile) async {
  // Read the image data
  final bytes = await imageFile.readAsBytes();

  // Read the EXIF data
  final tags = await readExifFromBytes(bytes);

  // Decode the image
  img.Image image = img.decodeImage(bytes)!;

  //No need to rotate if it's coming from iOS
  if (Platform.isIOS) {
    return image;
  }

  if (tags.isEmpty || !tags.containsKey('Image Orientation')) {
    return image;
  }

  // Get the orientation value
  int orientation = tags['Image Orientation']?.values.firstAsInt() ?? 1;

  switch (orientation) {
    case 3:
      image = img.copyRotate(image, 180);
      break;
    case 6:
      image = img.copyRotate(image, 90);
      break;
    case 8:
      image = img.copyRotate(image, -90);
      break;
  }

  return image;
}

myBCDelarations() async {
  final declares = await NyStorage.readCollection('bcDeclarations');
  List<BusCheckResponse> declarationChecklist = declares.toList().map((it) {
    final map = {
      'id': int.parse(it['id'].toString()),
      'task': int.parse(it['taskId'].toString()),
      'type': it['type'].toString(),
      'description': it['description'].toString(),
      'serialNo': int.parse(it['serialNo'].toString()),
      'tag': it['tag'].toString(),
      'checked': bool.parse(it['checked'].toString()),
      'attachment1': null,
      'attachment2': null,
      'remarks': it['remarks'].toString(),
    } as Map<String, dynamic>;
    return BusCheckResponse.fromMap(map);
  }).toList();
  return declarationChecklist;
}

RegExp allowedInputTextPattern() {
  // return RegExp(r'[a-zA-Z0-9!&*,.? \u4e00-\u9fff]');
  return RegExp(r'[^\u0000-\u007F\u4e00-\u9fff\s]');
}

Upgrader initializedUpgrader(String langPref) {
  bool isDebugMode = getEnv('APP_DEBUG') == true ? true : false;
  return Upgrader(
      languageCode: langPref, 
      debugLogging: isDebugMode,
      durationUntilAlertAgain:  const Duration(milliseconds: 1),
      // debugDisplayAlways: isDebugMode,
    );
}
