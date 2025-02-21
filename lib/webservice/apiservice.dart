import 'dart:convert';
import 'dart:developer';

import 'package:contactapp/model/loginmodel.dart';
import 'package:contactapp/model/partnermodel.dart';
import 'package:contactapp/utils/constant.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiService {
  String authEndPoint = Constant().authEndpoint;
  String contactUrl = Constant().baseUrl;
  late Dio dio;
  String? authToken;

  ApiService() {
    dio = Dio();
    dio.options.headers['Content-Type'] = 'application/json';
    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
  }

  void setBasicAuth(String username, String password) {
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    dio.options.headers['Authorization'] = basicAuth;
  }

  Future<LoginResponse?> login(LoginRequest request) async {
    setBasicAuth(request.username, request.password);
    try {
      Response response = await dio.post(
        authEndPoint,
        data: request.toJson(),
      );
      log("Login Response: ${response.data}");

      if (response.statusCode == 200 &&
          response.data['result'] == 'authorised') {
        if (response.data.containsKey("your-api-key")) {
          String? token = response.data['your-api-key'];

          if (token == null || token.isEmpty) {
            log("Error: API Key is empty");
            return null;
          }

          LoginResponse loginResponse =
              LoginResponse(token: token, userId: request.username);

          setAuthToken(token);

          return loginResponse;
        } else {
          log("Error: API Key is missing in response");
          return null;
        }
      } else {
        log("Login Failed ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log("Login Error: $e");
      return null;
    }
  }

  Future<List<Partner>> getContactPartners() async {
    if (authToken == null) {
      log("Error: authToken is null, please login first.");
      return [];
    }

    try {
      Response response = await dio.post(
        contactUrl,
        options: Options(headers: {
          'x-api-key': authToken,
          'Content-Type': 'application/json',
        }),
        data: {
          "query": """
            query MyQuery {
    ResPartner {
    id
    name
    phone
    email
    
}}
          """
        },
      );

      // log("Contact List Data => ${response.data}");

      if (response.statusCode == 200 && response.data["data"] != null) {
        List<dynamic> partnerList = response.data["data"]["ResPartner"];
        // log("partner list => {$partnerList}");
        return partnerList.map((json) => Partner.fromJson(json)).toList();
      } else {
        log("Failed To Get Contact Partners ${response.statusCode}");
        return [];
      }
    } catch (e) {
      log("Error Fetch Partner: $e");
      return [];
    }
  }

  void setAuthToken(String token) {
    authToken = token;
    dio.options.headers['Authorization'] = "Bearer $token";
    dio.options.headers['x-api-key'] = token;
  }
}
