import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:read_paper/core/widgets/article/article_item.dart';
import 'package:read_paper/core/widgets/shimmer_effect.dart';
import 'package:read_paper/src/viewmodal/article/article_viewmodel.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  @override
  void initState() {
    fetchHistoryArticle(); // TODO: implement initState
    super.initState();
  }

  fetchHistoryArticle() {
    final articleProvider =
        Provider.of<ArticleViewModel>(context, listen: false);
    articleProvider.getHistoryArticleList();
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
        child: articleProvider.historyArticleList.isNotEmpty
            ? SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                header: const MaterialClassicHeader(),
                controller: _refreshController,
                onRefresh: () {
                  fetchHistoryArticle();
                  _refreshController.refreshCompleted();
                },
                child: ListView.builder(
                  itemCount: articleProvider.historyArticleList.length,
                  itemBuilder: (context, index) {
                    var item = articleProvider.articleList[index];
                    return ArticleItem(
                      item: item,
                      heroId: 333,
                    );
                  },
                ),
              )
            : Center(child: Text("Không có dữ liệu")),
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
