import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_paper/core/widgets/article/article_item.dart';
import 'package:read_paper/core/data/data.dart';
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
  @override
  void initState() {
    // fetchArticle(); // TODO: implement initState
    super.initState();
  }

  fetchArticle() {
    final articleProvider =
        Provider.of<ArticleViewModel>(context, listen: false);
    articleProvider.getSearchArticleList();
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
                    FocusScope.of(context).requestFocus(FocusNode());
                    await articleProvider
                        .getArticleListByTitle(_searchController.text);

                    _searchController.text = '';
                    articleIdList = articleProvider.articleIdList;
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
            !articleProvider.isLoading
                ? Expanded(
                    child: articleProvider.searchArticleList.isNotEmpty
                        ? ListView.builder(
                            itemCount: articleProvider.searchArticleList.length,
                            itemBuilder: (context, index) {
                              var item =
                                  articleProvider.searchArticleList[index];
                              return ArticleItem(
                                  item: item,
                                  heroId: 222,
                                  articleIdList: articleIdList);
                            },
                          )
                        : Center(
                            child: Text("Nhập tên bài báo bạn muốn tìm kiếm")),
                  )
                : Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }
}
