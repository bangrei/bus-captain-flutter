import 'package:nylo_framework/nylo_framework.dart';
import 'package:bc_app/app/networking/api_service.dart';

///Controller for the Nylo
/// See more on controllers here - https://nylo.dev/docs/5.20.0/controllers
class Controller extends NyController {
  ApiService apiService = ApiService();
  Controller();
}
