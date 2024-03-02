import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:read_paper/core/constants/constants.dart';

class HiveStorageManager {
  static Box hiveBox = Hive.box(HIVE_BOX);

  static Future<void> openHiveBox() async {
    WidgetsFlutterBinding.ensureInitialized();

    print("Initializing Hive...");
    await Hive.initFlutter();

    print("Opening Box...");
    await Hive.openBox(HIVE_BOX);
    print("Box is Open...");
  }

  static saveData({required String key, dynamic data}) {
    hiveBox.put(key, data);
  }

  static dynamic readData({required String key}) {
    var value = hiveBox.get(key);
    return value;
  }

  static deleteData({required String key}) {
    hiveBox.delete(key);
  }

  // save json web token user
  static storeUserTokenInfo(dynamic data) {
    saveData(
      key: USER_TOKEN_INFO,
      data: data,
    );
  }

  static readUserTokenInfo() {
    return readData(
      key: USER_TOKEN_INFO,
    );
  }

  static deleteUserTokenInfo() {
    deleteData(key: USER_TOKEN_INFO);
  }
}
