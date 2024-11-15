abstract class DrivingPerformance {
  final DrivingPerformanceEvent events;
  final DrivingPerformanceTrip trips;

  DrivingPerformance({
    required this.events,
    required this.trips,
  });
}

class DrivingPerformanceEvent {
  DrivingPerformanceEvent({
    required String time,
    required String serviceno,
    required String alarmType,
  });

  factory DrivingPerformanceEvent.fromJson(Map<String, dynamic> json) {
    return DrivingPerformanceEvent(
      time: (json['time'] ?? '').toString(),
      serviceno: (json['serviceno'] ?? '').toString(),
      alarmType: (json['alarmType'] ?? '').toString(),
    );
  }
}

class DrivingPerformanceTrip {
  final String startTime;
  final String endTime;
  final Map<String, int> eventOcc;

  DrivingPerformanceTrip({
    required this.startTime,
    required this.endTime,
    required this.eventOcc,
  });

  factory DrivingPerformanceTrip.fromJson(Map<String, dynamic> json) {
    return DrivingPerformanceTrip(
      startTime: (json['startTime'] ?? '').toString(),
      endTime: (json['endTime'] ?? '').toString(),
      eventOcc: Map<String, int>.from(json['eventOcc']),
    );
  }
}
