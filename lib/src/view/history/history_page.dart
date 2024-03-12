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
  Future<List<dynamic>>? _futureHistoryArticleList;
  List<int> articleIdList = [];
  @override
  void initState() {
    loadDataFromApi(); // TODO: implement initState
    super.initState();
  }

  loadDataFromApi() {
    setState(() {
      _futureHistoryArticleList = fetchHistoryArticleInfo();
    });
  }

  Future<List<dynamic>> fetchHistoryArticleInfo() async {
    final articleProvider =
        Provider.of<ArticleViewModel>(context, listen: false);
    List<dynamic> articleList = await articleProvider.getHistoryArticleList();
    if (articleList.isNotEmpty) {
      return articleList;
    }
    return [];
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
      body: Stack(children: [
        SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          header: const MaterialClassicHeader(),
          controller: _refreshController,
          onRefresh: () {
            loadDataFromApi();
            _refreshController.refreshCompleted();
          },
          child: buildArticleList(context, _futureHistoryArticleList!),
        )
      ]),
    );
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
