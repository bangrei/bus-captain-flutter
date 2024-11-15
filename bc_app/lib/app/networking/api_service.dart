import 'package:bc_app/resources/utils.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '/config/decoders.dart';

/* ApiService
| -------------------------------------------------------------------------
| Define your API endpoints
| Learn more https://nylo.dev/docs/5.20.0/networking
|-------------------------------------------------------------------------- */

class ApiService extends NyApiService {
  ApiService({BuildContext? buildContext})
      : super(
          buildContext,
          decoders: modelDecoders,
          baseOptions: (BaseOptions baseOptions) {
            return baseOptions
                      ..connectTimeout = Duration(seconds: 20)
                      ..sendTimeout = Duration(seconds: 20)
                      ..receiveTimeout = Duration(seconds: 20);
          },
        );

  @override
  String get baseUrl => getEnv('STAGE_API_BASE_URL');

  @override
  // ignore: overridden_fields
  final interceptors = {
    if (getEnv('APP_DEBUG') == true) PrettyDioLogger: PrettyDioLogger()
  };

  Future getRequest(Map<String, dynamic> params, {String auth = ""}) async {
    String? myAuthToken = await NyStorage.read('authToken') ?? '';
    String deviceOsVersion = await getDeviceOsVersion();

    return await network(
      request: (request) {
        if (myAuthToken!.isNotEmpty) {
          request.options.headers.addAll({
            "Authorization": "Bearer $myAuthToken",
            "User-Agent": deviceOsVersion
          });
        } else if (auth.isNotEmpty) {
          request.options.headers.addAll({
            "Authorization": "TMP $auth",
            "User-Agent": deviceOsVersion
          });
        }
        return request.get("/mobile-api/", queryParameters: params);
      },
    );
  }

  Future postRequest(Map payload, {String auth = "", String? authToken = ""}) async {
    String? myAuthToken = await NyStorage.read('authToken') ?? authToken;
    String deviceOsVersion = await getDeviceOsVersion();

    return await network(
      request: (request) {
        request.options.headers.addHeader('Content-Type', 'application/json');
        if (myAuthToken!.isNotEmpty) {
          request.options.headers.addAll({
            "Authorization": "Bearer $myAuthToken",
            "User-Agent": deviceOsVersion
          });
        } else if (auth.isNotEmpty) {
          request.options.headers.addAll({
            "Authorization": "TMP $auth",
            "User-Agent": deviceOsVersion
          });
        }
        return request.post("/mobile-api/", data: payload);
      },
    );
  }

  Future postFormDataRequest(FormData payload, {String auth = ""}) async {
    String? myAuthToken = await NyStorage.read('authToken') ?? '';
    String deviceOsVersion = await getDeviceOsVersion();

    return await network(
      request: (request) {
        request.options.headers
            .addHeader('Content-Type', 'multipart/form-data');
        if (myAuthToken!.isNotEmpty) {
          request.options.headers.addAll({
            "Authorization": "Bearer $myAuthToken",
            "User-Agent": deviceOsVersion
          });
        } else if (auth.isNotEmpty) {
          request.options.headers.addAll({
            "Authorization": "TMP $auth",
            "User-Agent": deviceOsVersion
          });
        }
        return request.post("/mobile-api/", data: payload);
      },
    );
  }
  /* Helpers
  |-------------------------------------------------------------------------- */

  /* Authentication Headers
  |--------------------------------------------------------------------------
  | Set your auth headers
  | Authenticate your API requests using a bearer token or any other method
  |-------------------------------------------------------------------------- */

  // @override
  // Future<RequestHeaders> setAuthHeaders(RequestHeaders headers) async {
  //   String? myAuthToken = await StorageKey.userToken.read();
  //   if (myAuthToken != null) {
  //     headers.addBearerToken( myAuthToken );
  //   }
  //   return headers;
  // }

  /* Should Refresh Token
  |--------------------------------------------------------------------------
  | Check if your Token should be refreshed
  | Set `false` if your API does not require a token refresh
  |-------------------------------------------------------------------------- */

  // @override
  // Future<bool> shouldRefreshToken() async {
  //   return false;
  // }

  /* Refresh Token
  |--------------------------------------------------------------------------
  | If `shouldRefreshToken` returns true then this method
  | will be called to refresh your token. Save your new token to
  | local storage and then use the value in `setAuthHeaders`.
  |-------------------------------------------------------------------------- */

  // @override
  // refreshToken(Dio dio) async {
  //  dynamic response = (await dio.get("https://example.com/refresh-token")).data;
  //  // Save the new token
  //   await StorageKey.userToken.store(response['token']);
  // }

  /* Display a error
  |--------------------------------------------------------------------------
  | This method is only called if you provide the API service
  | with a [BuildContext]. Example below:
  | api<ApiService>(
  |        request: (request) => request.myApiCall(),
  |         context: context);
  |-------------------------------------------------------------------------- */

  // displayError(DioException dioException, BuildContext context) {
  //   showToastNotification(context,
  //       title: "Error",
  //       description: dioException.message ?? "",
  //       style: ToastNotificationStyleType.DANGER);
  // }
}
