import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:read_paper/core/files/hive_storage_file/hive_storage_manager.dart';
import 'package:read_paper/core/helper/network.dart';
import 'package:read_paper/src/model/category.dart';

class LoginViewModel extends ChangeNotifier {
  int statusCode = 0;
  LoginViewModel() {}

  Future<int> loginAccount(Map<String, dynamic> data) async {
    String base_url = "/api/auth/login";
    final response = await ApiProvider().post(base_url, data);
    if (response != null) {
      Map<String, dynamic> responseData = response.data;
      String jsonString = json.encode(responseData);
      Map<String, dynamic> userToken = json.decode(jsonString);
      statusCode = int.parse(userToken['code'].toString());
      if (statusCode == 200) {
        HiveStorageManager.storeUserTokenInfo(userToken['result'].toString());
        return statusCode;
      }
    }
    return statusCode;
  }

  Future<int> sendOTPPassword(String numberphone) async {
    int numberphoneCode = int.parse(numberphone);
    String base_url = "/api/v1/verification/send-code?phoneNumber=$numberphone";

    final response = await ApiProvider().get(base_url);

    log(response.toString());
    if (response != null) {
      Map<String, dynamic> responseData = response;
      String jsonString = json.encode(responseData);
      Map<String, dynamic> userToken = json.decode(jsonString);
      statusCode = int.parse(userToken['code'].toString());
    }
    return statusCode;
  }

  veritifyOTP({required String phoneNumber, required String code}) async {
    int OTPcode = int.parse(code);
    log(phoneNumber.toString());
    log(OTPcode.toString());
    String base_url =
        "/api/v1/verification/verify-code?phoneNumber=$phoneNumber&code=$OTPcode";
    final response = await ApiProvider().get(base_url);
    if (response != null) {
      Map<String, dynamic> responseData = response;
      String jsonString = json.encode(responseData);
      Map<String, dynamic> userToken = json.decode(jsonString);
      statusCode = int.parse(userToken['code'].toString());

      log(response.toString());
      log(statusCode.toString());
    }
    return statusCode;
  }

  resetPassword(Map<String, dynamic> data) async {
    String base_url = "/api/auth/reset-password";
    final response = await ApiProvider().post(base_url, data);
    if (response != null) {
      Map<String, dynamic> responseData = response.data;
      // log(responseData.toString());
      // String jsonString = json.encode(responseData);
      // log(responseData.toString());
      // Map<String, dynamic> userToken = json.decode(jsonString);
      // log(userToken.toString());
      statusCode = int.parse(responseData['code']);
    }
    return statusCode;
  }
}
