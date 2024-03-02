import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class AppThemePreferences {
  static Color primaryColor = Colors.grey;
  static Color primaryColorLight = Colors.grey[300]!;
  static Color closeIconColor = Colors.grey[500]!;
  static Color secondPrimaryColor = Colors.brown;
  static Color inactiveColorPrimary = Colors.grey[600]!;
  static Color activeColorPrimary = Colors.grey[400]!;
}

class AppDataPreferences {
  static List<PersistentBottomNavBarItem> bottomNavBarItems() {
    return [
      PersistentBottomNavBarItem(
        inactiveIcon: Icon(
          Icons.home,
          color: AppThemePreferences.activeColorPrimary,
        ),
        icon: Icon(
          Icons.home,
          color: AppThemePreferences.inactiveColorPrimary,
        ),
        title: "Trang chủ",
        activeColorPrimary: AppThemePreferences.inactiveColorPrimary,
        inactiveColorPrimary: AppThemePreferences.activeColorPrimary,
      ),
      PersistentBottomNavBarItem(
        inactiveIcon: Icon(
          Icons.category,
          color: AppThemePreferences.activeColorPrimary,
        ),
        icon: Icon(
          Icons.category,
          color: AppThemePreferences.inactiveColorPrimary,
        ),
        title: "Thể loại",
        activeColorPrimary: AppThemePreferences.inactiveColorPrimary,
        inactiveColorPrimary: AppThemePreferences.activeColorPrimary,
      ),
      PersistentBottomNavBarItem(
        inactiveIcon: Icon(
          Icons.search,
          color: AppThemePreferences.activeColorPrimary,
        ),
        icon: Icon(
          Icons.search,
          color: AppThemePreferences.inactiveColorPrimary,
        ),
        title: "Tìm kiếm",
        activeColorPrimary: AppThemePreferences.inactiveColorPrimary,
        inactiveColorPrimary: AppThemePreferences.activeColorPrimary,
      ),
      PersistentBottomNavBarItem(
        inactiveIcon: Icon(
          Icons.history,
          color: AppThemePreferences.activeColorPrimary,
        ),
        icon: Icon(
          Icons.history,
          color: AppThemePreferences.inactiveColorPrimary,
        ),
        title: "Lịch sử",
        activeColorPrimary: AppThemePreferences.inactiveColorPrimary,
        inactiveColorPrimary: AppThemePreferences.activeColorPrimary,
      ),
      PersistentBottomNavBarItem(
        inactiveIcon: Icon(
          Icons.person,
          color: AppThemePreferences.activeColorPrimary,
        ),
        icon: Icon(
          Icons.person,
          color: AppThemePreferences.inactiveColorPrimary,
        ),
        title: "Thông tin",
        activeColorPrimary: AppThemePreferences.inactiveColorPrimary,
        inactiveColorPrimary: AppThemePreferences.activeColorPrimary,
      ),
    ];
  }
}
