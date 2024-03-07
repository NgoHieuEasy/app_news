import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:read_paper/core/helper/network.dart';
import 'package:read_paper/src/model/article.dart';
import 'package:read_paper/src/model/category.dart';

class CategoriesViewModel extends ChangeNotifier {
  List<CategoryModel> allCategory = [];
  List<Article> articleList = [];
  List<int> articleIdList = [];

  CategoriesViewModel() {}

  getArticleIdList(List<Article> articleList) {
    articleIdList = [];

    articleList.forEach((element) {
      articleIdList.add(element.id!);
    });
  }

  Future<List<dynamic>> getAllCategories() async {
    String base_url = "/article/get-all-category";
    var resData = await ApiProvider().get(base_url);
    allCategory = resData
        .map<CategoryModel>((item) => CategoryModel.fromJson(item))
        .toList();
    return allCategory;
    // notifyListeners();
  }

  getListByCategoryId(int id) async {
    log(id.toString());
    String base_url = "/get-list-by-categoryId?categoryId=$id";
    var response = await ApiProvider().get(base_url);
    articleList =
        response.map<Article>((item) => Article.fromJson(item)).toList();
    getArticleIdList(articleList);
    notifyListeners();
  }
}
