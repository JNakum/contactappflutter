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
    image_1920
    
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

  Future<Partner> addNewPartner({
    required String name,
    required String phone,
    required String email,
    required String image,
  }) async {
    const String mutation = """
    mutation Create(\$name: String!, \$phone: String!, \$email: String, \$image: String) {
      createResPartner: ResPartner(
        ResPartnerValues: {
          name: \$name,
          phone: \$phone,
          email: \$email,
          image_1920: \$image
        }
      ) {
        id
        name
        email
        phone
        image_1920
      }
    }
  """;

    final Map<String, dynamic> variables = {
      "name": name,
      "phone": phone,
      "email": email,
      "image": image,
    };

    try {
      Response response = await dio.post(contactUrl,
          options: Options(headers: {
            'x-api-key': authToken,
            'Content-Type': "application/json",
          }),
          data: jsonEncode({"query": mutation, "variables": variables}));

      log("Insert Data Call or Not => $response");
      log("List ya Map => ${response.data.runtimeType}");

      if (response.statusCode == 200 && response.data["data"] != null) {
        final List<dynamic> dataList =
            response.data["data"]["createResPartner"];
        if (dataList.isNotEmpty) {
          final Map<String, dynamic> data = dataList[0];
          Partner partner = Partner.fromJson(data);
          return partner;
        } else {
          throw Exception("createResPartner list is empty");
        }
      } else {
        log("Failed To Insert Partner - Status Code : ${response.statusCode},Response: ${jsonEncode(response.data)}");
        throw Exception("Failed to insert else code partner apiservice");
      }
    } catch (e) {
      log("Error while adding partner: $e");
      throw Exception("Failed to add partner catch code in apiservice");
    }
  }

  Future<void> deletePartner(int id) async {
    final String mutation = """
    mutation Delete(\$id: Int!) {
      deleteResPartner: ResPartner(id: \$id) {
        id
      }
    }
  """;

    try {
      final response = await dio.post(
        contactUrl,
        options: Options(
          headers: {
            'x-api-key': authToken,
            "Content-Type": "application/json",
          },
          responseType: ResponseType.json,
        ),
        data: jsonEncode({
          "query": mutation,
          "variables": {"id": id},
        }),
      );

      if (response.statusCode == 200 && response.data["data"] != null) {
        if (response.data["data"]["delete"] == "Success") {
          log("Partner deleted successfully");
        } else {
          log("Warning: Unexpected response structure");
        }
      } else {
        throw Exception("Failed to delete partner: ${response.statusCode}");
      }
    } catch (e) {
      log("Error deleting partner: $e");
      throw Exception("Error deleting partner");
    }
  }

  Future<Map<String, dynamic>?> updateContact(
      int id, String name, String phone, String email, String image) async {
    const String mutation = '''
      mutation Update(\$id: Int!, \$name: String!, \$phone: String!, \$email: String!, \$image: String!) {
        updateResPartner: ResPartner(
          id: \$id, 
          ResPartnerValues: {
            name: \$name,
            phone: \$phone,
            email: \$email,
            image_1920: \$image
          }
        ) {
          id
          name
          phone
          email
          image_1920
        }
      }
    ''';

    final Map<String, dynamic> variables = {
      "id": id,
      "name": name,
      "phone": phone,
      "email": email,
      "image": image.isNotEmpty ? image : "",
    };

    try {
      final response = await dio.post(
        contactUrl,
        options: Options(headers: {
          'x-api-key': authToken,
          'Content-Type': "application/json",
        }),
        data: jsonEncode({"query": mutation, "variables": variables}),
      );
      log("Response type: ${response.data["data"]["updateResPartner"].runtimeType}");
      log("Response type: ${response.runtimeType}");

      if (response.statusCode == 200) {
        // return response.data["data"]["updateResPartner"];
        final updateResPartner = response.data["data"]["updateResPartner"];

        if (updateResPartner is List && updateResPartner.isNotEmpty) {
          return updateResPartner.first as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print("Error updating contact: $e");
    }
    return null;
  }

  void setAuthToken(String token) {
    authToken = token;
    dio.options.headers['Authorization'] = "Bearer $token";
    dio.options.headers['x-api-key'] = token;
  }
}
