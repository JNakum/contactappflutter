import 'dart:developer';

import 'package:contactapp/model/partnermodel.dart';
import 'package:contactapp/utils/shareprefrence.dart';
import 'package:contactapp/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class PartnerProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Partner> _partner = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Partner> get contact => _partner;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPartners() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? token = await SharePreferenceHelper.getToken();
      log("get token data partnerparovider.dart => $token ");

      if (token != null) {
        _apiService.setAuthToken(token);
      }

      _partner = await _apiService.getContactPartners();
      log("contact load in api partnerparovider.dartr => $_partner");
    } catch (e) {
      _errorMessage = "Failed to Load Contact In Provider file..";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNewContactPartner({
    required String name,
    required String phone,
    required String email,
    required String image,
  }) async {
    try {
      Partner insertNewPartner = await _apiService.addNewPartner(
          name: name, phone: phone, email: email, image: image);

      _partner.add(insertNewPartner);
      notifyListeners();
    } catch (e) {
      log("Failed to add Partner in provider file $e");
    }
  }
}
