import 'package:bc_app/resources/utils.dart';

class UniformRequest {
  int id;
  String orderno;
  String name;
  String type;
  String size;
  int qty;
  String status;
  String submittedTime;
  String? requestType;
  String? pickupLocation;
  
 

  UniformRequest({
    required this.id,
    required this.orderno,
    required this.name,
    required this.type,
    required this.size,
    required this.qty,
    required this.status,
    required this.submittedTime,
    this.requestType,
    this.pickupLocation,
  });

  void updateStatus(String newStatus) {
    status = newStatus;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderno': orderno,
        'name': name,
        'type': type,
        'size': size,
        'qty': qty,
        'status': status,
        'submittedTime': submittedTime,
        'pickupLocation': pickupLocation,
        'requestType' : requestType
      };

  factory UniformRequest.fromJson(Map<String, dynamic> json) {
    return UniformRequest(
      id: json['id'] ?? '',
      orderno: json['orderNo'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      size: json['size'] ?? '',
      qty: json['qty'] ?? 0,
      status: json['status'] ?? 'Pending',
      pickupLocation: json['pickupLocation'] ?? '',
      requestType: (json['requestType'] ?? '') == '' ? '' : requestTypeToString(json['requestType']),
      submittedTime: dateFormatString(
        json['submittedTime'] ?? '',
        fromFormat: 'yyyy-MM-dd HH:m:s',
        toFormat: 'dd/MM/yyyy HH:mm',
      ),
    );
  }
}