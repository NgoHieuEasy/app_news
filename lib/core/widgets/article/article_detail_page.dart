import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';
import 'package:read_paper/core/files/app_preferences/app_preferences.dart';
import 'package:read_paper/core/widgets/article/article_item.dart';
import 'package:read_paper/src/viewmodal/article/article_viewmodel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ArticleDetailPage extends StatefulWidget {
  final Map dataMap;
  final List<int> articleIdList;
  ArticleDetailPage({
    super.key,
    required this.dataMap,
    required this.articleIdList,
  });

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  Map dataMap = {};

  late StateSetter _setStateSpeech;

  double _currentSliderValue = 0.5;

  int articleIndex = 0;
  int chunkIndex = 0;

  SpeechToText speechToText = SpeechToText();
  FlutterTts flutterTts = FlutterTts();
  List<PopupMenuItem<String>>? speedItems;

  String link_share = "";
  String link_Copy = "";
  String mp3Main = "";

  bool isRender = true;
  bool isAvailable = false;
  bool isPlay = false;
  late bool isTalkBackActive;

  List<int> articleIdList = [];
  List<dynamic> articleRenderList = [];
  List<String> chunks = [];

  Future<List<dynamic>>? _futureArticleDetail;
  Future<List<dynamic>>? _futureArticleRelateList;

  Map<String, String> voiceRead = {"name": "vi-VN-language", "locale": "vi-VN"};

  List<Map<String, dynamic>> optionList = [
    {"id": 0, "icon": Icons.share, "text": "Chia sẻ"},
    {"id": 1, "icon": Icons.download, "text": "Tải xuống"},
    {"id": 2, "icon": Icons.copy, "text": "Sao chép"}
  ];

  List<Map<String, dynamic>> speedList = [
    {"id": 0, "speed": "x0.5 chậm", "value": 0.2},
    {"id": 1, "speed": "x1 bình thường", "value": 0.5},
    {"id": 2, "speed": "x1.5 nhanh", "value": 0.7},
    {"id": 3, "speed": "x2 rất nhanh", "value": 0.9},
  ];

  List<Map<String, String>> voiceVNList = [
    {"key": "vi-VN-language", "locale": "vi-VN", "name": "Giọng đọc 1"},
    {"key": "vi-vn-x-gft-network", "locale": "vi-VN", "name": "Giọng đọc 2"},
    {"key": "vi-vn-x-vie-network", "locale": "vi-VN", "name": "Giọng đọc 3"},
    {"key": "vi-vn-x-vid-local", "locale": "vi-VN", "name": "Giọng đọc 4"},
    {"key": "vi-vn-x-vic-local", "locale": "vi-VN", "name": "Giọng đọc 5"},
    {"key": "vi-vn-x-gft-local", "locale": "vi-VN", "name": "Giọng đọc 6"},
    {"key": "vi-vn-x-vie-local", "locale": "vi-VN", "name": "Giọng đọc 7"},
    {"key": "vi-vn-x-vif-network", "locale": "vi-VN", "name": "Giọng đọc 8"},
    {"key": "vi-vn-x-vif-local", "locale": "vi-VN", "name": "Giọng đọc 9"},
    {"key": "vi-vn-x-vid-network", "locale": "vi-VN", "name": "Giọng đọc 10"},
    {"key": "vi-vn-x-vic-network", "locale": "vi-VN", "name": "Giọng đọc 11"}
  ];
  @override
  void initState() {
    if (mounted) {
      initSpeech();
      dataMap = widget.dataMap;

      speedItems = optionList.map<PopupMenuItem<String>>((e) {
        return PopupMenuItem<String>(
          value: e["text"],
          child: Row(
            children: [
              Icon(e["icon"]),
              SizedBox(width: 8),
              Text(e["text"]),
            ],
          ),
        );
      }).toList();
      articleIdList =
          cutArticleIdList(widget.articleIdList, widget.dataMap['id']);
      loadDataFromApi();
      MyTtsManager();
    }
    super.initState();
  }

  loadDataFromApi() {
    setState(() {
      _futureArticleDetail = fetchArticleDetailInfo();
      _futureArticleRelateList = fetchArticleRelateInfo();
    });
  }

  void initSpeech() async {
    isAvailable = await speechToText.initialize();
  }

  //check talkaback
  MyTtsManager() {
    initTalkBackListener();
  }

  Future<void> initTalkBackListener() async {
    MethodChannel talkBackChannel =
        MethodChannel('com.example.read_paper/talkback_channel');
    try {
      final bool talkBackActive =
          await talkBackChannel.invokeMethod('isTalkBackActive');
      updateTalkBackStatus(talkBackActive);
      talkBackChannel.setMethodCallHandler((call) async {
        if (call.method == 'onTalkBackStateChanged') {
          final bool talkBackActive = call.arguments['isTalkBackActive'];

          updateTalkBackStatus(talkBackActive);
        }
      });
    } on PlatformException catch (e) {
      print("Failed to check TalkBack status: '${e.message}'.");
    }
  }

  void updateTalkBackStatus(bool isActive) {
    if (isActive) {
      log('vo ative');
      pauseTts();
    } else {
      log('vo not active talkback');
      if (chunks != [] && chunks.length > 0) {
        speak(chunks[chunkIndex]);
      }
    }
  }

  Future<void> pauseTts() async {
    await flutterTts.stop();

    log('pause:::::');
    // cutCharacter(mp3Main);
  }
  // ===========================

  Future<List<dynamic>> fetchArticleDetailInfo() async {
    final articleProvider =
        Provider.of<ArticleViewModel>(context, listen: false);
    List<dynamic> articleList =
        await articleProvider.getSingleArticle(widget.dataMap['id']);
    if (articleList.isNotEmpty) {
      mp3Main = articleList[0].textContent;
      link_Copy = articleList[0].crawlUrl;
      link_share = articleList[0].crawlUrl;
      articleRenderList = articleList;
      cutCharacter(mp3Main);
      return articleList;
    }
    return [];
  }

  Future<List<dynamic>> fetchArticleRelateInfo() async {
    final articleProvider =
        Provider.of<ArticleViewModel>(context, listen: false);
    List<dynamic> articleList =
        await articleProvider.getRelateArticleList(widget.dataMap['catId']);
    if (articleList.isNotEmpty) {
      return articleList;
    }
    return [];
  }

  fetchArticleRender(int id) async {
    setState(() {
      isRender = false;
    });
    final articleProvider =
        Provider.of<ArticleViewModel>(context, listen: false);
    List<dynamic> articleList = await articleProvider.getSingleArticle(id);

    if (articleList.isNotEmpty) {
      setState(() {
        mp3Main = articleList[0].textContent;
        link_Copy = articleList[0].crawlUrl;
        link_share = articleList[0].crawlUrl;
        articleRenderList = articleList;
      });
      setState(() {
        isRender = true;
      });

      cutCharacter(mp3Main);
    } else {
      setState(() {
        isRender = true;
      });
    }
  }

  //new
  Future<void> speak(String word) async {
    await flutterTts.setLanguage('vi-VN');
    await flutterTts.setVoice(voiceRead);
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(_currentSliderValue);

    flutterTts.setCompletionHandler(() {
      chunkIndex++;
      if (chunkIndex < chunks.length) {
        speak(chunks[chunkIndex]);
      } else {
        if (articleIndex < articleIdList.length) {
          articleIndex++;
          fetchArticleRender(articleIdList[articleIndex]);
        }
      }
    });

    flutterTts.setCancelHandler(() {
      log('voooooo dayyyyyyyy');
      // speak()
      cutCharacter(mp3Main);
      setState(() {
        isPlay = true;
      });
    });

    flutterTts.setProgressHandler((text, start, end, word) {
      log('dang chay');
      // speak(chunks[chunkIndex]);
    });

    await flutterTts.speak(word);
  }

  //old

  // Future<void> speak(String word) async {
  //   await flutterTts.setLanguage('vi-VN');
  //   await flutterTts.setVoice(voiceRead);
  //   await flutterTts.setPitch(1.0);
  //   await flutterTts.setSpeechRate(_currentSliderValue);

  //   flutterTts.setCompletionHandler(() {
  //     chunkIndex++;
  //     if (chunkIndex < chunks.length) {
  //       speak(chunks[chunkIndex]);
  //     } else {
  //       if (articleIndex < articleIdList.length) {
  //         articleIndex++;
  //         fetchArticleRender(articleIdList[articleIndex]);
  //       }
  //     }
  //   });

  //   flutterTts.setCancelHandler(() {});

  //   flutterTts.setProgressHandler((text, start, end, word) {
  //     log('dang chay');
  //   });

  //   await flutterTts.speak(word);
  // }

  Future<void> cutCharacter(String mp3Main) async {
    int chunkSize = 3900;
    mp3Main = mp3Main.trim().toString();

    for (int i = 0; i < mp3Main.length; i += chunkSize) {
      chunks.add(mp3Main.substring(
          i, i + chunkSize < mp3Main.length ? i + chunkSize : mp3Main.length));
    }

    if (isAvailable) {
      if (mounted) {
        setState(() {
          isPlay = true;
        });
        speak(chunks[chunkIndex]);
      }
    }
  }

  List<int> cutArticleIdList(List<int> array, int location) {
    int index = array.indexOf(location);
    if (index != -1) {
      return array.sublist(index);
    } else {
      return [];
    }
  }

  void showPopupMenu(
      BuildContext context, Map optionMap, TapDownDetails tapDownDetails) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          tapDownDetails.globalPosition.dx,
          tapDownDetails.globalPosition.dy,
          tapDownDetails.globalPosition.dx + 100,
          tapDownDetails.globalPosition.dx + 100),
      items: speedItems!,
    ).then((value) async {
      if (value != null) {
        if (value == "Chia sẻ") {
          Share.share(optionMap['share']);
        } else if (value == "Tải xuống") {
          // String text = "Hello, how are you?";
          // String? filePath = await TTSHelper.saveTextToSpeech(text);
          // if (filePath != null) {
          //   log('Audio file saved at: $filePath');
          // } else {
          //   log('Failed to save audio file');
          // }
        } else {
          if (link_Copy != '') {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: AppThemePreferences.primaryColor,
              content: const Text("Copy thành công"),
            ));
            final value = ClipboardData(text: optionMap['copy']);
            Clipboard.setData(value);
          }
        }
      }
    });
  }

  void showSettings({
    required BuildContext context,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          _setStateSpeech = setState;
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            insetPadding: EdgeInsets.all(10),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cài đặt'),
                InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.close))
              ],
            ),
            content: Container(
                width: double.maxFinite,
                height: 400,
                child: ListView(children: [
                  Text('Cài đặt âm thanh'),
                  sliderbar(),
                  Text('Cài đặt giọng nói'),
                  Wrap(
                    children: voiceVNList.map<Widget>((item) {
                      return Card(
                        child: GestureDetector(
                          onTap: () {
                            Map<String, String> voiceName = {
                              "name": item['key']!,
                              "locale": item['locale']!
                            };

                            _setStateSpeech(() {
                              voiceRead = voiceName;
                            });
                            speak(chunks[chunkIndex]);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(item['name']!),
                          ),
                        ),
                      );
                    }).toList(),
                  )
                ])),
          );
        });
      },
    );
  }

  @override
  void dispose() {
    flutterTts.stop();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articleProvider =
        Provider.of<ArticleViewModel>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
            iconSize: 30,
            icon: Icon(
              Icons.close_rounded,
              color: AppThemePreferences.closeIconColor,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        elevation: 0,
        actions: [
          isRender
              ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                      onTapDown: (TapDownDetails tapDownDetails) async {
                        Map optionMap = {
                          "share": link_share,
                          "download": mp3Main,
                          "copy": link_Copy,
                        };
                        showPopupMenu(context, optionMap, tapDownDetails);
                      },
                      child: Icon(Icons.more_vert)),
                )
              : Container(),
          isRender
              ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      showSettings(context: context);
                    },
                    child: Icon(Icons.settings),
                  ),
                )
              : Container(),
        ],
      ),
      body: buildArticleList(context, _futureArticleDetail!),
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
              child: Text("Không có chi tiết bài báo"),
            );
          } else if (dataSnapshot.data!.isNotEmpty) {
            // List articleList = dataSnapshot.data!;
            return isRender
                ? Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 130),
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                children: articleRenderList.map<Widget>((item) {
                                  link_share = item.crawlUrl!;
                                  link_Copy = item.textContent!;

                                  return Column(
                                    children: [
                                      Text(
                                        item.title ?? '',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 19),
                                      ),
                                      Text(
                                        item.subTitle ?? '',
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      HtmlWidget(item.htmlContent ?? ''),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Nguồn báo : ${item.crawlUrl.toString()}",
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: GestureDetector(
                                                onTapDown: (TapDownDetails
                                                    tapDownDetails) async {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    backgroundColor:
                                                        AppThemePreferences
                                                            .primaryColor,
                                                    content: const Text(
                                                        "Đã coppy nguồn báo"),
                                                  ));
                                                  final value = ClipboardData(
                                                      text: item.crawlUrl
                                                          .toString());
                                                  Clipboard.setData(value);
                                                },
                                                child: Icon(Icons.copy)),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                              sliderbar(),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Tin liên quan",
                                      style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Divider(),
                                    buildArticleRelateList(
                                        context, _futureArticleRelateList!)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: AppThemePreferences.primaryColorLight,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [audioWidget()],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  );
          }
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget buildArticleRelateList(
      BuildContext context, Future<List<dynamic>> futureArticleRelateList) {
    return FutureBuilder<List<dynamic>>(
      future: futureArticleRelateList,
      builder: (context, dataSnapshot) {
        if (dataSnapshot.hasData) {
          if (dataSnapshot.data!.isEmpty) {
            return Center(
              child: Text("Không có bài báo liên quan"),
            );
          } else if (dataSnapshot.data!.isNotEmpty) {
            List articleList = dataSnapshot.data!;
            return Wrap(
              children: articleList.map((news) {
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ArticleItem(
                      heroId: 555,
                      item: news,
                      articleIdList: widget.articleIdList),
                );
              }).toList(),
            );
          }
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget sliderbar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Text(
        //   'Value: $_currentSliderValue',
        //   style: TextStyle(fontSize: 20),
        // ),
        Slider(
          value: _currentSliderValue,
          min: 0.1,
          max: 0.9,
          divisions: 100,
          onChanged: (double value) {},
          onChangeEnd: (double value) {
            _setStateSpeech(() {
              _currentSliderValue = value;
            });
            speak(chunks[chunkIndex]);
          },
        ),
      ],
    );
  }

  Widget audioWidget() {
    return Card(
        child: Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Container(
              height: 30,
              child: Image.asset('assets/sound_wave_icon.png'),
            ),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              if (articleIndex >= 0) {
                articleIndex--;
                chunks = [];
                fetchArticleRender(articleIdList[articleIndex]);
              }
            },
            icon: Icon(Icons.keyboard_double_arrow_left),
          ),
          IconButton(
            iconSize: 40,
            icon: Icon(isPlay
                ? Icons.pause_circle_outline_rounded
                : Icons.play_circle_outline_sharp),
            onPressed: () async {
              if (!isPlay) {
                cutCharacter(mp3Main);
                setState(() {
                  isPlay = true;
                });
              } else {
                await flutterTts.pause();
                setState(() {
                  isPlay = false;
                });
              }
            },
          ),
          IconButton(
            onPressed: () {
              if (articleIndex < articleIdList.length) {
                articleIndex++;
                chunks = [];
                fetchArticleRender(articleIdList[articleIndex]);
              }
            },
            icon: Icon(Icons.keyboard_double_arrow_right),
          )
        ],
      ),
    ]));
  }
}
