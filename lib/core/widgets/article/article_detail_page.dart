import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:read_paper/core/constants/constants.dart';
import 'package:read_paper/core/files/app_preferences/app_preferences.dart';
import 'package:read_paper/core/files/generic_methods/utility_methods.dart';
import 'package:read_paper/core/widgets/article/article_item.dart';
import 'package:read_paper/core/widgets/shimmer_effect_error_widget.dart';
import 'package:read_paper/src/viewmodal/article/article_viewmodel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

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
  final player = AudioPlayer();
  bool isPlaying = true;
  bool playLoading = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  int audioIndex = 0;

  SpeechToText speechToText = SpeechToText();
  FlutterTts flutterTts = FlutterTts();
  List<PopupMenuItem<String>>? speedItems;

  String mp3Url1 = "";
  String mp3Url2 = "";
  String mp3Url3 = "";
  String mp3Url4 = "";
  String mp3Url5 = "";
  String link_share = "";
  String link_Copy = "";
  String mp3Main = "";

  List<int> articleIdList = [];

  List<Map<String, dynamic>> optionList = [
    {"id": 0, "icon": Icons.share, "text": "Chia sẻ"},
    {"id": 1, "icon": Icons.download, "text": "Tải xuống"},
    {"id": 2, "icon": Icons.copy, "text": "Sao chép"}
  ];

  List<Map<String, dynamic>> speedList = [
    {"id": 0, "speed": "x0.5 chậm"},
    {"id": 1, "speed": "x1 bình thường"},
    {"id": 2, "speed": "x1.5 nhanh"},
    {"id": 3, "speed": "x2 rất nhanh"},
  ];

  @override
  void initState() {
    if (mounted) {
      dataMap = widget.dataMap;
      initSpeech();
      getSingleArticle(widget.dataMap['id']);
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

      player.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            playLoading = false;
            isPlaying = state == PlayerState.playing;
          });
        }
      });
      player.onDurationChanged.listen((newDuration) {
        if (mounted) {
          setState(() {
            duration = newDuration;
          });
        }
      });

      player.onPositionChanged.listen((newPosition) {
        if (mounted) {
          setState(() {
            position = newPosition;
          });
        }
      });
      player.onPlayerComplete.listen((event) {
        if (audioIndex < articleIdList.length) {}
        final articleProvider =
            Provider.of<ArticleViewModel>(context, listen: false);

        audioIndex++;
        getSingleArticle(articleIdList[audioIndex]);
        String mp3 =
            "$URL_TAKE_MP3${articleProvider.articleList[audioIndex].mp3Url1}";
        playAudio(mp3);
      });

      getRelateArticle();
      getArticleIdList();
    }
    super.initState();
  }

  getArticleIdList() {
    int index = widget.articleIdList.indexOf(widget.dataMap['id']);
    if (index != -1) {
      List<int> articleIdListTemp = List<int>.from(widget.articleIdList);
      setState(() {
        articleIdList = articleIdListTemp.sublist(index);
      });
    } else {
      log("Không tìm thấy phần tử có giá trị trong mảng.");
    }
  }

  void initSpeech() async {
    await speechToText.initialize();
    setState(() {});
  }

  getSingleArticle(int id) async {
    final articleProvider =
        Provider.of<ArticleViewModel>(context, listen: false);
    await articleProvider.getSingleArticle(id);
    playAudio("$URL_TAKE_MP3${articleProvider.singleArticleList[0].mp3Url1}");
  }

  getRelateArticle() {
    final articleProvider =
        Provider.of<ArticleViewModel>(context, listen: false);
    articleProvider.getRelateArticleList(widget.dataMap['catId']);
  }

  Future<void> playAudio(String mp3) async {
    if (mounted) {
      setState(() {
        playLoading = true;
      });
      await player.play(UrlSource(mp3));
    }
  }

  Future<void> forward() async {
    Duration secondsNext = Duration(seconds: 5);
    Duration? currentPosition = await player.getCurrentPosition();
    Duration newPosition = currentPosition! + secondsNext;

    player.seek(newPosition);

    await player.resume();
  }

  Future<void> backward() async {
    Duration secondsNext = Duration(seconds: 5);
    Duration? currentPosition = await player.getCurrentPosition();
    Duration newPosition = currentPosition! - secondsNext;

    player.seek(newPosition);

    await player.resume();
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
          DateTime now = DateTime.now();
          Dio dio = Dio();
          String fileName = "${now.toString()}.mp3}";

          String path = await _getFilePath(fileName);
          await dio.download(
            optionMap['download'],
            path,
            onReceiveProgress: (recivedBytes, totalBytes) {
              print(totalBytes);
            },
            deleteOnError: true,
          ).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: AppThemePreferences.primaryColor,
              content: const Text("Download thành công"),
            ));
          });
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

  Future<String> _getFilePath(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    return "${dir.path}/$filename";
  }

  void showSpeed(
    BuildContext context,
    TapDownDetails tapDownDetails,
  ) {
    List<PopupMenuEntry<Map<String, dynamic>>> popupMenuEntries =
        speedList.map((voice) {
      return PopupMenuItem<Map<String, dynamic>>(
        value: voice,
        child: Text(voice['speed']),
      );
    }).toList();

    showMenu<Map<String, dynamic>>(
      context: context,
      position: RelativeRect.fromLTRB(
        tapDownDetails.globalPosition.dx,
        tapDownDetails.globalPosition.dy,
        tapDownDetails.globalPosition.dx + 100,
        tapDownDetails.globalPosition.dy + 100,
      ),
      items: popupMenuEntries,
    ).then((value) async {
      if (value != null) {
        int selectedId = value['id'];
        switch (selectedId) {
          case 0:
            player.setPlaybackRate(0.5);
            break;
          case 1:
            player.setPlaybackRate(1);
            break;
          case 2:
            player.setPlaybackRate(1.5);
            break;

          default:
            player.setPlaybackRate(2);
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    player.dispose();
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
              articleProvider.clearArray();
              Navigator.of(context).popUntil((route) => route.isFirst);
            }),
        elevation: 0,
        actions: [
          link_Copy.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                      onTapDown: (TapDownDetails tapDownDetails) async {
                        Map optionMap = {
                          "share": link_share,
                          "download": mp3Url1,
                          "copy": link_Copy,
                        };
                        showPopupMenu(context, optionMap, tapDownDetails);
                      },
                      child: Icon(Icons.more_vert)),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTapDown: (TapDownDetails tapDownDetails) async {
                Map optionMap = {
                  "share": link_share,
                  "download": mp3Url1,
                  "copy": link_Copy,
                };
                showSpeed(context, tapDownDetails);
              },
              child: Icon(Icons.speed_sharp),
            ),
          )
        ],
      ),
      body: (articleProvider.singleArticleList.isNotEmpty)
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
                          children: articleProvider.singleArticleList
                              .map<Widget>((item) {
                            mp3Url1 = "$URL_TAKE_MP3${item.mp3Url1}";

                            mp3Url2 = "$URL_TAKE_MP3${item.mp3Url2}";
                            mp3Url3 = "$URL_TAKE_MP3${item.mp3Url3}";
                            mp3Url4 = "$URL_TAKE_MP3${item.mp3Url4}";
                            mp3Url5 = "$URL_TAKE_MP3${item.mp3Url5}";
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
                                Text(
                                  "Nguồn báo : ${item.crawlUrl.toString()}",
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tin liên quan",
                                style: TextStyle(
                                    fontSize: 19, fontWeight: FontWeight.bold),
                              ),
                              Divider(),
                              articleProvider.relateArticleList.isNotEmpty
                                  ? Wrap(
                                      children: articleProvider
                                          .relateArticleList
                                          .map((news) {
                                        return Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: ArticleItem(
                                              heroId: 555,
                                              item: news,
                                              articleIdList:
                                                  widget.articleIdList),
                                        );
                                      }).toList(),
                                    )
                                  : Text("Không có tin liên quan"),
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
                        children: [
                          sliderAudioWidget(
                              mp3Url1, mp3Url2, mp3Url3, mp3Url4, mp3Url5),
                          playAudioWidget(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Container(
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }

  Widget sliderAudioWidget(
    String mp3Url1,
    String mp3Url2,
    String mp3Url3,
    String mp3Url4,
    String mp3Url5,
  ) {
    return Slider(
        min: 0,
        max: duration.inSeconds.toDouble(),
        value: position.inSeconds.toDouble(),
        thumbColor: AppThemePreferences.secondPrimaryColor,
        activeColor: AppThemePreferences.secondPrimaryColor,
        inactiveColor: AppThemePreferences.primaryColor,
        secondaryActiveColor: AppThemePreferences.secondPrimaryColor,
        onChanged: (value) async {
          final position = Duration(seconds: value.toInt());
          await player.seek(position);

          await player.resume();
        });
  }

  Widget playAudioWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(UtilityMethods.formatTimeClock(position)),
        IconButton(
          icon: Icon(Icons.fast_rewind),
          color: Colors.brown,
          iconSize: 25,
          onPressed: () {
            backward();
          },
        ),
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.brown,
          child: playLoading == false
              ? IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 25,
                  onPressed: () async {
                    if (isPlaying) {
                      await player.pause();
                    } else {
                      setState(() {
                        playLoading = true;
                      });
                      await player.play(UrlSource(mp3Main));
                    }
                  },
                )
              : Center(
                  child: CircularProgressIndicator(
                    color: AppThemePreferences.primaryColor,
                  ),
                ),
        ),
        IconButton(
          icon: Icon(
            Icons.fast_forward,
            color: Colors.brown,
          ),
          iconSize: 25,
          onPressed: () {
            forward();
          },
        ),
        Text(UtilityMethods.formatTimeClock(duration - position)),
      ],
    );
  }
}
