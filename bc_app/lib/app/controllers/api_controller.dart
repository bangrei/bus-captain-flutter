import 'dart:convert';
import 'dart:io';

import 'package:bc_app/app/models/broadcast_message.dart';
import 'package:bc_app/app/models/bus_check_history.dart';
import 'package:bc_app/app/models/bus_check_item.dart';
import 'package:bc_app/app/models/bus_check_response.dart';
import 'package:bc_app/app/models/document_file.dart';
import 'package:bc_app/app/models/document_folder.dart';
import 'package:bc_app/app/models/driving_performance_events.dart';
import 'package:bc_app/app/models/driving_performance_monthly.dart';
import 'package:bc_app/app/models/duty_roster.dart';
import 'package:bc_app/app/models/hazard_report.dart';
import 'package:bc_app/app/models/leave_request.dart';
import 'package:bc_app/app/models/notifications_message.dart';
import 'package:bc_app/app/models/payslip.dart';
import 'package:bc_app/app/models/uniform_request.dart';
import 'package:bc_app/config/constants.dart';
import 'package:bc_app/resources/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http_parser/http_parser.dart';
import 'package:nylo_framework/nylo_framework.dart';

import 'controller.dart';

class ApiController extends Controller {
  onLoginOTP(
    String username,
    String password,
  ) async {
    try {
      await NyStorage.delete('authToken');
      final payload = {
        "username": username,
        "password": password,
        "_method": Constants.isDummyAPI ? "dummy.login" : "bc.login",
        "_version": await getAppVersion()
      } as Map;
      return await apiService.postRequest(payload);
    } catch (e) {
      return jsonEncode({'success': false, 'message': e.toString()});
    }
  }

  onVerifyLogin(
    String username,
    String otp,
    String auth,
  ) async {
    try {
      final payload = {
        "username": username,
        "otp": otp,
        "_method":
            Constants.isDummyAPI ? "dummy.verifyLogin" : "bc.verifyLogin",
        "_version": await getAppVersion()
      } as Map;
      return await apiService.postRequest(payload, auth: auth);
    } catch (e) {
      return jsonEncode({'success': false, 'message': e.toString()});
    }
  }

  onForgotPasswordOTP(
    String username,
    String mobile,
  ) async {
    try {
      final payload = {
        "username": username,
        "mobile": mobile,
        "_method":
            Constants.isDummyAPI ? "dummy.forgotPassword" : "bc.forgotPassword",
        "_version": await getAppVersion()
      } as Map;
      return await apiService.postRequest(payload);
    } catch (e) {
      return jsonEncode({'success': false, 'message': e.toString()});
    }
  }

  onVerifyForgotPassword(
    String username,
    String otp,
    String auth,
  ) async {
    try {
      final payload = {
        "username": username,
        "otp": otp,
        "_method": Constants.isDummyAPI
            ? "dummy.verifyForgotPassword"
            : "bc.verifyForgotPassword",
        "_version": await getAppVersion()
      } as Map;
      return await apiService.postRequest(payload, auth: auth);
    } catch (e) {
      return jsonEncode({'success': false, 'message': e.toString()});
    }
  }

  onUpdatePassword(
    String username,
    String password,
    String confirmPassword,
    String otp,
    String auth,
  ) async {
    try {
      final payload = {
        "username": username,
        "password": password,
        "confirmPassword": confirmPassword,
        "otp": otp,
        "_method":
            Constants.isDummyAPI ? "dummy.updatePassword" : "bc.updatePassword",
        "_version": await getAppVersion()
      } as Map;
      return await apiService.postRequest(payload, auth: auth);
    } catch (e) {
      return jsonEncode({'success': false, 'message': e.toString()});
    }
  }

  onChangeMyPassword(
    String currentPassword,
    String password,
    String confirmPassword,
  ) async {
    try {
      final payload = {
        "currentPassword": currentPassword,
        "password": password,
        "confirmPassword": confirmPassword,
        "_method": Constants.isDummyAPI
            ? "dummy.changeMyPassword"
            : "bc.changeMyPassword",
        "_version": await getAppVersion()
      } as Map;
      return await apiService.postRequest(payload);
    } catch (e) {
      return jsonEncode({'success': false, 'message': e.toString()});
    }
  }

  getProfile() async {
    try {
      final payload = {
        "_method": Constants.isDummyAPI ? "dummy.profile" : "bc.profile",
        "_version": await getAppVersion()
      } as Map<String, dynamic>;
      return await apiService.getRequest(payload);
    } catch (e) {
      return jsonEncode({'success': false, 'message': e.toString()});
    }
  }

  updateLanguagePref({required String langPref, String? token}) async {
    try {
      final payload = {
        "_method":
            Constants.isDummyAPI ? "dummy.updateLangPref" : "bc.updateLangPref",
        "langPref": langPref,
        "_version": await getAppVersion()
      } as Map;

      return await apiService.postRequest(payload, authToken: token ?? "");
    } catch (e) {
      return jsonEncode({'success': false, 'message': e.toString()});
    }
  }

