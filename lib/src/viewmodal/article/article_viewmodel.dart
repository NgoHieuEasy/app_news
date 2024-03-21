import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:read_paper/core/constants/constants.dart';
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

  Future<List<dynamic>> getSingleArticle(int id) async {
    String base_url = "/article/get-detail/$id";

    var response = await ApiProvider().get(base_url);

    List<Article> newArticleList = [];
    newArticleList.add(Article.fromJson(response));

    if (newArticleList.isNotEmpty) {
      return newArticleList;
    }

    return [];
  }

  updateSingleArticleList(List<Article> newArticleList) {}

  clearArray() {
    if (singleArticleList.isNotEmpty) {
      singleArticleList.clear();
      notifyListeners();
    }
  }

  Future<List<dynamic>> getArticleList(int page) async {
    String base_url = "/article/get-list?page=$page";

    var response = await ApiProvider().get(base_url);

    List<Article> articleList =
        response.map<Article>((item) => Article.fromJson(item)).toList();

    if (articleList.isNotEmpty) {
      return articleList;
    }
    return [];
  }

  Future<List<dynamic>> getRelateArticleList(int id) async {
    String base_url = "/article/get-all-category-page?categoryId=$id";
    var response = await ApiProvider().get(base_url);

    List<Article> relateArticleList =
        response.map<Article>((item) => Article.fromJson(item)).toList();
    if (relateArticleList.isNotEmpty) {
      return relateArticleList;
    }
    return [];
  }

  Future<List<dynamic>> getHistoryArticleList() async {
    String base_url = "/history-article/get-all-by-username";
    var response = await ApiProvider().get(base_url);
    List<Article> articleList =
        response.map<Article>((item) => Article.fromJson(item)).toList();
    if (articleList.isNotEmpty) {
      return articleList;
    }
    return [];
  }

  Future<List<dynamic>> getArticleListByTitle(String param) async {
    String base_url = "/article/get-list-by-title?title=$param";
    var response = await ApiProvider().get(base_url);
    List<Article> searchArticleList =
        response.map<Article>((item) => Article.fromJson(item)).toList();
    if (searchArticleList.isNotEmpty) {
      log(searchArticleList.toString());
      return searchArticleList;
    }
    return [];
  }

  setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }
}
