import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:read_paper/core/files/hive_storage_file/hive_storage_manager.dart';
import 'package:read_paper/src/view/login/login_page.dart';
import 'package:read_paper/src/view/main_navigation/main_navigation.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLogin = false;
  @override
  void initState() {
    isLogined();
    super.initState();
  }

  isLogined() {
    final userToken = HiveStorageManager.readUserTokenInfo();
    log(userToken.toString());
    if (userToken != null) {
      isLogin = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLogin ? MainNavigationPage() : LoginPage();
    // return TestHtml();
  }
}
