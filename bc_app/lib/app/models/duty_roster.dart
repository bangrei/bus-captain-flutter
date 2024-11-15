
class Duty {
  
  final String workdayId;
  final String busPlateNum;
  final String date;
  final String startTime;
  final String endTime;
  final String fromDep;
  final String toDep;
  final String ovtCode;

  Duty({
    required this.workdayId,
    required this.busPlateNum,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.fromDep,
    required this.toDep,
    required this.ovtCode
  });

  // Method
  factory Duty.fromMap(Map<String,dynamic> map) {
    return Duty(
      workdayId: (map['workdayId'] ?? '').toString(),
      busPlateNum: (map['busPlateNum'] ?? '').toString(),
      date: (map['date'] ?? '').toString(),
      startTime: (map['startTime'] ?? '').toString(),
      endTime: (map['endTime'] ?? '').toString(),
      fromDep: (map['fromDep'] ?? '').toString(),
      toDep: (map['toDep'] ?? '').toString(),
      ovtCode: (map['ovtCode'] ?? '').toString(),
    );
  }

  @override
  bool operator ==(covariant Duty other) {
    if (identical(this, other)) return true;

    return other.workdayId == workdayId &&
            other.busPlateNum == busPlateNum &&
            other.date == date &&
            other.startTime == startTime &&
            other.endTime == endTime &&
            other.fromDep == fromDep &&
            other.toDep == toDep &&
            other.ovtCode == ovtCode ;
  }

  @override
  int get hashCode {
    return workdayId.hashCode ^
        busPlateNum.hashCode ^
        date.hashCode ^
        startTime.hashCode ^
        endTime.hashCode ^
        fromDep.hashCode ^
        toDep.hashCode ^
        ovtCode.hashCode;
  }

}