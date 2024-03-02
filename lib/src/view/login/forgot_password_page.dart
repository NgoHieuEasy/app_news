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
import 'package:read_paper/src/view/main_navigation/main_navigation.dart';
import 'package:read_paper/src/view/register/register_page.dart';
import 'package:read_paper/src/viewmodal/login/login_viewmodel.dart';
import 'package:read_paper/src/viewmodal/register/register_viewmodel.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<ForgotPasswordPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  SpeechToText speechToText = SpeechToText();
  FlutterTts flutterTts = FlutterTts();
  bool obscure = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    await speechToText.initialize();
    setState(() {});
  }

  handleContinue() async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (_phoneNumberController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      final navigaProvider =
          Provider.of<MainNavigationController>(context, listen: false);
      final loginProvider = Provider.of<LoginViewModel>(context, listen: false);
      final statusCode = await loginProvider
          .sendOTPPassword(_phoneNumberController.text.trim());
      if (statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        navigatorKey.currentState?.push(
          MaterialPageRoute(
              builder: (context) => OTPPage(
                    numberPhone: _phoneNumberController.text.trim(),
                  )),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        UtilityMethods.speak(flutterTts, "Số điện thoại không tồn tại");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppThemePreferences.primaryColor,
          content: const Text("Số điện thoại không tồn tại!"),
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
                height: 30,
              ),
              continuteButtonWidget(),
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
      "Quên mật khẩu NewsPaper ",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
    );
  }

  Widget slogunWidget() {
    return Text(
      "Hãy nhập số điện thoại để lấy lại mật khẩu",
      style: TextStyle(
          color: Colors.black, fontSize: 16, fontStyle: FontStyle.italic),
    );
  }

  Widget forgotPassWidget() {
    return Align(
      alignment: Alignment.centerRight,
      child: Text("Quên mật khẩu?"),
    );
  }

  Widget continuteButtonWidget() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: AppThemePreferences.secondPrimaryColor),
        onPressed: !isLoading ? handleContinue : () {},
        child: !isLoading
            ? Text(
                'Tiếp tục',
                style: TextStyle(color: Colors.white),
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget backtButtonWidget() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          navigatorKey.currentState?.pop();
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
