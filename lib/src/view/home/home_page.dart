import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_paper/core/widgets/article/article_item.dart';
import 'package:read_paper/core/widgets/shimmer_effect.dart';
import 'package:read_paper/core/widgets/shimmer_effect_error_widget.dart';
import 'package:read_paper/main.dart';
import 'package:read_paper/core/data/data.dart';
import 'package:read_paper/src/view/login/login_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:read_paper/src/viewmodal/article/article_viewmodel.dart';
import 'package:read_paper/src/viewmodal/categories/categories_viewmodel.dart';
import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int page = 0;
  bool isLoading = false;
  List<int> articleIdList = [];
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    fetchArticle();
    super.initState();
  }

  fetchArticle() {
    final articleProvider =
        Provider.of<ArticleViewModel>(context, listen: false);
    articleProvider.getArticleList(page, false);
  }

  // getAllData() {
  //   final categoryProvider = Provider.of<CategoriesViewModel>(context);
  // }

  void handlePagination() {
    final articleProvider =
        Provider.of<ArticleViewModel>(context, listen: false);
    setState(() {
      isLoading = true;
      page++;
    });
    articleProvider.getArticleList(page, true);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final articleProvider = Provider.of<ArticleViewModel>(context);
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
        child: articleProvider.articleList.isNotEmpty
            ? SmartRefresher(
                enablePullDown: false,
                enablePullUp: true,
                header: const MaterialClassicHeader(),
                controller: _refreshController,
                onRefresh: () => {},
                onLoading: () {
                  setState(() {
                    isLoading = true;
                    page++;
                  });
                  articleProvider.getArticleList(page, true).then((_) {
                    setState(() {
                      isLoading = false;
                    });
                    _refreshController.loadComplete();
                  });
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
                  itemCount: articleProvider.articleList.length,
                  itemBuilder: (context, index) {
                    var item = articleProvider.articleList[index];

                    articleIdList.add(item.id!);
                    return ArticleItem(
                      item: item,
                      heroId: 111,
                    );
                  },
                ),
              )
            : shimmerLoading(),
      ),
    );
  }

  Widget shimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: shimmerCategoryLoading(),
    );
  }
}
