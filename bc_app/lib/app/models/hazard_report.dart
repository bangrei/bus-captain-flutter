// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';

class HazardReport {
  String caseId;
  String location;
  String description;
  String status;
  String comments;
  String timeReported;
  String timeAcknowledged;
  String timeCompleted;
  String timeClosed;
  List<dynamic> attachments;
  List<dynamic> resolutionAttachments;
  HazardReport({
    required this.caseId,
    required this.location,
    required this.description,
    required this.status,
    required this.comments,
    required this.timeReported,
    required this.timeAcknowledged,
    required this.timeCompleted,
    required this.timeClosed,
    required this.attachments,
    required this.resolutionAttachments,
  });

  HazardReport copyWith(
      {String? caseId,
      String? location,
      String? description,
      String? status,
      String? comments,
      String? timeReported,
      String? timeAcknowledged,
      String? timeCompleted,
      String? timeClosed,
      List<dynamic>? attachments,
      List<dynamic>? resolutionAttachments}) {
    return HazardReport(
        caseId: caseId ?? this.caseId,
        location: location ?? this.location,
        description: description ?? this.description,
        status: status ?? this.status,
        comments: comments ?? this.comments,
        timeReported: timeReported ?? this.timeReported,
        timeAcknowledged: timeAcknowledged ?? this.timeAcknowledged,
        timeCompleted: timeCompleted ?? this.timeCompleted,
        timeClosed: timeClosed ?? this.timeClosed,
        attachments: attachments ?? this.attachments,
        resolutionAttachments:
            resolutionAttachments ?? this.resolutionAttachments);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'caseId': caseId,
      'location': location,
      'description': description,
      'status': status,
      'comments': comments,
      'timeReported': timeReported,
      'timeAcknowledged': timeAcknowledged,
      'timeCompleted': timeCompleted,
      'timeClosed': timeClosed,
      'attachments': attachments,
      'resolutionAttachments': resolutionAttachments
    };
  }

  factory HazardReport.fromMap(Map<String, dynamic> map) {
    List<dynamic> attachments = [];
    if (map['attachments'] != null) {
      attachments = map['attachments'] as List<dynamic>;
    }

    List<dynamic> resolutionAttachments = [];
    if (map['resolutionAttachments'] != null) {
      resolutionAttachments = map['resolutionAttachments'] as List<dynamic>;
    }

    return HazardReport(
        caseId: (map['caseId'] ?? '').toString(),
        location: (map['location'] ?? '').toString(),
        description: (map['description'] ?? '').toString(),
        status: (map['status'] ?? '').toString(),
        comments: (map['comments'] ?? '').toString(),
        timeReported: (map['timeReported'] ?? '').toString(),
        timeAcknowledged: (map['timeAcknowledged'] ?? '').toString(),
        timeCompleted: (map['timeCompleted'] ?? '').toString(),
        timeClosed: (map['timeClosed'] ?? '').toString(),
        attachments: attachments,
        resolutionAttachments: resolutionAttachments);
  }

  String toJson() => json.encode(toMap());

  factory HazardReport.fromJson(String source) =>
      HazardReport.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'HazardReport(caseId: $caseId, location: $location, description: $description, status: $status, comments: $comments, timeReported: $timeReported, timeAcknowledged: $timeAcknowledged, timeCompleted: $timeCompleted, timeClosed: $timeClosed, attachments: $attachments, resolutionAttachments: $resolutionAttachments)';
  }

  @override
  bool operator ==(covariant HazardReport other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.caseId == caseId &&
        other.location == location &&
        other.description == description &&
        other.status == status &&
        other.comments == comments &&
        other.timeReported == timeReported &&
        other.timeAcknowledged == timeAcknowledged &&
        other.timeCompleted == timeCompleted &&
        other.timeClosed == timeClosed &&
        listEquals(other.attachments, attachments) &&
        listEquals(other.resolutionAttachments, resolutionAttachments);
  }

  @override
  int get hashCode {
    return caseId.hashCode ^
        location.hashCode ^
        description.hashCode ^
        status.hashCode ^
        comments.hashCode ^
        timeReported.hashCode ^
        timeAcknowledged.hashCode ^
        timeCompleted.hashCode ^
        timeClosed.hashCode ^
        attachments.hashCode ^
        resolutionAttachments.hashCode;
  }
}
