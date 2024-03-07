import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:read_paper/core/data/data.dart';
import 'package:read_paper/core/files/app_preferences/app_preferences.dart';
import 'package:read_paper/core/files/generic_methods/utility_methods.dart';
import 'package:read_paper/core/widgets/article/article_item.dart';
import 'package:read_paper/src/viewmodal/categories/categories_viewmodel.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ArticleListPage extends StatefulWidget {
  final String name;
  final int id;
  const ArticleListPage({super.key, required this.id, required this.name});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  SpeechToText speechToText = SpeechToText();
  FlutterTts flutterTts = FlutterTts();
// getListByCategoryId
  List<int> articleIdList = [];
  void initState() {
    super.initState();
    fetchArticle();
    initSpeech();
  }

  void initSpeech() async {
    await speechToText.initialize();
    UtilityMethods.speak(flutterTts, "Bài báo ${widget.name}");
  }

  fetchArticle() async {
    final categoryProvider =
        Provider.of<CategoriesViewModel>(context, listen: false);
    await categoryProvider.getListByCategoryId(widget.id);
    articleIdList = categoryProvider.articleIdList;
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider =
        Provider.of<CategoriesViewModel>(context, listen: false);
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
      body: categoryProvider.articleList.isNotEmpty
          ? Padding(
              padding: EdgeInsets.all(10),
              child: ListView.builder(
                itemCount: categoryProvider.articleList.length,
                itemBuilder: (context, index) {
                  var item = categoryProvider.articleList[index];
                  return ArticleItem(
                      item: item, heroId: 444, articleIdList: articleIdList);
                },
              ),
            )
          : Center(
              child: Text("Không có bài báo nào"),
            ),
    );
  }
}
