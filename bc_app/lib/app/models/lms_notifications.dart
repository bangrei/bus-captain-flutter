import 'dart:convert';

class LmsNotifications {
  int id;
  String courseName;
  String sessionCode;
  String dateTime;
  String venue;
  String remarks;
  String broadcastTime;
  bool selected;
  bool read;
  bool acknowledge;
  bool closed;
  bool popup;
  LmsNotifications({
    required this.id,
    required this.courseName,
    required this.sessionCode,
    required this.dateTime,
    required this.venue,
    required this.remarks,
    required this.broadcastTime,
    required this.selected,
    required this.read,
    required this.acknowledge,
    required this.closed,
    required this.popup,
  });

  LmsNotifications copyWith({
    int? id,
    String? courseName,
    String? sessionCode,
    String? dateTime,
    String? venue,
    String? remarks,
    String? broadcastTime,
    bool? selected,
    bool? read,
    bool? acknowledge,
    bool? closed,
    bool? popup,
  }) {
    return LmsNotifications(
      id: id ?? this.id,
      courseName: courseName ?? this.courseName,
      sessionCode: sessionCode ?? this.sessionCode,
      dateTime: dateTime ?? this.dateTime,
      venue: venue ?? this.venue,
      remarks: remarks ?? this. remarks,
      broadcastTime: broadcastTime ?? this.broadcastTime,
      selected: selected ?? this.selected,
      read: read ?? this.read,
      acknowledge: acknowledge ?? this.acknowledge,
      closed: closed ?? this.closed,
      popup: popup ?? this.popup,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id' : id,
      'courseName': courseName,
      'sessionCode' : sessionCode,
      'dateTime': dateTime,
      'venue': venue,
      'remarks': remarks,
      'broadcastTime': broadcastTime,
      'selected': selected,
      'read': read,
      'acknowledge': acknowledge,
      'closed': closed,
      'popup': popup,
    };
  }

  factory LmsNotifications.fromMap(Map<String, dynamic> map) {

    return LmsNotifications(
      id: map['id'] != null ? int.parse(map['id'].toString()) : 0,
      courseName: (map['courseName'] ?? '').toString(),
      sessionCode: (map['sessionCode'] ?? '').toString(),
      dateTime: (map['dateTime'] ?? '').toString(),
      venue: (map['venue'] ?? '').toString(),
      remarks: (map['remarks'] ?? '').toString(),
      broadcastTime: (map['broadcastTime'] ?? '').toString(),
      selected: false,
      read: map['read'] || false,
      acknowledge: map['acknowledge'] || false,
      closed: map['closed'] || false,
      popup: map['popup'] || false,
    );
  }

  String toJson() => json.encode(toMap());
}