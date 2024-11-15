class Payslip {
  String year;
  String month;
  String range;
  String type;
  String payslipCodeName;
  List<String> filenames;

  Payslip({
    required this.year,
    required this.month,
    required this.range,
    required this.type,
    required this.payslipCodeName,
    required this.filenames,
  });
}
