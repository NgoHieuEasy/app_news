import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:read_paper/core/constants/constants.dart';
import 'package:read_paper/core/files/hive_storage_file/hive_storage_manager.dart';

class ApiProvider {
  final dio = Dio();

  get(String url) async {
    final token = HiveStorageManager.readUserTokenInfo() ?? '';
    log(token.toString());
    Options options = Options(
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token.toString()}',
      },
    );
    try {
      final response = await dio.get(URL_BASE + url, options: options);

      if (response.statusCode == STATUS_SUCCESS) {
        return response.data;
      }
    } catch (e) {
      //bad practice to print error use logger
      // print(e);
      rethrow;
    }
  }

  post(String url, Map<String, dynamic> data) async {
    try {
      Options options = Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token',
        },
      );

      final response =
          await dio.post(URL_BASE + url, data: data, options: options);
      if (response.statusCode == STATUS_SUCCESS) {
        return response;
      }
    } catch (e) {
      rethrow;
    }
  }

  put(String url, Map<String, dynamic> data) async {
    try {
      String jsondata = json.encode(data);
      Options options = Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token',
        },
      );

      final response =
          await dio.put(URL_BASE + url, data: jsondata, options: options);

      if (response.statusCode == STATUS_SUCCESS) {
        return true;
      }
    } catch (e) {
      //bad practice to print error use logger
      // print(e);
      rethrow;
    }
  }

  delete(String url) async {
    try {
      Options options = Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token',
        },
      );
      final response = await dio.delete(URL_BASE + url);

      if (response.statusCode == STATUS_SUCCESS) {
        return true;
      }
    } catch (e) {
      //bad practice to print error use logger
      // print(e);
      rethrow;
    }
  }
}
