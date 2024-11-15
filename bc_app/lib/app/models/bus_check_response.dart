// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

class BusCheckResponse {
  int id;
  int taskId;
  String type;
  String description;
  int serialNo;
  String tag;
  bool? checked;
  bool unfilled;
  File? attachment1;
  File? attachment2;
  String? attachmentPath1;
  String? attachmentPath2;
  String? remarks;
  bool? isLoading1;
  bool? isLoading2;
  BusCheckResponse({
    required this.id,
    required this.taskId,
    required this.type,
    required this.description,
    required this.serialNo,
    required this.tag,
    required this.checked,
    this.unfilled = false,
    this.attachment1,
    this.attachment2,
    this.attachmentPath1,
    this.attachmentPath2,
    this.remarks,
    this.isLoading1,
    this.isLoading2,
  });

  BusCheckResponse copyWith(
      {int? id,
      int? taskId,
      String? type,
      String? description,
      int? serialNo,
      String? tag,
      bool? checked,
      bool? unfilled,
      File? attachment1,
      File? attachment2,
      String? attachmentPath1,
      String? attachmentPath2,
      String? remarks,
      bool? isLoading1,
      bool? isLoading2}) {
    return BusCheckResponse(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      type: type ?? this.type,
      description: description ?? this.description,
      serialNo: serialNo ?? this.serialNo,
      tag: tag ?? this.tag,
      checked: checked ?? this.checked,
      unfilled: unfilled ?? this.unfilled,
      attachment1: attachment1 ?? this.attachment1,
      attachment2: attachment2 ?? this.attachment2,
      attachmentPath1: attachmentPath1 ?? this.attachmentPath1,
      attachmentPath2: attachmentPath2 ?? this.attachmentPath2,
      remarks: remarks ?? this.remarks,
      isLoading1: isLoading1 ?? this.isLoading1,
      isLoading2: isLoading1 ?? this.isLoading2,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'taskId': taskId,
      'type': type,
      'description': description,
      'serialNo': serialNo,
      'tag': tag,
      'checked': checked,
      'unfilled': unfilled,
      'attachment1': attachment1,
      'attachment2': attachment2,
      'attachmentPath1': attachmentPath1,
      'attachmentPath2': attachmentPath2,
      'remarks': remarks,
    };
  }

  factory BusCheckResponse.fromMap(Map<String, dynamic> map) {
    return BusCheckResponse(
      id: map['id'] as int,
      taskId: map['task'] as int,
      type: (map['type'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      serialNo: map['serialNo'] as int,
      tag: (map['tag'] ?? '').toString(),
      checked: map['checked'] != null ? ((map['checked'] ?? false ) as bool) : null,
      unfilled: (map['unfilled'] ?? false) as bool,
      attachment1: map['attachment1'] != null
          ? File.fromUri(map['attachment1']['url'])
          : null,
      attachment2: map['attachment2'] != null
          ? File.fromUri(map['attachment2']['url'])
          : null,
      attachmentPath1: (map['attachmentPath1'] ?? '').toString(),
      attachmentPath2: (map['attachmentPath2'] ?? '').toString(),
      remarks: (map['remarks'] ?? '').toString(),
      isLoading1: (map['isLoading1'] ?? false) as bool,
      isLoading2: (map['isLoading2'] ?? false) as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory BusCheckResponse.fromJson(String source) =>
      BusCheckResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BusCheckResponse(id: $id, taskId: $taskId, type: $type, description: $description, serialNo: $serialNo, tag: $tag, checked: $checked, unfilled: $unfilled, attachment1: ${attachment1!.path}, attachment2: ${attachment2!.path}, attachmentPath1: $attachmentPath1, attachmentPath2: $attachmentPath2, remarks: $remarks, isLoading1: $isLoading1, isLoading2: $isLoading2)';
  }

  @override
  bool operator ==(covariant BusCheckResponse other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.taskId == taskId &&
        other.type == type &&
        other.description == description &&
        other.serialNo == serialNo &&
        other.tag == tag &&
        other.checked == checked &&
        other.unfilled == unfilled &&
        other.attachment1 == attachment1 &&
        other.attachment2 == attachment2 &&
        other.attachmentPath1 == attachmentPath1 &&
        other.attachmentPath2 == attachmentPath2 &&
        other.remarks == remarks;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        taskId.hashCode ^
        type.hashCode ^
        description.hashCode ^
        serialNo.hashCode ^
        tag.hashCode ^
        checked.hashCode ^
        unfilled.hashCode ^
        attachment1.hashCode ^
        attachment2.hashCode ^
        attachmentPath1.hashCode ^
        attachmentPath2.hashCode ^
        remarks.hashCode;
  }
}
