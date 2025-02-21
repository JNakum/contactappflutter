import 'package:contactapp/model/loginmodel.dart';
import 'package:contactapp/utils/shareprefrence.dart';
import 'package:contactapp/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class LoginProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  LoginResponse? _user;
  bool _isLoading = false;
  String? _errorMessage;

  LoginResponse? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    LoginResponse? response = await _apiService
        .login(LoginRequest(username: username, password: password));

    _isLoading = false;

    if (response != null) {
      _user = response;
      _apiService.setAuthToken(response.token!);
      await SharePreferenceHelper.saveToken(response.token!);
      notifyListeners();
      return true;
    } else {
      _errorMessage = "Invalid username or password!";
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _user = null;
    _apiService.setAuthToken("");
    notifyListeners();
  }
}
