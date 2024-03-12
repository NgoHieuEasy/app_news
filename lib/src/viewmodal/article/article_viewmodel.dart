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
      if (newArticleList[0].mp3Url1 == "") {
        String base_url_mp3 = "/create_voice";
        Map<String, dynamic> data = {"article_id": newArticleList[0].id};
        final response = await ApiProvider().post_voice(base_url_mp3, data);

        if (response.statusCode == 200) {
          newArticleList[0].mp3Url1 = response.data['data'];
        } else {
          log('mp3 call api voice mp3');
        }
      }
      return newArticleList;
    }

    return [];

    // singleArticleList = newArticleList;
    // log('tới đây thôi');
    // if (singleArticleList[0].mp3Url1 == 'null') {
    //   String base_url = "/create_voice";
    //   Map<String, dynamic> data = {"article_id": id.toString()};
    //   var response = await ApiProvider().post_voide(base_url, data);

    //   if (response != null && response.data != null) {
    //     singleArticleList[0].mp3Url1 = response.data['data'];
    //   } else {
    //     log("trường hợp phản hồi không hợp lệ");
    //   }
    // }
    // notifyListeners();
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

    // if (isPag) {
    //   articleList.addAll(
    //       response.map<Article>((item) => Article.fromJson(item)).toList());
    // } else {
    //   articleList =
    //       response.map<Article>((item) => Article.fromJson(item)).toList();
    // }
    // getArticleIdList(articleList);

    // notifyListeners();
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
