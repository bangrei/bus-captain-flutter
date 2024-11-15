class DrivingPerformanceEvents {
  final String date;
  final String performance;
  final Map<String, int> eventOcc;

  DrivingPerformanceEvents({
    required this.date,
    required this.performance,
    required this.eventOcc,
  });

  factory DrivingPerformanceEvents.fromJson(Map<String, dynamic> json) {
    return DrivingPerformanceEvents(
      date: (json['date'] ?? '').toString(),
      performance: (json['performance'] ?? '').toString(),
      eventOcc: Map<String, int>.from(json['performanceCount']),
    );
  }
}
