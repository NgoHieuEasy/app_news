import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:read_paper/core/helper/network.dart';
import 'package:read_paper/src/model/article.dart';
import 'package:read_paper/src/model/category.dart';

class ArticleViewModel extends ChangeNotifier {
  List<Article> articleList = [];
  List<Article> searchArticleList = [];
  List<Article> relateArticleList = [];
  List<Article> historyArticleList = [];
  List<Article> singleArticleList = [];
  List<int> articleIdList = [];
  bool isLoading = false;
  ArticleViewModel() {
    // getArticleList();
  }

  getArticleIdList(List<Article> articleList) {
    articleIdList = [];

    articleList.forEach((element) {
      articleIdList.add(element.id!);
    });
  }

  getSingleArticle(int id) async {
    String base_url = "/article/get-detail/$id";

    var response = await ApiProvider().get(base_url);

    List<Article> newArticleList = [];
    newArticleList.add(Article.fromJson(response));

    updateSingleArticleList(newArticleList);
  }

  updateSingleArticleList(List<Article> newArticleList) {
    singleArticleList = newArticleList;
    notifyListeners();
  }

  clearArray() {
    if (singleArticleList.isNotEmpty) {
      singleArticleList.clear();
      notifyListeners();
    }
  }

  getArticleList(int page, bool isPag) async {
    String base_url = "/article/get-list?page=$page";

    var response = await ApiProvider().get(base_url);

    if (isPag) {
      articleList.addAll(
          response.map<Article>((item) => Article.fromJson(item)).toList());
      getArticleIdList(articleList);
    } else {
      articleList =
          response.map<Article>((item) => Article.fromJson(item)).toList();
      getArticleIdList(articleList);
    }

    notifyListeners();
  }

  getSearchArticleList() async {
    String base_url = "/article/get-list?page=0";
    var response = await ApiProvider().get(base_url);

    searchArticleList =
        response.map<Article>((item) => Article.fromJson(item)).toList();
    getArticleIdList(searchArticleList);

    notifyListeners();
  }

  getRelateArticleList(int id) async {
    String base_url = "/article/get-all-category-page?categoryId=$id";
    var response = await ApiProvider().get(base_url);

    relateArticleList =
        response.map<Article>((item) => Article.fromJson(item)).toList();
    getArticleIdList(relateArticleList);
    notifyListeners();
  }

  getHistoryArticleList() async {
    String base_url = "/history-article/get-all-by-username";
    var response = await ApiProvider().get(base_url);

    historyArticleList =
        response.map<Article>((item) => Article.fromJson(item)).toList();
    getArticleIdList(historyArticleList);
    notifyListeners();
  }

  getArticleListByTitle(String param) async {
    String base_url = "/article/get-list-by-title?title=$param";
    setLoading(true);
    var response = await ApiProvider().get(base_url);
    setLoading(false);
    searchArticleList =
        response.map<Article>((item) => Article.fromJson(item)).toList();
    getArticleIdList(searchArticleList);

    notifyListeners();
  }

  setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }
}
