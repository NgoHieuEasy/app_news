import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_paper/core/files/app_preferences/app_preferences.dart';
import 'package:read_paper/core/files/generic_methods/utility_methods.dart';
import 'package:read_paper/core/provider/main_navigation_provider.dart';
import 'package:read_paper/main.dart';
import 'package:read_paper/src/view/home/home_page.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:read_paper/src/view/login/OTP_page.dart';
import 'package:read_paper/src/view/login/forgot_password_page.dart';
import 'package:read_paper/src/view/main_navigation/main_navigation.dart';
import 'package:read_paper/src/view/register/register_page.dart';
import 'package:read_paper/src/viewmodal/login/login_viewmodel.dart';
import 'package:read_paper/src/viewmodal/register/register_viewmodel.dart';
import 'package:speech_to_text/speech_to_text.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  SpeechToText speechToText = SpeechToText();
  FlutterTts flutterTts = FlutterTts();
  bool obscure = true;
  bool isLogin = false;

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    await speechToText.initialize();
    setState(() {});
  }

  handleLogin() async {
    FocusScope.of(context).requestFocus(FocusNode());
    Map<String, dynamic> data = {
      "username": _phoneNumberController.text.trim(),
      "password": _passwordController.text.trim(),
    };

    if (_phoneNumberController.text.isNotEmpty) {
      setState(() {
        isLogin = true;
      });
      final navigaProvider =
          Provider.of<MainNavigationController>(context, listen: false);
      final loginProvider = Provider.of<LoginViewModel>(context, listen: false);
      final statusCode = await loginProvider.loginAccount(data);
      if (statusCode == 200) {
        setState(() {
          isLogin = false;
        });
        navigaProvider.changeTabIndex(0);
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (context) => MainNavigationPage()),
        );
      } else {
        setState(() {
          isLogin = false;
        });
        UtilityMethods.speak(
            flutterTts, "Số điện thoại hoặc mật khẩu không chính xác");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppThemePreferences.primaryColor,
          content: const Text("Số điện thoại hoặc mật khẩu không chính xác!"),
        ));
      }
    } else {
      UtilityMethods.speak(flutterTts, "Số điện thoại không được trống");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppThemePreferences.primaryColor,
        content: const Text("Số điện thoại không được trống!"),
      ));
    }
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
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
            mainAxisAlignment: MainAxisAlignment.center,
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
              phoneWidget(),
              SizedBox(
                height: 20,
              ),
              passwordWidget(),
              SizedBox(
                height: 10,
              ),
              forgotPassWidget(),
              SizedBox(
                height: 30,
              ),
              loginButtonWidget(),
              SizedBox(
                height: 15,
              ),
              createAccountButtonWidget()
            ],
          ),
        ),
      )),
    );
  }

  Widget phoneWidget() {
    return TextField(
        controller: _phoneNumberController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(width: 0.8),
          ),
          hintText: 'Số điện thoại...',
          prefixIcon: Icon(Icons.phone),
        ));
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
      "Đăng nhập NewsPaper ",
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
            hintText: 'Mật khẩu...',
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

  Widget forgotPassWidget() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
        );
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: Text("Quên mật khẩu?"),
      ),
    );
  }

  Widget loginButtonWidget() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: AppThemePreferences.secondPrimaryColor),
        onPressed: !isLogin ? handleLogin : () {},
        child: !isLogin
            ? Text(
                'Đăng nhập',
                style: TextStyle(color: Colors.white),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  Widget createAccountButtonWidget() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterPage()),
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
          'Tạo tài khoản',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
