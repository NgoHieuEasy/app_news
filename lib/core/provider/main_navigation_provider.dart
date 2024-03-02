import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class MainNavigationController extends ChangeNotifier {
  int indexDrawerTitle = 0;

  PersistentTabController persistentTabController =
      PersistentTabController(initialIndex: 0);

  var scaffoldKey = GlobalKey<ScaffoldState>();

  void setIndexDrawer(int index) {
    indexDrawerTitle = index;
    notifyListeners();
  }

  void changeTabIndex(int index) async {
    persistentTabController.index = index;
    notifyListeners();
  }
}
