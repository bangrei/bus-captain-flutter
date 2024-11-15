class DrivingLicense {
  final int id;
  List<String> drivingLicenseTypes = [];
  DateTime issueDate;
  DateTime expiryDate;
  bool renewRequested;
  List<DrivingLicenseItem> items = [];

  DrivingLicense({
    required this.id,
    required this.drivingLicenseTypes,
    required this.issueDate,
    required this.expiryDate,
    required this.renewRequested,
    required this.items,
  });
}

class DrivingLicenseItem {
  final int id;
  List<String> drivingLicenseTypes = [];
  DateTime issueDate;
  DateTime expiryDate;
  bool renewRequested;

  DrivingLicenseItem({
    required this.id,
    required this.drivingLicenseTypes,
    required this.issueDate,
    required this.expiryDate,
    required this.renewRequested,
  });
}
