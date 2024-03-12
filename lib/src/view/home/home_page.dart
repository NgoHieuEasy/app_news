import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_paper/core/widgets/article/article_item.dart';
import 'package:read_paper/core/widgets/shimmer_effect.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:read_paper/src/viewmodal/article/article_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int page = 0;
  bool isLoading = false;
  List<int> articleIdList = [];
  List<dynamic> articleAllList = [];
  Future<List<dynamic>>? _futureArticleList;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    loadDataFromApi();
    super.initState();
  }

  loadDataFromApi() {
    setState(() {
      _futureArticleList = fetchArticleInfo();
    });
  }

  Future<List<dynamic>> fetchArticleInfo() async {
    final articleProvider =
        Provider.of<ArticleViewModel>(context, listen: false);
    List<dynamic> articleList = await articleProvider.getArticleList(page);
    if (articleList.isNotEmpty) {
      articleAllList = articleList;
      //get id
      articleAllList.forEach((element) {
        articleIdList.add(element.id!);
      });
      return articleAllList;
    }
    return [];
  }

  onLoading(int page) async {
    setState(() {
      isLoading = true;
    });
    final articleProvider =
        Provider.of<ArticleViewModel>(context, listen: false);
    List<dynamic> articleList = await articleProvider.getArticleList(page);
    if (articleList.isNotEmpty) {
      setState(() {
        articleAllList.addAll(articleList);
      });

      articleAllList.forEach((element) {
        articleIdList.add(element.id!);
      });
      setState(() {
        isLoading = false;
      });
      _refreshController.loadComplete();
    } else {
      setState(() {
        isLoading = false;
      });
      _refreshController.loadComplete();
    }
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
            return SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              header: const MaterialClassicHeader(),
              controller: _refreshController,
              onRefresh: () {
                _refreshController.refreshCompleted();
              },
              onLoading: () async {
                page++;
                onLoading(page);
              },
              footer: CustomFooter(
                builder: (BuildContext context, LoadStatus? mode) {
                  if (isLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              child: ListView.builder(
                itemCount: articleAllList.length,
                itemBuilder: (context, index) {
                  var item = articleAllList[index];
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
