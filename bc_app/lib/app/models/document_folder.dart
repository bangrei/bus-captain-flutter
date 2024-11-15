// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DocumentFolder {
  int id;
  String name;
  String timeAdded;
  DocumentFolder({
    required this.id,
    required this.name,
    required this.timeAdded,
  });

  DocumentFolder copyWith({
    int? id,
    String? name,
    String? timeAdded,
  }) {
    return DocumentFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      timeAdded: timeAdded ?? this.timeAdded,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'timeAdded': timeAdded,
    };
  }

  factory DocumentFolder.fromMap(Map<String, dynamic> map) {
    return DocumentFolder(
      id: map['id'] as int,
      name: (map['name'] ?? '') as String,
      timeAdded: (map['timeAdded'] ?? '') as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DocumentFolder.fromJson(String source) =>
      DocumentFolder.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'DocumentFolder(id: $id, name: $name, timeAdded: $timeAdded)';

  @override
  bool operator ==(covariant DocumentFolder other) {
    if (identical(this, other)) return true;

    return other.id == id && other.name == name && other.timeAdded == timeAdded;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ timeAdded.hashCode;
}
