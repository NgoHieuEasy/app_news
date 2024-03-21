import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:read_paper/core/files/generic_methods/utility_methods.dart';
import 'package:read_paper/core/widgets/article/article_detail_page.dart';
import 'package:read_paper/core/widgets/shimmer_effect_error_widget.dart';
import 'package:read_paper/main.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class ArticleItem extends StatefulWidget {
  final dynamic item;
  final int heroId;
  final List<int> articleIdList;
  const ArticleItem({
    super.key,
    required this.item,
    required this.heroId,
    required this.articleIdList,
  });

  @override
  State<ArticleItem> createState() => _ArticleItemState();
}

class _ArticleItemState extends State<ArticleItem> {
  dynamic item;
  DateTime? dateTime;
  @override
  void initState() {
    item = widget.item;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int id = item.id ?? 0;
    int catId = item.categoryId ?? 00;
    String title = item.title ?? '-/-';
    String categoryName = item.categoryName ?? '-/-';
    String audioUrl = item.mp3Url1 ?? '';
    String image = item!.thumb ?? '-/-';
    String description = UtilityMethods.truncateDescription(item.textContent);
    String htmlContent = item.htmlContent ?? '-/-';
    String publishedAt = UtilityMethods.formatUnixTime(item.publishedAt);
    String share = '-/-';
    String download = '-/-';
    String copy = '-/-';
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
              Map dataDetail = {
                "id": id,
                "catId": catId,
                "heroId": id + widget.heroId,
                "title": title,
                "audioUrl": audioUrl,
                "image": '',
                "description": description,
                "htmlContent": htmlContent,
              };
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) => ArticleDetailPage(
                    articleIdList: widget.articleIdList,
                    dataMap: dataDetail,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 70,
                        width: 70,
                        child: Hero(
                          tag: id + widget.heroId,
                          child: FancyShimmerImage(
                            imageUrl: image,
                            boxFit: BoxFit.cover,
                            shimmerBaseColor: Colors.grey[300],
                            shimmerHighlightColor: Colors.grey[100],
                            errorWidget:
                                const ShimmerEffectErrorWidget(iconSize: 50),
                          ),
                        )),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$categoryName - $title",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          Text("Ngày đăng: $publishedAt")
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
