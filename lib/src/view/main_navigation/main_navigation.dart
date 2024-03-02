import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:read_paper/core/files/app_preferences/app_preferences.dart';
import 'package:read_paper/core/files/generic_methods/utility_methods.dart';
import 'package:read_paper/core/files/hive_storage_file/hive_storage_manager.dart';
import 'package:read_paper/core/provider/main_navigation_provider.dart';
import 'package:read_paper/src/view/category/category_list_page.dart';
import 'package:read_paper/src/view/history/history_page.dart';
import 'package:read_paper/src/view/home/home_page.dart';
import 'package:read_paper/src/view/info/info_page.dart';
import 'package:read_paper/src/view/search/search_page.dart';
import 'package:read_paper/src/viewmodal/article/article_viewmodel.dart';
import 'package:speech_to_text/speech_to_text.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});
  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  bool isLoadingLocalData = false;

  SpeechToText speechToText = SpeechToText();
  FlutterTts flutterTts = FlutterTts();

  List<Widget> _screens(controller) {
    return [
      const HomePage(),
      const CategoryListPage(),
      const SearchPage(),
      const HistoryPage(),
      const InfoPage(),
    ];
  }

  void initSpeech() async {
    await speechToText.initialize();
    UtilityMethods.speak(flutterTts, "Bạn đang ở trang chủ");
  }

  void onItemSelected(int index) async {
    if (index == 0) {
      UtilityMethods.speak(flutterTts, "Bạn đang ở trang chủ");
    }
    if (index == 1) {
      UtilityMethods.speak(flutterTts, "Bạn đang ở trang thể loại");
    }

    if (index == 2) {
      UtilityMethods.speak(flutterTts, "Bạn đang ở trang tìm kiếm");
    }
    if (index == 3) {
      UtilityMethods.speak(flutterTts, "Bạn đang ở trang lịch sử đã xem");
    }
    if (index == 4) {
      UtilityMethods.speak(flutterTts, "Bạn đang ở trang thông tin cá nhân");
    }
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    final navigaProvider =
        Provider.of<MainNavigationController>(context, listen: false);
    return SafeArea(
      child: Scaffold(
        key: navigaProvider.scaffoldKey,
        drawerScrimColor: Colors.black.withOpacity(0.7),
        body: PersistentTabView(
          context,
          controller: navigaProvider.persistentTabController,
          screens: _screens(navigaProvider),
          items: AppDataPreferences.bottomNavBarItems(),
          hideNavigationBar: false,
          navBarHeight: 70,
          margin: EdgeInsets.all(0),
          padding: NavBarPadding.symmetric(horizontal: 5),
          onItemSelected: ((index) => onItemSelected(index)),
          confineInSafeArea: true,
          backgroundColor: Colors.white,
          handleAndroidBackButtonPress: true,
          resizeToAvoidBottomInset: true,
          stateManagement: true,
          hideNavigationBarWhenKeyboardShows: true,
          popAllScreensOnTapOfSelectedTab: true,
          popActionScreens: PopActionScreensType.all,
          itemAnimationProperties: ItemAnimationProperties(
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          ),
          screenTransitionAnimation: const ScreenTransitionAnimation(
            animateTabTransition: false,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          ),
          navBarStyle: NavBarStyle.style6,
        ),
        // floatingActionButton: FloatingActionButton(onPressed: () {
        //   final articleProvider =
        //       Provider.of<ArticleViewModel>(context, listen: false);
        //   articleProvider.getArticleList();
        // }),
      ),
    );
  }
}
