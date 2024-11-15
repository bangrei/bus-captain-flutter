// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

@immutable
class LeaveRequest {
  final String requestNo;
  final String leaveType;
  final String startDate;
  final String endDate;
  final bool isHalfDay;
  final String amOrPm;
  final String reason;
  final String status;
  final String submittedTime;
  final String approvedTime;
  final String cancelledTime;
  final List<dynamic>? attachments;
  final String supervisorRemarks;
  const LeaveRequest({
    required this.requestNo,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.isHalfDay,
    required this.amOrPm,
    required this.reason,
    required this.status,
    required this.submittedTime,
    required this.approvedTime,
    required this.cancelledTime,
    required this.attachments,
    required this.supervisorRemarks,
  });

  LeaveRequest copyWith({
    String? requestNo,
    String? leaveType,
    String? startDate,
    String? endDate,
    bool? isHalfDay,
    String? amOrPm,
    String? reason,
    String? status,
    String? submittedTime,
    String? approvedTime,
    String? cancelledTime,
    List<dynamic>? attachments,
    String? supervisorRemarks,
  }) {
    return LeaveRequest(
      requestNo: requestNo ?? this.requestNo,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isHalfDay: isHalfDay ?? this.isHalfDay,
      amOrPm: amOrPm ?? this.amOrPm,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      submittedTime: submittedTime ?? this.submittedTime,
      approvedTime: approvedTime ?? this.approvedTime,
      cancelledTime: cancelledTime ?? this.cancelledTime,
      attachments: attachments!.isNotEmpty ? this.attachments : [],
      supervisorRemarks: supervisorRemarks ?? this.supervisorRemarks,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'requestNo': requestNo,
      'leaveType': leaveType,
      'startDate': startDate,
      'endDate': endDate,
      'isHalfDay': isHalfDay,
      'amOrPm': amOrPm,
      'reason': reason,
      'status': status,
      'submittedTime': submittedTime,
      'approvedTime': approvedTime,
      'cancelledTime': cancelledTime,
      'attachments': attachments,
      'supervisorRemarks': supervisorRemarks,
    };
  }

  factory LeaveRequest.fromMap(Map<String, dynamic> map) {
    List<dynamic> attachments = [];
    if (map['attachments'].isNotEmpty) {
      List<dynamic> items = map['attachments'] as List<dynamic>;
      for (final n in items) {
        attachments.add(n);
      }
    }
    return LeaveRequest(
      requestNo: (map['requestNo'] ?? '').toString(),
      leaveType: (map['leaveType'] ?? '').toString(),
      startDate: (map['startDate'] ?? '').toString(),
      endDate: (map['endDate'] ?? '').toString(),
      isHalfDay: (map['isHalfDay'] ?? 0) == 1 ? true : false,
      amOrPm: (map['amOrPm'] ?? '').toString(),
      reason: (map['reason'] ?? '-').toString(),
      status: (map['status'] ?? 'Unknown').toString(),
      submittedTime: (map['submittedTime'] ?? '').toString(),
      approvedTime: (map['approvedTime'] ?? '').toString(),
      cancelledTime: (map['cancelledTime'] ?? '').toString(),
      attachments: attachments,
      supervisorRemarks: (map['supervisorRemarks'] ?? '-').toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory LeaveRequest.fromJson(String source) =>
      LeaveRequest.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LeaveRequest(requestNo: $requestNo, leaveType: $leaveType, startDate: $startDate, endDate: $endDate, isHalfDay: $isHalfDay, amOrPm: $amOrPm, reason: $reason, status: $status, submittedTime: $submittedTime, approvedTime: $approvedTime, cancelledTime: $cancelledTime, attachments: $attachments, supervisorRemarks: $supervisorRemarks)';
  }

  @override
  bool operator ==(covariant LeaveRequest other) {
    if (identical(this, other)) return true;

    return other.requestNo == requestNo &&
        other.leaveType == leaveType &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.isHalfDay == isHalfDay &&
        other.amOrPm == amOrPm &&
        other.reason == reason &&
        other.status == status &&
        other.submittedTime == submittedTime &&
        other.approvedTime == approvedTime &&
        other.cancelledTime == cancelledTime &&
        other.attachments == attachments &&
        other.supervisorRemarks == supervisorRemarks;
  }

  @override
  int get hashCode {
    return requestNo.hashCode ^
        leaveType.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        isHalfDay.hashCode ^
        amOrPm.hashCode ^
        reason.hashCode ^
        status.hashCode ^
        submittedTime.hashCode ^
        approvedTime.hashCode ^
        cancelledTime.hashCode ^
        attachments.hashCode ^
        supervisorRemarks.hashCode;
  }
}