  onRenewDrivingLicense({
    required String expiryDate,
    required String issueDate,
    File? imgFront,
    File? imgBack,
    required List<int> licenseIds,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "expiryDate": expiryDate,
        "issueDate": issueDate,
        "licenseIds": licenseIds.join(","),
        "_method": Constants.isDummyAPI
            ? "dummy.saveDrivingLicense"
            : "bc.saveDrivingLicense",
        "_version": await getAppVersion()
      });

      if (imgFront != null) {
        final img = await MultipartFile.fromFile(imgFront.path,
            contentType: MediaType('image', 'png'));
        // await Future.delayed(const Duration(seconds: 1));
        formData.files.add(
          MapEntry("imgFront", img),
        );
      }
      if (imgBack != null) {
        final img = await MultipartFile.fromFile(imgBack.path,
            contentType: MediaType('image', 'png'));
        // await Future.delayed(const Duration(seconds: 1));
        formData.files.add(
          MapEntry("imgBack", img),
        );
      }

      return await apiService.postFormDataRequest(formData);
    } catch (e) {
      return jsonEncode({'success': false, 'message': e.toString()});
    }
  }

  onLogout() async {
    try {
      final payload = {
        "_method": Constants.isDummyAPI ? "dummy.logout" : "bc.logout",
        "_version": await getAppVersion()
      } as Map;
      return await apiService.postRequest(payload);
    } catch (e) {
      return jsonEncode({'success': false, 'message': e.toString()});
    }
  }

  Future<List<LeaveRequest>> getLeaveRequests(
    BuildContext context,
    String? status,
    String? leaveDate,
    String? applyDate,
  ) async {
    try {
      final payload = {
        "status": status,
        "leaveDate": leaveDate,
        "applyDate": applyDate,
        "_method":
            Constants.isDummyAPI ? "dummy.leaveRequests" : "bc.leaveRequests",
        "_version": await getAppVersion()
      } as Map<String, dynamic>;
      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      if (!success) {
        return Future.value([]);
      }
      final List<Map<String, dynamic>> items =
          List<Map<String, dynamic>>.from((json['leaveRequests'] ?? []));
      final requests = items.toList().map((it) {
        return LeaveRequest.fromMap(it);
      });
      return requests.toList();
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }

  Future<bool> onApplyLeave({
    required BuildContext context,
    required String type,
    required String startDate,
    required String endDate,
    // String? amOrPm,
    String? reason,
    File? attachment,
  }) async {
    try {
      FormData payload = FormData.fromMap({
        "type": type,
        "startDate": startDate,
        "endDate": endDate,
        // "amOrPm": amOrPm,
        "reason": reason,
        "_method": Constants.isDummyAPI ? "dummy.applyLeave" : "bc.applyLeave",
        "_version": await getAppVersion()
      });
      if (attachment != null) {
        final imgs = await MultipartFile.fromFile(attachment.path,
            contentType: MediaType('image', 'jpeg'));
        payload.files.addAll([
          MapEntry("attachment", imgs),
        ]);
      }
      final res = await apiService.postFormDataRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      String message = json['message'] ?? 'Something went wrong!';
      if (success) {
        message = json['message'] ?? 'Your request is successfully submitted!';
        showSnackBar(context, message, isSuccess: success);
      }
      return Future.value(success);
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value(false);
    }
  }

  Future<List<String>> getDrivingLicenseTypes(BuildContext context) async {
    try {
      final payload = {
        "_method": Constants.isDummyAPI
            ? "dummy.getDrivingLicenseTypes"
            : "bc.getDrivingLicenseTypes",
        "_version": await getAppVersion()
      } as Map<String, dynamic>;
      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      if (!success) {
        return Future.value([]);
      }
      final List<String> items =
          List<String>.from((json['licenseTypes'] ?? []));
      return items.toList();
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }

  Future<List<String>> getLeaveTypes(BuildContext context) async {
    try {
      final payload = {
        "_method":
            Constants.isDummyAPI ? "dummy.getLeaveTypes" : "bc.getLeaveTypes",
        "_version": await getAppVersion()
      } as Map<String, dynamic>;
      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      if (!success) {
        return Future.value([]);
      }
      final List<String> items = List<String>.from((json['leaveTypes'] ?? []));
      return items.toList();
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }

  Future<void> cancelLeaveRequest(
      {required BuildContext context, required String requestNo}) async {
    try {
      final payload = {
        "_method": Constants.isDummyAPI
            ? "dummy.cancelLeaveRequest"
            : "bc.cancelLeaveRequest",
        "requestNo": requestNo,
        "_version": await getAppVersion()
      } as Map<String, dynamic>;
      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      if (!success) {
        return;
      }

      showSnackBar(context, json['message']);

      return;
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return;
    }
  }

  Future<Map> getUniformItems(BuildContext context) async {
    try {
      final payload = {
        "_method": Constants.isDummyAPI
            ? "dummy.getUniformItems"
            : "bc.getUniformItems",
        "_version": await getAppVersion()
      } as Map<String, dynamic>;
      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      if (!success) {
        return Future.value({});
      }
      final List<dynamic> items = List<dynamic>.from((json['items'] ?? []));
      final Map entitlementGuide = Map.from(json['entitlement']);
      final map = {
        "items": items.toList(),
        "entitlementGuide": entitlementGuide,
      };
      return map;
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value({});
    }
  }

  Future<bool> onSubmitUniformRequest({
    required BuildContext context,
    required List<dynamic> carts,
    required String pickupLocation,
  }) async {
    try {
      final payload = {
        "pickupLocation": pickupLocation,
        "carts": carts,
        "_method": Constants.isDummyAPI
            ? "dummy.submitUniformRequest"
            : "bc.submitUniformRequest",
        "_version": await getAppVersion()
      } as Map;
      debugPrint(jsonEncode(carts));
      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      String message = json['message'] ?? 'Something went wrong!';
      if (success) {
        message = json['message'] ?? 'Your request is successfully submitted!';
        showSnackBar(context, message, isSuccess: success);
      }
      return Future.value(success);
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value(false);
    }
  }

  Future<List<UniformRequest>> getUniformRequests(
    BuildContext context,
    String? status,
    String? submitDate,
  ) async {
    try {
      final payload = {
        "status": status,
        "submitDate": submitDate,
        "_method": Constants.isDummyAPI
            ? "dummy.uniformRequests"
            : "bc.uniformRequests",
        "_version": await getAppVersion()
      } as Map<String, dynamic>;
      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      if (!success) {
        return Future.value([]);
      }
      final List<Map<String, dynamic>> items =
          List<Map<String, dynamic>>.from((json['uniformRequests'] ?? []));
      final requests = items.toList().map((it) {
        return UniformRequest.fromJson(it);
      });
      return requests.toList();
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }

  Future<void> cancelUniformRequest(
      {required BuildContext context, required int requestId}) async {
    try {
      final payload = {
        "_method": Constants.isDummyAPI
            ? "dummy.cancelUniformRequest"
            : "bc.cancelUniformRequest",
        "requestId": requestId,
        "_version": await getAppVersion()
      } as Map<String, dynamic>;

      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);

      if (!success) {
        return;
      }

      showSnackBar(context, json['message']);

      return;
    } catch (e) {}
  }

  Future<List<DrivingPerformanceMonthly>> getMonthlyDrivingPerformance(
      {required BuildContext context}) async {
    try {
      final payload = {
        "_method": Constants.isDummyAPI
            ? "dummy.monthlyDrivingPerformance"
            : "bc.getMonthlyDrivingPerformance",
        "_version": await getAppVersion()
      };

      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);

      if (!success) {
        return Future.value([]);
      }

      final List<dynamic> monthlyPerformances =
          json['monthlyPerformance'] ?? [];

      final performances = monthlyPerformances.map((mp) {
        // Process performance count
        final Map<String, int> performanceCount =
            Map<String, int>.from(mp['performanceCount'] ?? {});

        // Process events count
        Map<String, int> events = {};
        if (mp['eventsCount'] is Map<String, dynamic>) {
          events = Map<String, int>.from(
            (mp['eventsCount'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, value as int),
            ),
          );
        }

        return DrivingPerformanceMonthly(
          date: mp['date'] ?? '',
          performance: mp['performance'] ?? '',
          performanceCount: performanceCount,
          eventsCount: events,
          interventionStatus: mp['interventionStatus'] ?? '',
        );
      }).toList();

      return performances;
    } catch (e) {
      debugPrint('ERROR!!!');
      debugPrint(e.toString());
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }

  Future<List<DrivingPerformanceEvents>> getEventsDrivingPerformance(
      {required BuildContext context, String? month}) async {
    try {
      final payload = {
        "month": month,
        "_method": Constants.isDummyAPI
            ? "dummy.getMonthlyDrivingPerformanceEvents"
            : "bc.getMonthlyDrivingPerformanceEvents",
        "_version": await getAppVersion()
      };

      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);

      if (!success) {
        return Future.value([]);
      }

      final List<dynamic> monthlyPerformances = json['monthlyPerfEvents'] ?? [];

      final performances = monthlyPerformances.map((mp) {
        // Process events count
        Map<String, int> events = {};
        if (mp['eventOcc'] is Map<String, dynamic>) {
          events = Map<String, int>.from(
            (mp['eventOcc'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, value as int),
            ),
          );
        }

        return DrivingPerformanceEvents(
          date: mp['date'] ?? '',
          performance: mp['performance'] ?? '',
          eventOcc: events,
        );
      }).toList();

      return performances;
    } catch (e) {
      debugPrint('ERROR!!!');
      debugPrint(e.toString());
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>>
      getDrivingPerformanceDailyOccurence({
    required BuildContext context,
    String? date,
  }) async {
    try {
      final payload = {
        "date": date ?? '',
        "_method": Constants.isDummyAPI
            ? "dummy.getDrivingPerformanceDailyOccurence"
            : "bc.getDrivingPerformanceDailyOccurence",
        "_version": await getAppVersion()
      };

      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);

      if (!success) {
        return {
          "detail_events": [],
          "detail_trips": []
        }; // Return empty map if API call was not successful
      }

      // Extract dailyOccurence data safely
      final List<dynamic> eventsJson = json['dailyOccurence']?['events'] ?? [];
      final List<dynamic> tripsJson = json['dailyOccurence']?['trips'] ?? [];

      // Map events and trips to lists of maps
      final List<Map<String, dynamic>> events =
          eventsJson.cast<Map<String, dynamic>>();
      final List<Map<String, dynamic>> trips =
          tripsJson.cast<Map<String, dynamic>>();

      // Return a map containing the lists of events and trips
      return {"detail_events": events, "detail_trips": trips};
    } catch (e) {
      debugPrint('ERROR!!!');
      debugPrint(e.toString());
      showSnackBar(context, e.toString(), isSuccess: false);
      return {"events": [], "trips": []}; // Return empty map on error
    }
  }

  Future<List<Payslip>> getPayslips({
    required BuildContext context,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final payload = {
        "startDate": startDate,
        "endDate": endDate,
        "_method": Constants.isDummyAPI ? "dummy.payslips" : "bc.payslips",
        "_version": await getAppVersion()
      } as Map<String, dynamic>;
      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      if (!success) {
        return Future.value([]);
      }
      final List<Map<String, dynamic>> items =
          List<Map<String, dynamic>>.from((json['payslips'] ?? []));
      final requests = items.toList().map((it) {
        final month = dateFormatString(it['startDate'],
            fromFormat: 'yyyy-MM-dd', toFormat: 'MMM yyyy');
        final yearStart = dateFormatString(it['startDate'],
            fromFormat: 'yyyy-MM-dd', toFormat: 'yyyy');
        final yearEnd = dateFormatString(it['endDate'],
            fromFormat: 'yyyy-MM-dd', toFormat: 'yyyy');
        final year = yearStart == yearEnd ? yearStart : "$yearStart - $yearEnd";
        final range = datesWithDuration(it['startDate'], it['endDate'],
            withDuration: false);
        final filenames = it['filenames'] != ""
            ? List.from(it['filenames']).map((f) {
                return f.toString();
              }).toList()
            : [];

        return Payslip(
          year: year,
          month: month,
          range: range,
          type: it['type'] ?? '',
          payslipCodeName: it['payslipCodeName'] ?? '',
          filenames: filenames.toList() as List<String>,
        );
      });
      return requests.toList();
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }

  Future<List<Payslip>> getAWSBonusPayslips({
    required BuildContext context,
  }) async {
    try {
      final payload = {
        "_method": Constants.isDummyAPI
            ? "dummy.getAWSBonusPayslips"
            : "bc.getAWSBonusPayslips",
        "_version": await getAppVersion()
      } as Map<String, dynamic>;
      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      if (!success) {
        return Future.value([]);
      }
      final List<Map<String, dynamic>> items =
          List<Map<String, dynamic>>.from((json['payslips'] ?? []));
      final requests = items.toList().map((it) {
        final month = dateFormatString(it['startDate'],
            fromFormat: 'yyyy-MM-dd', toFormat: 'MMM yyyy');
        final yearStart = dateFormatString(it['startDate'],
            fromFormat: 'yyyy-MM-dd', toFormat: 'yyyy');
        final yearEnd = dateFormatString(it['endDate'],
            fromFormat: 'yyyy-MM-dd', toFormat: 'yyyy');
        final year = yearStart == yearEnd ? yearStart : "$yearStart - $yearEnd";
        final range = datesWithDuration(it['startDate'], it['endDate'],
            withDuration: false);
        final filenames = it['filename'] != "" ? it['filename'].toString() : '';
        return Payslip(
          year: year,
          month: month,
          range: range,
          type: it['type'] ?? '',
          payslipCodeName: it['payslipCodeName'] ?? '',
          filenames: [filenames],
        );
      });
      return requests.toList();
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }

  Future<List<Payslip>> getCorrectionPayslips({
    required BuildContext context,
  }) async {
    try {
      final payload = {
        "_method": Constants.isDummyAPI
            ? "dummy.getCorrectionPayslips"
            : "bc.getCorrectionPayslips",
        "_version": await getAppVersion()
      } as Map<String, dynamic>;
      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      if (!success) {
        return Future.value([]);
      }
      final List<Map<String, dynamic>> items =
          List<Map<String, dynamic>>.from((json['payslips'] ?? []));
      final requests = items.toList().map((it) {
        final month = dateFormatString(it['startDate'],
            fromFormat: 'yyyy-MM-dd', toFormat: 'MMM yyyy');
        final yearStart = dateFormatString(it['startDate'],
            fromFormat: 'yyyy-MM-dd', toFormat: 'yyyy');
        final yearEnd = dateFormatString(it['endDate'],
            fromFormat: 'yyyy-MM-dd', toFormat: 'yyyy');
        final year = yearStart == yearEnd ? yearStart : "$yearStart - $yearEnd";
        final range = datesWithDuration(it['startDate'], it['endDate'],
            withDuration: false);
        final filenames = it['filename'] != "" ? it['filename'].toString() : '';
        return Payslip(
          year: year,
          month: month,
          range: range,
          type: it['type'] ?? '',
          payslipCodeName: it['payslipCodeName'] ?? '',
          filenames: [filenames],
        );
      });
      return requests.toList();
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }

  Future<List<Payslip>> getIR8eForm({
    required BuildContext context,
  }) async {
    try {
      final payload = {
        "_method":
            Constants.isDummyAPI ? "dummy.getIR8eForm" : "bc.getIR8eForm",
        "_version": await getAppVersion()
      } as Map<String, dynamic>;
      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      if (!success) {
        return Future.value([]);
      }
      final List<Map<String, dynamic>> items =
          List<Map<String, dynamic>>.from((json['forms'] ?? []));
      final requests = items.toList().map((it) {
        final month = dateFormatString(it['startDate'],
            fromFormat: 'yyyy-MM-dd', toFormat: 'MMM yyyy');
        final yearStart = dateFormatString(it['startDate'],
            fromFormat: 'yyyy-MM-dd', toFormat: 'yyyy');
        final yearEnd = dateFormatString(it['endDate'],
            fromFormat: 'yyyy-MM-dd', toFormat: 'yyyy');
        final year = yearStart == yearEnd ? yearStart : "$yearStart - $yearEnd";
        final range = datesWithDuration(it['startDate'], it['endDate'],
            withDuration: false);
        final filenames = it['filenames'] != ""
            ? List.from(it['filenames']).map((f) {
                return f.toString();
              }).toList()
            : [];
        return Payslip(
          year: year,
          month: month,
          range: range,
          type: it['type'] ?? '',
          payslipCodeName: it['payslipCodeName'] ?? '',
          filenames: filenames.toList() as List<String>,
        );
      });
      return requests.toList();
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }

  // GET Safety & Security Messages
  Future<Map<String, dynamic>> getSSM({required BuildContext context}) async {
    try {
      final payload = {
        "_method": Constants.isDummyAPI
            ? "dummy.getSafetySecurityMessages"
            : "bc.getSafetySecurityMessages",
        "_version": await getAppVersion()
      } as Map<String, dynamic>;
      final res = await apiService.getRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      if (!success) {
        return Future.value({});
      }
      // debugPrint(json);
      return json['ssm'];
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value({});
    }
  }

  Future<Map<String, dynamic>> requestGeneratePayslip({
    required BuildContext context,
    required String filename,
  }) async {
    try {
      final payload = {
        "filename": filename,
        "_method": Constants.isDummyAPI
            ? "dummy.requestDownloadPayslip"
            : "bc.requestDownloadPayslip",
        "_version": await getAppVersion()
      } as Map<String, dynamic>;
      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      await apiResHandler(context, json);
      return Future.value(json);
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value({'success': false, 'message': e.toString()});
    }
  }

  Future<Map<String, dynamic>> checkProgressGeneratePayslip({
    required BuildContext context,
    required String filename,
  }) async {
    try {
      final payload = {
        "filename": filename,
        "_method": Constants.isDummyAPI
            ? "dummy.progressDownloadPayslip"
            : "bc.progressDownloadPayslip",
        "_version": await getAppVersion()
      } as Map<String, dynamic>;
      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      await apiResHandler(context, json);
      return Future.value(json);
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value({'success': false, 'message': e.toString()});
    }
  }

  Future<List<Duty>> getDutyRosters({
    required BuildContext context,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final payload = {
        '_method':
            Constants.isDummyAPI ? "dummy.getDutyRosters" : "bc.getDutyRosters",
        'startDate': startDate,
        'endDate': endDate,
        "_version": await getAppVersion()
      } as Map<String, dynamic>;

      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      if (!success) {
        return Future.value([]);
      }
      final List<Map<String, dynamic>> items =
          List<Map<String, dynamic>>.from((json['dutyrosters'] ?? []));
      final List<Duty> requests =
          items.map((map) => Duty.fromMap(map)).toList();
      return requests;
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }

  Future<List<Map<String, dynamic>>> overtimeList(
    BuildContext context,
    String? month,
  ) async {
    try {
      final payload = {
        "month": month,
        "_method":
            Constants.isDummyAPI ? "dummy.overtimeList" : "bc.overtimeList",
        "_version": await getAppVersion()
      } as Map<String, dynamic>;
      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      if (!success) {
        return Future.value([]);
      }
      final List<Map<String, dynamic>> items =
          List<Map<String, dynamic>>.from((json['overtimeList'] ?? []));
      return items.toList();
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }

  Future<List<Map<String, dynamic>>> attendanceList(
    BuildContext context,
    String? startDate,
    String? endDate,
  ) async {
    try {
      final payload = {
        "startDate": startDate,
        "endDate": endDate,
        "_method": Constants.isDummyAPI
            ? "dummy.getAttendanceList"
            : "bc.getAttendanceList",
        "_version": await getAppVersion()
      };

      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);

      if (!success) {
        return Future.value([]);
      }

      final List<Map<String, dynamic>> items =
          List<Map<String, dynamic>>.from((json['attendanceList'] ?? []));
      return items.toList();
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }

  Future<List<BroadcastMessage>> broadcastMessagesList(BuildContext context,
      String? status, String? keyword, String? filterDate) async {
    try {
      final payload = {
        "status": status,
        "keyword": keyword,
        "filterDate": filterDate,
        "_method": Constants.isDummyAPI
            ? "dummy.broadcastMessages"
            : "bc.broadcastMessages",
        "_version": await getAppVersion()
      };

      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      if (!success) {
        return Future.value([]);
      }

      final List<Map<String, dynamic>> items =
          List<Map<String, dynamic>>.from((json['messagesList'] ?? []));
      List<BroadcastMessage> messages = items.map((it) {
        return BroadcastMessage.fromMap(it);
      }).toList();
      return messages;
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }

  Future<List<NotificationsMessage>> notificationMessagesList(
      BuildContext context, String? status, String? keyword) async {
    try {
      final payload = {
        "status": status,
        "keyword": keyword,
        "_method": Constants.isDummyAPI
            ? "dummy.notificationMessages"
            : "bc.notificationMessages",
        "_version": await getAppVersion()
      };

      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      if (!success) {
        return Future.value([]);
      }

      final List<Map<String, dynamic>> items =
          List<Map<String, dynamic>>.from((json['messagesList'] ?? []));
      List<NotificationsMessage> messages = items.map((it) {
        return NotificationsMessage.fromMap(it);
      }).toList();
      return messages;
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }

  Future<bool> updateNotificationsMessageStatus(
    BuildContext context,
    NotificationsMessage message,
    String? status,
  ) async {
    try {
      final payload = {
        "status": status,
        "id": message.id,
        "_method": Constants.isDummyAPI
            ? "dummy.readNotification"
            : "bc.readNotification",
        "_version": await getAppVersion()
      };

      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      return Future.value(success);
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value(false);
    }
  }

  Future<bool> updateBroadcastMessageStatus(
    BuildContext context,
    BroadcastMessage message,
    String? status,
    String? remark,
  ) async {
    try {
      final payload = {
        "status": status,
        "remark": remark,
        "id": message.id,
        "_method": Constants.isDummyAPI
            ? "dummy.updateBroadcastMessageStatus"
            : "bc.updateBroadcastMessageStatus",
        "_version": await getAppVersion()
      };

      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      return Future.value(success);
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value(false);
    }
  }

  Future<bool> removeBroadcastMessageFile(
    BuildContext context,
    BroadcastMessage message,
    String fileUrl,
  ) async {
    try {
      final payload = {
        "id": message.id,
        "fileUrl": fileUrl,
        "_method": Constants.isDummyAPI
            ? "dummy.removeBroadcastMessageFile"
            : "bc.removeBroadcastMessageFile",
        "_version": await getAppVersion()
      };

      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      return Future.value(success);
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value(false);
    }
  }

  Future<bool> removeBroadcastMessages(
    BuildContext context,
    List<int> ids,
  ) async {
    try {
      final payload = {
        "ids": ids,
        "_method": Constants.isDummyAPI
            ? "dummy.removeBroadcastMessages"
            : "bc.removeBroadcastMessages",
        "_version": await getAppVersion()
      };

      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      return Future.value(success);
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value(false);
    }
  }

  Future<bool> removeNotifications(
    BuildContext context,
    List<int> ids,
  ) async {
    try {
      final payload = {
        "ids": ids,
        "_method": Constants.isDummyAPI
            ? "dummy.removeNotifications"
            : "bc.removeNotifications",
        "_version": await getAppVersion()
      };

      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      return Future.value(success);
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value(false);
    }
  }

  Future<List<String>> getBusTripTypes(
    BuildContext context,
  ) async {
    try {
      final payload = {
        "_method": Constants.isDummyAPI
            ? "dummy.getBusTripTypes"
            : "bc.getBusTripTypes",
        "_version": await getAppVersion()
      };

      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);

      if (!success) {
        return Future.value([]);
      }

      final List<String> items = List<String>.from((json['tripTypes'] ?? []));
      return items.toList();
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }

  Future<Map<String, dynamic>> startBusCheck(
    BuildContext context,
    String? trip,
    String? plateNumber,
  ) async {
    try {
      final payload = {
        "trip": trip,
        "plateNumber": plateNumber,
        "_method":
            Constants.isDummyAPI ? "dummy.startBusCheck" : "bc.startBusCheck",
        "_version": await getAppVersion()
      };

      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);

      if (!success) {
        return Future.value({"success": false, "message": json['message']});
      }
      final bus = Map<String, dynamic>.from(json['bus']);
      final checkList =
          List<Map<String, dynamic>>.from(json['logItems']).toList();
      final items = checkList.map((it) {
        final logs = List<Map<String, dynamic>>.from(it['logs']).toList();
        final responses = logs.map((r) {
          return BusCheckResponse.fromMap(r);
        }).toList();
        return BusCheckItem(type: it['type'], logs: responses);
      }).toList();
      return Future.value({"success": true, "bus": bus, "checklist": items});
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value({"success": false});
    }
  }

  Future<List<String>> getDepotList(
    BuildContext context,
  ) async {
    try {
      final payload = {
        "_method":
            Constants.isDummyAPI ? "dummy.getDepotList" : "bc.getDepotList",
        "_version": await getAppVersion()
      };

      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);

      if (!success) {
        return Future.value([]);
      }
      final depots =
          List<String>.from(json['depotList']).map((it) => it.toString());
      return Future.value(depots.toList());
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }

  Future<bool> submitBusCheck({
    required BuildContext context,
    required List<BusCheckItem> buscheckItems,
    required taskName,
    required String plate,
    required String depot,
    required String tripNumber,
  }) async {
    try {
      List<Map<String, dynamic>> items = [];
      for (final item in buscheckItems) {
        List<Map<String, dynamic>> logs = [];
        for (final log in item.logs) {
          final it = {
            'id': log.id,
            'taskId': log.taskId,
            'type': log.type,
            'description': log.description,
            'serialNo': log.serialNo,
            'tag': log.tag,
            'checked': log.checked == true,
            'remarks': log.remarks,
            'attachmentPath1': log.attachmentPath1,
            'attachmentPath2': log.attachmentPath2,
          };
          logs.add(it);
        }
        items.add({
          "type": item.type,
          "logs": logs,
        });
      }

      FormData payload = FormData.fromMap({
        "taskName": taskName,
        "plate": plate,
        "tripNumber": tripNumber,
        "depot": depot,
        "buscheckItems": items,
        "_method": "bc.submitBusCheckList",
        "_version": await getAppVersion()
      });
      final res = await apiService.postFormDataRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      String message = json['message'] ?? 'Something went wrong!';
      if (success) {
        message = json['message'] ?? 'Your request is successfully submitted!';
        showSnackBar(context, message);
      }
      return Future.value(success);
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value(false);
    }
  }

  Future<String> uploadBusCheckAttachment({
    required BuildContext context,
    required File attachment,
  }) async {
    try {
      FormData payload = FormData.fromMap({
        "_method": "bc.uploadBusCheckAttachment",
        "_version": await getAppVersion()
      });
      final img = await MultipartFile.fromFile(
        attachment.path,
        contentType: MediaType('image', 'jpeg'),
      );
      payload.files.add(MapEntry("attachment", img));
      final res = await apiService.postFormDataRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      String path = "";
      if (success) {
        path = json['path'].toString();
        if (path == "" || path.isEmpty) {
          showSnackBar(context, "Unable to upload file!", isSuccess: false);
        }
      }
      return Future.value(path);
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value("");
    }
  }

  Future<bool> removeBusCheckAttachment({
    required BuildContext context,
    required String path,
  }) async {
    try {
      FormData payload = FormData.fromMap({
        "_method": "bc.removeBusCheckAttachment",
        "filename": path,
        "_version": await getAppVersion()
      });
      final res = await apiService.postFormDataRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      return Future.value(success);
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value(false);
    }
  }

  Future<List<BusCheckResponse>> getDeclarations(
    BuildContext context,
  ) async {
    try {
      final payload = {
        "_method": Constants.isDummyAPI
            ? "dummy.getBCDeclarations"
            : "bc.getBCDeclarations",
        "_version": await getAppVersion()
      };

      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);

      if (!success) {
        return Future.value([]);
      }
      if (json['declarations']?.isEmpty) return Future.value([]);
      final declarations = List<Map<String, dynamic>>.from(json['declarations'])
          .map((it) => Map<String, dynamic>.from(it))
          .toList();
      return Future.value(
          declarations.map((it) => BusCheckResponse.fromMap(it)).toList());
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }

  Future<bool> submitBusCheckDeclaration(
      {required BuildContext context,
      required BusCheckItem buscheckItem,
      required bool needApproval}) async {
    try {
      List<Map<String, dynamic>> logs = buscheckItem.logs.map((log) {
        return {
          'id': log.id,
          'taskId': log.taskId,
          'type': log.type,
          'description': log.description,
          'serialNo': log.serialNo,
          'tag': log.tag,
          'checked': log.checked == true,
          'remarks': log.remarks,
        } as Map<String, dynamic>;
      }).toList();

      FormData payload = FormData.fromMap({
        "logs": logs,
        "needApproval": needApproval,
        "_method": "bc.submitBusCheckDeclaration",
        "_version": await getAppVersion()
      });
      final res = await apiService.postFormDataRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      String message = json['message'] ?? 'Something went wrong!';
      if (success) {
        message = json['message'] ?? 'Your request is successfully submitted!';
        showSnackBar(context, message);
      }
      return Future.value(success);
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value(false);
    }
  }

  Future<Map<String, dynamic>> myDeclarationsDeclared(
    BuildContext context,
  ) async {
    try {
      final payload = {
        "_method": "bc.declarationsDeclared",
        "_version": await getAppVersion()
      };

      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);

      if (!success) {
        return Future.value({});
      }
      return json;
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value({});
    }
  }

  Future<List<BusCheckHistory>> getBusCheckHistory(
    BuildContext context,
    String? status,
    List<String>? taskType,
    String? submittedDate,
  ) async {
    try {
      final payload = {
        "_method": "bc.busCheckHistory",
        "status": status,
        "taskType": taskType,
        "submittedDate": submittedDate,
        "_version": await getAppVersion()
      };

      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);

      if (!success) {
        return Future.value([]);
      }
      final maps = List<Map<String, dynamic>>.from(json['history']).map((it) {
        final item = Map<String, dynamic>.from(it);
        final results = List<dynamic>.from(item['checkResults']);
        List<Map<String, dynamic>> list = [];
        for (final r in results) {
          list.add(Map<String, dynamic>.from(r));
        }
        item['checkResults'] = list;
        return item;
      }).toList();
      final history = maps.map((it) => BusCheckHistory.fromMap(it)).toList();
      return Future.value(history);
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }

  Future<bool> submitReportHazard({
    required BuildContext context,
    required String description,
    required String location,
    required List<File> documents,
    required String? others,
  }) async {
    try {
      FormData payload = FormData.fromMap({
        "description": description,
        "location": location,
        "others": others,
        "_method": "bc.submitReportHazard",
        "_version": await getAppVersion()
      });

      if (documents.isNotEmpty) {
        int i = 0;
        for (final doc in documents) {
          final attachment = await MultipartFile.fromFile(
            doc.path,
            contentType: MediaType('image', 'jpeg'),
          );
          payload.files.add(MapEntry("attachments[$i]", attachment));
          i++;
        }
      }

      final res = await apiService.postFormDataRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      String message = json['message'] ?? 'Something went wrong!';
      if (success) {
        message = json['message'] ?? 'Your report is successfully submitted!';
        showSnackBar(context, message);
      }
      return Future.value(success);
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value(false);
    }
  }

  Future<List<String>> getFeedbackTypes(BuildContext context) async {
    try {
      final payload = {
        "_method":
            Constants.isDummyAPI ? "dummy.getFeedBackTypeList" : "bc.getFeedBackTypeList",
        "_version": await getAppVersion()
      } as Map<String, dynamic>;
      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      if (!success) {
        return Future.value([]);
      }
      final List<String> items = List<String>.from((json['feedbackTypes'] ?? []));
      return items.toList();
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }

  Future<bool> submitFeedback({
    required BuildContext context,
    required String description,
    required String type,
    required File? document,
    required String timeReported,
  }) async {
    try {
      FormData payload = FormData.fromMap({
        "description": description,
        "type": type,
        "timeReported": timeReported,
        "_method": "bc.submitFeedback",
        "_version": await getAppVersion()
      });

      if (document != null) {
        final attachment = await MultipartFile.fromFile(
          document.path,
          contentType: MediaType('image', 'jpeg'),
        );
        payload.files.add(MapEntry("attachments[0]", attachment));
      }

      final res = await apiService.postFormDataRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      String message = json['message'] ?? 'Something went wrong!';
      if (success) {
        message = json['message'] ?? 'Your feedback is successfully submitted!';
        showSnackBar(context, message);
      }
      return Future.value(success);
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value(false);
    }
  }

  Future<List<HazardReport>> hazardReportHistory(
    BuildContext context, {
    String? status,
    List<String>? locations,
    String? submitDate,
  }) async {
    try {
      final payload = {
        "status": status,
        "locations": locations,
        "submitDate": submitDate,
        "_method": Constants.isDummyAPI
            ? "dummy.hazardReportHistory"
            : "bc.hazardReportHistory",
        "_version": await getAppVersion()
      };

      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);
      if (!success) {
        return Future.value([]);
      }
      final List<Map<String, dynamic>> items =
          List<Map<String, dynamic>>.from((json['history'] ?? []));
      final hazardReports =
          items.map((item) => HazardReport.fromMap(item)).toList();
      return Future.value(hazardReports);
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }

  Future<List<DocumentFolder>> getFolders(BuildContext context) async {
    try {
      final payload = {
        "_method": "bc.getDocumentFolders",
        "_version": await getAppVersion()
      };

      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);

      if (!success) {
        return Future.value([]);
      }
      final List<Map<String, dynamic>> items =
          List<Map<String, dynamic>>.from((json['folders'] ?? []));
      final folders =
          items.map((item) => DocumentFolder.fromMap(item)).toList();
      return Future.value(folders);
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }

  Future<List<DocumentFile>> getDocumentFiles(
      BuildContext context, DocumentFolder folder) async {
    try {
      final payload = {
        "_method": "bc.getDocumentFolderDetails",
        "id": folder.id,
        "_version": await getAppVersion()
      };

      final res = await apiService.postRequest(payload);
      final json = jsonDecode(res);
      bool success = await apiResHandler(context, json);

      if (!success) {
        return Future.value([]);
      }
      final List<Map<String, dynamic>> items =
          List<Map<String, dynamic>>.from((json['files'] ?? []));
      final files = items.map((item) => DocumentFile.fromMap(item)).toList();
      return Future.value(files);
    } catch (e) {
      showSnackBar(context, e.toString(), isSuccess: false);
      return Future.value([]);
    }
  }
}
