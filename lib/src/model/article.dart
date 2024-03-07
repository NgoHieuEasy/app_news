class Article {
  final int? id;
  final String? crawlUrl;
  final String? title;
  final String? subTitle;
  final dynamic author;
  final String? htmlContent;
  final String? textContent;
  final int? categoryId;
  final String? categoryName;
  final String? thumb;
  final String? thumbM;
  dynamic mp3Url1;
  final dynamic mp3Url2;
  final dynamic mp3Url3;
  final dynamic mp3Url4;
  final dynamic mp3Url5;
  final int? createdAt;
  final int? updatedAt;
  final int? publishedAt;

  Article({
    this.id,
    this.crawlUrl,
    this.title,
    this.subTitle,
    this.author,
    this.htmlContent,
    this.textContent,
    this.categoryId,
    this.categoryName,
    this.thumb,
    this.thumbM,
    this.mp3Url1,
    this.mp3Url2,
    this.mp3Url3,
    this.mp3Url4,
    this.mp3Url5,
    this.createdAt,
    this.updatedAt,
    this.publishedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        id: json["id"] != null ? json["id"] : 00,
        crawlUrl: json["crawlUrl"] != null ? json["crawlUrl"] : "",
        title: json["title"] != null ? json["title"] : "",
        subTitle: json["subTitle"] != null ? json["subTitle"] : "",
        author: json["author"] != null ? json["author"] : "",
        htmlContent: json["htmlContent"] != null ? json["htmlContent"] : "",
        textContent: json["textContent"] != null ? json["textContent"] : "",
        categoryId: json["categoryId"] != null ? json["categoryId"] : 00,
        categoryName: json["categoryName"] != null ? json["categoryName"] : "",
        thumb: json["thumb"] != null ? json["thumb"] : "",
        thumbM: json["thumbM"] != null ? json["thumbM"] : "",
        mp3Url1: json["mp3Url1"] != null ? json["mp3Url1"] : 'null',
        mp3Url2: json["mp3Url2"] != null ? json["mp3Url2"] : "",
        mp3Url3: json["mp3Url3"] != null ? json["mp3Url3"] : "",
        mp3Url4: json["mp3Url4"] != null ? json["mp3Url4"] : "",
        mp3Url5: json["mp3Url5"] != null ? json["mp3Url5"] : "",
        createdAt: json["createdAt"] != null ? json["createdAt"] : 00,
        updatedAt: json["updatedAt"] != null ? json["updatedAt"] : 00,
        publishedAt: json["publishedAt"] != null ? json["publishedAt"] : 00,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "crawlUrl": crawlUrl,
        "title": title,
        "subTitle": subTitle,
        "author": author,
        "htmlContent": htmlContent,
        "textContent": textContent,
        "categoryId": categoryId,
        "categoryName": categoryName,
        "thumb": thumb,
        "thumbM": thumbM,
        "mp3Url1": mp3Url1,
        "mp3Url2": mp3Url2,
        "mp3Url3": mp3Url3,
        "mp3Url4": mp3Url4,
        "mp3Url5": mp3Url5,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "publishedAt": publishedAt,
      };
}
