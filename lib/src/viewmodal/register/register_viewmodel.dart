import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:read_paper/core/helper/network.dart';
import 'package:read_paper/src/model/category.dart';

class RegisterViewModel extends ChangeNotifier {
  int statusCode = 0;
  RegisterViewModel() {}

  Future<int> registerAccount(Map<String, dynamic> data) async {
    log(data.toString());
    String base_url = "/api/auth/signup";
    var response = await ApiProvider().post(base_url, data);
    log(response.data.toString());
    Map<String, dynamic> responseData = response.data;
    String jsonString = json.encode(responseData);
    Map<String, dynamic> userToken = json.decode(jsonString);
    statusCode = int.parse(userToken['code'].toString());

    return statusCode;
    // notifyListeners();
  }
}
