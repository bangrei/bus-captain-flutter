// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bc_app/app/models/bus_check_response.dart';

class BusCheckItem {
  String type;
  List<BusCheckResponse> logs;
  BusCheckItem({
    required this.type,
    required this.logs,
  });
}
