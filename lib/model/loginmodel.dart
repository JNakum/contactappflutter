class LoginRequest {
  final String username;
  final String password;
  final String baseEndpoint;

  LoginRequest(
      {required this.username,
      required this.password,
      this.baseEndpoint = "gql-sample"});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'base_endpoint': baseEndpoint,
    };
  }
}

class LoginResponse {
  final String? token;
  final String userId;

  LoginResponse({required this.token, required this.userId});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['your-api-key'],
      userId: json['userId'],
    );
  }
}
