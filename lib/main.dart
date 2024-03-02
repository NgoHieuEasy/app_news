import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_paper/core/files/app_preferences/app_preferences.dart';
import 'package:read_paper/core/files/hive_storage_file/hive_storage_manager.dart';
import 'package:read_paper/core/provider/main_navigation_provider.dart';
import 'package:read_paper/src/my_home_page.dart';
import 'package:read_paper/src/view/login/reset_password_page.dart';
import 'package:read_paper/src/viewmodal/article/article_viewmodel.dart';
import 'package:read_paper/src/viewmodal/categories/categories_viewmodel.dart';
import 'package:read_paper/src/viewmodal/login/login_viewmodel.dart';
import 'package:read_paper/src/viewmodal/register/register_viewmodel.dart';

final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveStorageManager.openHiveBox();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MainNavigationController(),
        ),
        ChangeNotifierProvider(
          create: (context) => CategoriesViewModel(),
        ),
        ChangeNotifierProvider(create: (context) => LoginViewModel()),
        ChangeNotifierProvider(create: (context) => RegisterViewModel()),
        ChangeNotifierProvider(create: (context) => ArticleViewModel()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Read Paper App',
        theme: ThemeData(
          primarySwatch: Colors.grey,
        ),
        initialRoute: '/',
        home: const MyHomePage(),
      ),
    );
  }
}
