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
  Partner? _selectedpartner;

  List<Partner> get contact => _partner;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Partner? get selectedPartner => _selectedpartner;

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
      // log("contact load in api partnerparovider.dartr => $_partner");
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

  Future<void> deleteContactPartner(int id) async {
    try {
      await _apiService.deletePartner(id);
      _partner.removeWhere((partner) => partner.id == id);
      notifyListeners();
    } catch (e) {
      log("Failed to delete Partner in provider file: $e");
    }
  }

  void setSelectedPartner(Partner? partner) {
    _selectedpartner = partner;
    notifyListeners();
  }

  Future<void> updateContactPartner(
      int id, String name, String phone, String email, String image) async {
    final updatedData =
        await _apiService.updateContact(id, name, phone, email, image);
    if (updatedData != null) {
      _selectedpartner = Partner.fromJson(updatedData);
      notifyListeners();
    }
  }
}
