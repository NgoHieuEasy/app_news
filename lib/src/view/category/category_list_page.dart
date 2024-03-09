import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:read_paper/core/widgets/shimmer_effect.dart';
import 'package:read_paper/main.dart';
import 'package:read_paper/src/model/category.dart';
import 'package:read_paper/src/view/category/article_list_page.dart';
import 'package:read_paper/src/viewmodal/categories/categories_viewmodel.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  List<dynamic> parentList = [];
  List<dynamic> childList = [];

  @override
  void initState() {
    fetchArticle(); // TODO: implement initState
    super.initState();
  }

  fetchArticle() async {
    final categoryProvider =
        Provider.of<CategoriesViewModel>(context, listen: false);
    List<dynamic> cateList = await categoryProvider.getAllCategories();
    for (dynamic categoryItem in cateList) {
      var parentId = categoryItem.parentId;
      if (parentId == null) {
        parentList.add(categoryItem);
      } else {
        childList.add(categoryItem);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoriesViewModel>(context);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: GestureDetector(
                onTap: () {}, child: Image.asset("assets/logo.png")),
          ),
        ),
        body: parentList.isNotEmpty
            ? ListView.builder(
                itemCount: parentList.length,
                itemBuilder: (context, index) {
                  var parentCategory = parentList[index];

                  return Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                builder: (context) => ArticleListPage(
                                  id: int.parse(parentCategory.id!.toString()),
                                  name: parentCategory.name!,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 5, bottom: 20, top: 10),
                            width: double.infinity,
                            child: Text(
                              parentCategory.name,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: childList.map((child) {
                            if (parentCategory.id.toString() ==
                                child.parentId.toString()) {
                              return InkWell(
                                onTap: () {
                                  navigatorKey.currentState?.push(
                                    MaterialPageRoute(
                                      builder: (context) => ArticleListPage(
                                        id: int.parse(child.id!.toString()),
                                        name: child.name!,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    bottom: 20,
                                  ),
                                  width: double.infinity,
                                  child: Text(
                                    "• ${child.name}",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              );
                            }
                            return Container();
                          }).toList(),
                        )
                      ],
                    ),
                  );
                },
              )
            : shimmerLoading());
  }

  Widget shimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: shimmerCategoryLoading(),
    );
  }
}
