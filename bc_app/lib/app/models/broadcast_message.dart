// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class BroadcastMessage {
  int id;
  String messageId;
  String authorPrivacy;
  String authorDisplay;
  String title;
  String content;
  String hyperlink;
  List<dynamic> attachments;
  List<dynamic> actionFiles;
  String status;
  String type;
  bool archived;
  String broadcastTime;
  bool selected;
  bool read;
  bool acknowledge;
  bool closed;
  bool popup;
  String response;
  BroadcastMessage({
    required this.id,
    required this.messageId,
    required this.authorPrivacy,
    required this.authorDisplay,
    required this.title,
    required this.content,
    required this.hyperlink,
    required this.attachments,
    required this.actionFiles,
    required this.status,
    required this.type,
    required this.archived,
    required this.broadcastTime,
    required this.selected,
    required this.read,
    required this.acknowledge,
    required this.closed,
    required this.popup,
    required this.response,
  });

  BroadcastMessage copyWith({
    int? id,
    String? messageId,
    String? authorPrivacy,
    String? authorDisplay,
    String? title,
    String? content,
    String? hyperlink,
    List<dynamic>? attachments,
    List<dynamic>? actionFiles,
    String? status,
    String? type,
    bool? archived,
    String? broadcastTime,
    bool? selected,
    bool? read,
    bool? acknowledge,
    bool? closed,
    bool? popup,
    String? response,
  }) {
    return BroadcastMessage(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      authorPrivacy: authorPrivacy ?? this.authorPrivacy,
      authorDisplay: authorDisplay ?? this.authorDisplay,
      title: title ?? this.title,
      content: content ?? this.content,
      hyperlink: hyperlink ?? this.hyperlink,
      attachments: attachments ?? this.attachments,
      actionFiles: actionFiles ?? this.actionFiles,
      status: status ?? this.status,
      type: type ?? this.type,
      archived: archived ?? this.archived,
      broadcastTime: broadcastTime ?? this.broadcastTime,
      selected: selected ?? this.selected,
      read: read ?? this.read,
      acknowledge: acknowledge ?? this.acknowledge,
      closed: closed ?? this.closed,
      popup: popup ?? this.popup,
      response: response ?? this.response,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'messageId': messageId,
      'authorPrivacy': authorPrivacy,
      'authorDisplay': authorDisplay,
      'title': title,
      'content': content,
      'hyperlink': hyperlink,
      'attachments': attachments,
      'actionFiles': actionFiles,
      'status': status,
      'type': type,
      'archived': archived,
      'broadcastTime': broadcastTime,
      'selected': selected,
      'read': read,
      'acknowledge': acknowledge,
      'closed': closed,
      'popup': popup,
      'response': response,
    };
  }

  factory BroadcastMessage.fromMap(Map<String, dynamic> map) {
    List<dynamic> attachments = [];
    List<dynamic> actionFiles = [];
    if (map['attachments'] != null) {
      attachments = map['attachments'] as List<dynamic>;
    }
    if (map['actionFiles'] != null) {
      actionFiles = map['actionFiles'] as List<dynamic>;
    }

    return BroadcastMessage(
      id: map['id'] != null ? int.parse(map['id'].toString()) : 0,
      messageId: (map['messageId'] ?? '').toString(),
      authorPrivacy: (map['authorPrivacy'] ?? '').toString(),
      authorDisplay: (map['authorDisplay'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),
      hyperlink: (map['hyperlink'] ?? '').toString(),
      attachments: attachments,
      actionFiles: actionFiles,
      status: (map['status'] ?? '').toString(),
      type: (map['type'] ?? '').toString(),
      archived: map['archived'] || false,
      broadcastTime: (map['broadcastTime'] ?? '').toString(),
      selected: false,
      read: map['read'] || false,
      acknowledge: map['acknowledge'] || false,
      closed: map['closed'] || false,
      popup: map['popup'] || false,
      response: (map['response'] ?? '').toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory BroadcastMessage.fromJson(String source) =>
      BroadcastMessage.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BroadcastMessage(id: $id, messageId: $messageId, authorPrivacy: $authorPrivacy, authorDisplay: $authorDisplay, title: $title, content: $content, hyperlink: $hyperlink, attachments: $attachments, actionFiles: $actionFiles, status: $status, type: $type, archived: $archived, broadcastTime: $broadcastTime, selected: $selected, read: $read, acknowledge: $acknowledge, closed: $closed, popup: $popup, response: $response)';
  }

  @override
  bool operator ==(covariant BroadcastMessage other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.messageId == messageId &&
        other.authorPrivacy == authorPrivacy &&
        other.authorDisplay == authorDisplay &&
        other.title == title &&
        other.content == content &&
        other.hyperlink == hyperlink &&
        other.attachments == attachments &&
        other.actionFiles == actionFiles &&
        other.status == status &&
        other.type == type &&
        other.archived == archived &&
        other.broadcastTime == broadcastTime &&
        other.selected == selected &&
        other.read == read &&
        other.acknowledge == acknowledge &&
        other.closed == closed &&
        other.popup == popup &&
        other.response == response;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        messageId.hashCode ^
        authorPrivacy.hashCode ^
        authorDisplay.hashCode ^
        title.hashCode ^
        content.hashCode ^
        hyperlink.hashCode ^
        attachments.hashCode ^
        actionFiles.hashCode ^
        status.hashCode ^
        type.hashCode ^
        archived.hashCode ^
        broadcastTime.hashCode ^
        selected.hashCode ^
        read.hashCode ^
        acknowledge.hashCode ^
        closed.hashCode ^
        popup.hashCode ^
        response.hashCode;
  }
}
