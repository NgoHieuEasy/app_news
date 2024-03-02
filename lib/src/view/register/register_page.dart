import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_paper/core/files/app_preferences/app_preferences.dart';
import 'package:read_paper/core/files/generic_methods/utility_methods.dart';
import 'package:read_paper/core/files/validated/validation.dart';
import 'package:read_paper/src/view/home/home_page.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:read_paper/src/view/login/login_page.dart';
import 'package:read_paper/src/view/main_navigation/main_navigation.dart';
import 'package:read_paper/src/viewmodal/categories/categories_viewmodel.dart';
import 'package:read_paper/src/viewmodal/register/register_viewmodel.dart';
import 'package:speech_to_text/speech_to_text.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<RegisterPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  SpeechToText speechToText = SpeechToText();
  FlutterTts flutterTts = FlutterTts();
  bool obscure = true;
  bool obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    await speechToText.initialize();
    setState(() {});
  }

  bool allFieldsNotEmpty() {
    return _fullNameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _phoneNumberController.text.isNotEmpty;
  }

  handleRegister() async {
    FocusScope.of(context).requestFocus(FocusNode());
    final registerProvider =
        Provider.of<RegisterViewModel>(context, listen: false);
    if (allFieldsNotEmpty()) {
      Map<String, dynamic> data = {
        "fullName": _fullNameController.text.trim(),
        "username": _phoneNumberController.text.trim(),
        "password": _passwordController.text.trim()
      };
      if (_passwordController.text
              .trim()
              .compareTo(_confirmPasswordController.text.trim()) ==
          0) {
        final statusCode = await registerProvider.registerAccount(data);
        if (statusCode == 200) {
          UtilityMethods.speak(flutterTts, "Đăng ký tài khoản thành công");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: AppThemePreferences.primaryColor,
            content: const Text("Đăng ký tài khoản thành công!"),
          ));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else if (statusCode == 500) {
          UtilityMethods.speak(
              flutterTts, "Số điện thoại không đúng định dạng");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: AppThemePreferences.primaryColor,
            content: const Text("Số điện thoại không đúng định dạng!"),
          ));
        } else {
          UtilityMethods.speak(flutterTts, "Số điện thoại đã tồn tại");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: AppThemePreferences.primaryColor,
            content: const Text("Số điện thoại đã tồn tại!"),
          ));
        }
      } else {
        UtilityMethods.speak(
            flutterTts, "Mật khẩu và xác nhận mật khẩu không khớp nhau");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppThemePreferences.primaryColor,
          content: const Text("Mật khẩu và xác nhận mật khẩu không khớp nhau"),
        ));
      }
    } else {
      UtilityMethods.speak(flutterTts, "Bạn hãy điền đầy đủ thông tin");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppThemePreferences.primaryColor,
        content: const Text("Bạn hãy điền đầy đủ thông tin"),
      ));
    }
  }

  @override
  void dispose() {
    super.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              logoWidget(),
              welcomeWidget(),
              SizedBox(
                height: 5,
              ),
              slogunWidget(),
              SizedBox(
                height: 30,
              ),
              textFieldWidget(
                  controller: _fullNameController,
                  hintText: "Tên đầy đủ...",
                  prefixIcon: Icons.person),
              SizedBox(
                height: 20,
              ),
              textFieldWidget(
                  controller: _phoneNumberController,
                  hintText: "Số điện thoại...",
                  prefixIcon: Icons.phone),
              SizedBox(
                height: 20,
              ),
              passwordWidget(),
              SizedBox(
                height: 20,
              ),
              confirmPasswordWidget(),
              SizedBox(
                height: 30,
              ),
              registerButtonWidget(),
              SizedBox(
                height: 15,
              ),
              backtButtonWidget()
            ],
          ),
        ),
      )),
    );
  }

  Widget logoWidget() {
    return SizedBox(
        height: 130,
        width: 130,
        child: Image.asset(
          "assets/logo.png",
          fit: BoxFit.contain,
        ));
  }

  Widget welcomeWidget() {
    return Text(
      "Đăng ký NewsPaper ",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
    );
  }

  Widget slogunWidget() {
    return Text(
      "Đọc báo là cách tuyệt vời để nâng cao tinh thần và tìm kiếm động lực mới mỗi ngày",
      style: TextStyle(
          color: Colors.black, fontSize: 16, fontStyle: FontStyle.italic),
    );
  }

  Widget textFieldWidget(
      {required TextEditingController controller,
      required String hintText,
      required IconData prefixIcon}) {
    return TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(width: 0.8),
          ),
          hintText: hintText,
          prefixIcon: Icon(prefixIcon),
        ));
  }

  Widget passwordWidget() {
    return TextField(
        controller: _passwordController,
        obscureText: obscure ? true : false,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(width: 0.8),
            ),
            hintText: "Mật khẩu...",
            prefixIcon: Icon(obscure ? Icons.lock_open : Icons.lock),
            suffixIcon: GestureDetector(
              onTap: () {
                if (mounted) {
                  setState(() {
                    obscure = !obscure;
                  });
                }
              },
              child: Icon(
                obscure ? Icons.remove_red_eye : Icons.visibility_off,
              ),
            )));
  }

  Widget confirmPasswordWidget() {
    return TextField(
        controller: _confirmPasswordController,
        obscureText: obscureConfirm ? true : false,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(width: 0.8),
            ),
            hintText: "Xác nhận Mật khẩu...",
            prefixIcon: Icon(obscureConfirm ? Icons.lock_open : Icons.lock),
            suffixIcon: GestureDetector(
              onTap: () {
                if (mounted) {
                  setState(() {
                    obscureConfirm = !obscureConfirm;
                  });
                }
              },
              child: Icon(
                obscureConfirm ? Icons.remove_red_eye : Icons.visibility_off,
              ),
            )));
  }

  Widget registerButtonWidget() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: AppThemePreferences.secondPrimaryColor),
        onPressed: handleRegister,
        child: Text(
          'Tạo tài khoản',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget backtButtonWidget() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
            elevation: 0,
            side: const BorderSide(
              width: 1.0,
              color: Colors.grey,
            )),
        child: Text(
          'Quay lại',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
