// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DocumentFile {
  int id;
  String name;
  String size;
  String mtime;
  String timeAdded;
  String owner;
  int folderId;
  String folderName;
  DocumentFile({
    required this.id,
    required this.name,
    required this.size,
    required this.mtime,
    required this.timeAdded,
    required this.owner,
    required this.folderId,
    required this.folderName,
  });

  DocumentFile copyWith({
    int? id,
    String? name,
    String? size,
    String? mtime,
    String? timeAdded,
    String? owner,
    int? folderId,
    String? folderName,
  }) {
    return DocumentFile(
      id: id ?? this.id,
      name: name ?? this.name,
      size: size ?? this.size,
      mtime: mtime ?? this.mtime,
      timeAdded: timeAdded ?? this.timeAdded,
      owner: owner ?? this.owner,
      folderId: folderId ?? this.folderId,
      folderName: folderName ?? this.folderName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'size': size,
      'mtime': mtime,
      'timeAdded': timeAdded,
      'owner': owner,
      'folderId': folderId,
      'folderName': folderName,
    };
  }

  factory DocumentFile.fromMap(Map<String, dynamic> map) {
    return DocumentFile(
      id: map['id'] as int,
      name: (map['name'] ?? '') as String,
      size: (map['size'] ?? '').toString(),
      mtime: (map['mtime'] ?? '') as String,
      timeAdded: (map['timeAdded'] ?? '') as String,
      owner: (map['owner'] ?? '') as String,
      folderId: map['folderId'] as int,
      folderName: (map['folderName'] ?? '') as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DocumentFile.fromJson(String source) =>
      DocumentFile.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DocumentFile(id: $id, name: $name, size: $size, mtime: $mtime, timeAdded: $timeAdded, owner: $owner, folderId: $folderId, folderName: $folderName)';
  }

  @override
  bool operator ==(covariant DocumentFile other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.size == size &&
        other.mtime == mtime &&
        other.timeAdded == timeAdded &&
        other.owner == owner &&
        other.folderId == folderId &&
        other.folderName == folderName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        size.hashCode ^
        mtime.hashCode ^
        timeAdded.hashCode ^
        owner.hashCode ^
        folderId.hashCode ^
        folderName.hashCode;
  }
}
