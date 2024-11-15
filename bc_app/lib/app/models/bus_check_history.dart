// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';

class BusCheckHistory {
  String caseId;
  String plate;
  String depot;
  String type;
  String status;
  String submittedTime;
  String busStatus;
  String bctAction;
  List<dynamic> checkResults;
  BusCheckHistory({
    required this.caseId,
    required this.plate,
    required this.depot,
    required this.type,
    required this.status,
    required this.submittedTime,
    required this.busStatus,
    required this.bctAction,
    required this.checkResults,
  });

  BusCheckHistory copyWith({
    String? caseId,
    String? plate,
    String? depot,
    String? type,
    String? status,
    String? submittedTime,
    String? busStatus,
    String? bctAction,
    List<Map<String, dynamic>>? checkResults,
  }) {
    return BusCheckHistory(
      caseId: caseId ?? this.caseId,
      plate: plate ?? this.plate,
      depot: depot ?? this.depot,
      type: type ?? this.type,
      status: status ?? this.status,
      submittedTime: submittedTime ?? this.submittedTime,
      busStatus: busStatus ?? this.busStatus,
      bctAction: bctAction ?? this.bctAction,
      checkResults: checkResults ?? this.checkResults,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'caseId': caseId,
      'plate': plate,
      'depot': depot,
      'type': type,
      'status': status,
      'submittedTime': submittedTime,
      'busStatus': busStatus,
      'bctAction': bctAction,
      'checkResults': checkResults,
    };
  }

  factory BusCheckHistory.fromMap(Map<String, dynamic> map) {
    return BusCheckHistory(
      caseId: (map['caseId'] ?? '').toString(),
      plate: (map['plate'] ?? '').toString(),
      depot: (map['depot'] ?? '').toString(),
      type: (map['type'] ?? '').toString(),
      status: (map['status'] ?? '').toString(),
      submittedTime: (map['submittedTime'] ?? '').toString(),
      busStatus: (map['busStatus'] ?? '').toString(),
      bctAction: (map['bctAction'] ?? '').toString(),
      checkResults: List<dynamic>.from(
        (map['checkResults']),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory BusCheckHistory.fromJson(String source) =>
      BusCheckHistory.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BusCheckHistory(caseId: $caseId, plate: $plate, depot: $depot, type: $type, status: $status, submittedTime: $submittedTime, busStatus: $busStatus, bctAction: $bctAction, checkResults: $checkResults)';
  }

  @override
  bool operator ==(covariant BusCheckHistory other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.caseId == caseId &&
        other.plate == plate &&
        other.depot == depot &&
        other.type == type &&
        other.status == status &&
        other.submittedTime == submittedTime &&
        other.busStatus == busStatus &&
        other.bctAction == bctAction && 
        listEquals(other.checkResults, checkResults);
  }

  @override
  int get hashCode {
    return caseId.hashCode ^
        plate.hashCode ^
        depot.hashCode ^
        type.hashCode ^
        status.hashCode ^
        submittedTime.hashCode ^
        busStatus.hashCode ^
        bctAction.hashCode ^
        checkResults.hashCode;
  }
}
