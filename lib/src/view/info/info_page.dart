import 'package:flutter/material.dart';
import 'package:read_paper/core/files/app_preferences/app_preferences.dart';
import 'package:read_paper/core/files/hive_storage_file/hive_storage_manager.dart';
import 'package:read_paper/main.dart';
import 'package:read_paper/src/view/login/login_page.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  List<Map<String, dynamic>> optionList = [
    {"id": 0, "icon": Icons.person_outlined, "text": "Thông tin cá nhân"},
    {"id": 1, "icon": Icons.verified_user_outlined, "text": "Chính sách"},
    {"id": 2, "icon": Icons.policy_outlined, "text": "Liên hệ"},
    {"id": 3, "icon": Icons.logout_outlined, "text": "Đăng xuất"}
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: AppThemePreferences.primaryColor,
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.2,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8 - 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      width: 150, // Đặt kích thước của container
                      height: 150,
                      child: Image.asset("assets/logo.png"),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: optionList.length,
                      itemBuilder: (context, index) {
                        var item = optionList[index];
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              print(item['id']);
                              if (item['id'] == 3) {
                                HiveStorageManager.deleteUserTokenInfo();
                                navigatorKey.currentState?.pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  Icon(item['icon']),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(item['text']),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
