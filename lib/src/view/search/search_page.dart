import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_paper/core/files/app_preferences/app_preferences.dart';
import 'package:read_paper/core/widgets/article/article_item.dart';
import 'package:read_paper/core/data/data.dart';
import 'package:read_paper/core/widgets/shimmer_effect.dart';
import 'package:read_paper/src/view/search/widgets/filter_topic_widget.dart';
import 'package:read_paper/src/viewmodal/article/article_viewmodel.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  List<int> articleIdList = [];
  List<dynamic> articleSearchList = [];

  @override
  void initState() {
    super.initState();
  }

  loadDataFromApi(String param) async {
    setState(() {
      isLoading = true;
    });
    List<dynamic> result = await fetchArticleInfo(param);
    setState(() {
      articleSearchList = result;
      isLoading = false;
    });
  }

  Future<List<dynamic>> fetchArticleInfo(String param) async {
    final articleProvider =
        Provider.of<ArticleViewModel>(context, listen: false);
    List<dynamic> articleList =
        await articleProvider.getArticleListByTitle(param);

    if (articleList.isNotEmpty) {
      return articleList;
    }
    return [];
  }

  @override
  void dispose() {
    articleSearchList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Image.asset("assets/logo.png"),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(width: 0.8),
                      ),
                      hintText: 'Tìm kiếm bài báo...',
                    ),
                    onChanged: (value) {
                      print('Searching for: $value');
                    },
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                InkWell(
                  onTap: () async {
                    if (_searchController.text.length > 7) {
                      FocusScope.of(context).requestFocus(FocusNode());

                      loadDataFromApi(_searchController.text);
                      _searchController.text = '';
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: AppThemePreferences.primaryColor,
                        content: const Text("Hãy nhập trên 6 kí tự tìm kiếm"),
                      ));
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.search,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            buildArticleList()
          ],
        ),
      ),
    );
  }

  Widget buildArticleList() {
    return !isLoading
        ? articleSearchList.isNotEmpty
            ? Expanded(
                child: Padding(
                  padding: EdgeInsets.all(0),
                  child: ListView.builder(
                    itemCount: articleSearchList.length,
                    itemBuilder: (context, index) {
                      var item = articleSearchList[index];
                      return ArticleItem(
                          item: item,
                          heroId: 444,
                          articleIdList: articleIdList);
                    },
                  ),
                ),
              )
            : Expanded(
                child: Center(
                child: Text("Không có bài báo nào"),
              ))
        : Expanded(
            child: Center(
            child: CircularProgressIndicator(),
          ));
  }
}
