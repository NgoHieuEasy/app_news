import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:read_paper/core/data/data.dart';
import 'package:read_paper/core/files/app_preferences/app_preferences.dart';
import 'package:read_paper/core/files/generic_methods/utility_methods.dart';
import 'package:read_paper/core/widgets/article/article_item.dart';
import 'package:read_paper/core/widgets/shimmer_effect.dart';
import 'package:read_paper/src/viewmodal/categories/categories_viewmodel.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:developer';

class ArticleListPage extends StatefulWidget {
  final String name;
  final int id;
  final bool isParent;
  const ArticleListPage(
      {super.key,
      required this.id,
      required this.name,
      required this.isParent});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  SpeechToText speechToText = SpeechToText();
  FlutterTts flutterTts = FlutterTts();
  Future<List<dynamic>>? _futureArticleList;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<int> articleIdList = [];
  void initState() {
    super.initState();
    loadDataFromApi();
    initSpeech();
  }

  void initSpeech() async {
    await speechToText.initialize();
    UtilityMethods.speak(flutterTts, "Bài báo ${widget.name}");
  }

  loadDataFromApi() {
    setState(() {
      _futureArticleList = fetchArticleInfo();
    });
  }

  Future<List<dynamic>> fetchArticleInfo() async {
    final categoryProvider =
        Provider.of<CategoriesViewModel>(context, listen: false);
    List<dynamic> articleList =
        await categoryProvider.getListByCategoryId(widget.id, widget.isParent);
    if (articleList != null) {
      return articleList;
    }

    return [];
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
              iconSize: 30,
              icon: Icon(
                Icons.close_rounded,
                color: AppThemePreferences.closeIconColor,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          elevation: 0,
        ),
        body: buildArticleList(context, _futureArticleList!));
  }

  Widget buildArticleList(
      BuildContext context, Future<List<dynamic>> futureArticleList) {
    return FutureBuilder<List<dynamic>>(
      future: futureArticleList,
      builder: (context, dataSnapshot) {
        if (dataSnapshot.hasData) {
          if (dataSnapshot.data!.isEmpty) {
            return Center(
              child: Text("Không có bài báo nào"),
            );
          } else if (dataSnapshot.data!.isNotEmpty) {
            List articleList = dataSnapshot.data!;
            return Padding(
              padding: EdgeInsets.all(10),
              child: ListView.builder(
                itemCount: articleList.length,
                itemBuilder: (context, index) {
                  var item = articleList[index];
                  return ArticleItem(
                      item: item, heroId: 444, articleIdList: articleIdList);
                },
              ),
            );
          }
        }
        return shimmerLoading();
      },
    );
  }

  Widget shimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: shimmerCategoryLoading(),
    );
  }
}
