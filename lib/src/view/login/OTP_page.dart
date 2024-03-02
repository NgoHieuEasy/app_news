import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:read_paper/core/files/app_preferences/app_preferences.dart';
import 'package:read_paper/core/files/generic_methods/utility_methods.dart';
import 'package:read_paper/core/provider/main_navigation_provider.dart';
import 'package:read_paper/main.dart';
import 'package:read_paper/src/view/login/login_page.dart';
import 'package:read_paper/src/view/login/reset_password_page.dart';
import 'package:read_paper/src/view/main_navigation/main_navigation.dart';
import 'package:read_paper/src/viewmodal/login/login_viewmodel.dart';
import 'package:speech_to_text/speech_to_text.dart';

class OTPPage extends StatefulWidget {
  final String numberPhone;
  const OTPPage({super.key, required this.numberPhone});

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  int amountOTP = 0;
  List<TextEditingController> controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  SpeechToText speechToText = SpeechToText();
  FlutterTts flutterTts = FlutterTts();
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

  submitOTP() async {
    String otp = controllers.fold(
        '', (previousValue, controller) => previousValue + controller.text);

    if (amountOTP >= 5) {
      setState(() {
        isLoading = true;
      });
      final navigaProvider =
          Provider.of<MainNavigationController>(context, listen: false);
      final loginProvider = Provider.of<LoginViewModel>(context, listen: false);
      final statusCode = await loginProvider.veritifyOTP(
          phoneNumber: widget.numberPhone, code: otp);
      if (statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        navigatorKey.currentState?.push(
          MaterialPageRoute(
              builder: (context) =>
                  ResetPasswordPage(numberPhone: widget.numberPhone)),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        UtilityMethods.speak(flutterTts, "Mã OTP không chính xác");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppThemePreferences.primaryColor,
          content: const Text("Mã OTP không chính xác"),
        ));
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Nhập mã OTP',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 40.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 40.0,
                    height: 40.0,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: TextField(
                        controller: controllers[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          counter: Offstage(),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              amountOTP = index;
                            });

                            print(amountOTP);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              continueButtonWidget(),
              SizedBox(
                height: 20,
              ),
              backtButtonWidget()
            ],
          ),
        ),
      ),
    );
  }

  Widget continueButtonWidget() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: AppThemePreferences.secondPrimaryColor),
        onPressed: !isLoading ? submitOTP : () {},
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
