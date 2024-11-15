class DrivingPerformanceMonthly {
  final String date;
  final String performance;
  final Map<String, int> performanceCount;
  final Map<String, int> eventsCount;
  final String interventionStatus;

  DrivingPerformanceMonthly({
    required this.date,
    required this.performance,
    required this.performanceCount,
    required this.eventsCount,
    required this.interventionStatus,
  });

  factory DrivingPerformanceMonthly.fromJson(Map<String, dynamic> json) {
    return DrivingPerformanceMonthly(
      date: (json['date'] ?? '').toString(),
      performance: (json['performance'] ?? '').toString(),
      performanceCount: Map<String, int>.from(json['performanceCount']),
      eventsCount: Map<String, int>.from(json['eventsCount']),
      interventionStatus: (json['interventionStatus'] ?? '').toString(),
    );
  }
}
