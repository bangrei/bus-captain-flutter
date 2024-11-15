import 'package:nylo_framework/nylo_framework.dart';

class User extends Model {
  String? token;

  User();

  User.fromJson(dynamic data) {
    token = data['token'];
  }

  @override
  toJson() => {"token": token};
}
