import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:read_paper/core/helper/network.dart';
import 'package:read_paper/src/model/article.dart';
import 'package:read_paper/src/model/category.dart';

class CategoriesViewModel extends ChangeNotifier {
  CategoriesViewModel() {}

  Future<List<dynamic>> getAllCategories() async {
    String base_url = "/article/get-all-category";
    var resData = await ApiProvider().get(base_url);
    List<CategoryModel> allCategory = resData
        .map<CategoryModel>((item) => CategoryModel.fromJson(item))
        .toList();
    return allCategory;
  }

  Future<List<dynamic>> getListByCategoryId(int id, bool isParent) async {
    String base_url = '';

    if (isParent) {
      base_url = "/article/get-list-by-categoryId?categoryId=$id&type=parent";
    } else {
      base_url = "/article/get-list-by-categoryId?categoryId=$id&type=child";
    }
    var response = await ApiProvider().get(base_url);
    List<Article> articleList =
        response.map<Article>((item) => Article.fromJson(item)).toList();
    return articleList;
  }
}
