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
  ArticleDetailPage({
    super.key,
    required this.dataMap,
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

  List<Map<String, dynamic>> voiceList = [
    {"id": 0, "name": "Giọng Ngọc Huyền"},
    {"id": 1, "name": "Giọng Anh Khôi"},
    {"id": 2, "name": "Giọng Mạnh Dũng"},
    {"id": 3, "name": "Giọng Thảo Trinh"},
    {"id": 4, "name": "Giọng Trung Kiên"}
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
        if (audioIndex < articleIdList.length) {
          audioIndex++;
          getSingleArticle(articleIdList[audioIndex]);
          log("Audio đã hoàn thành phát11111.$mp3Url2");

          playAudio(mp3Url2);
        }
      });
      mp3Main = "$URL_MP3${dataMap['audioUrl']}";
      playAudio(mp3Main);
      getRelateArticle();
      getArticleIdList();
    }
    super.initState();
  }

  getArticleIdList() {
    final articleProvider =
        Provider.of<ArticleViewModel>(context, listen: false);

    int index = articleProvider.articleIdList.indexOf(widget.dataMap['id']);

    if (index != -1) {
      setState(() {
        articleIdList = articleProvider.articleIdList.sublist(index);
      });
    } else {
      print("Không tìm thấy phần tử có giá trị trong mảng.");
    }
  }

  void initSpeech() async {
    await speechToText.initialize();
    setState(() {});
  }

  getSingleArticle(int id) {
    final articleProvider =
        Provider.of<ArticleViewModel>(context, listen: false);
    articleProvider.getSingleArticle(id);
  }

  getRelateArticle() {
    final articleProvider =
        Provider.of<ArticleViewModel>(context, listen: false);
    articleProvider.getRelateArticleList(widget.dataMap['catId']);
  }

  Future<void> playAudio(String mp3) async {
    setState(() {
      playLoading = true;
    });

    log("Audio đã hoàn thành phát2222.$mp3");

    await player.play(UrlSource(mp3));
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

  void handleSelectedVoiceId(
      int selectedId, Map<String, dynamic> dataVoice) async {
    switch (selectedId) {
      case 0:
        await player.play(UrlSource(mp3Main));
        break;
      case 1:
        mp3Main = dataVoice['audio2'];
        await player.play(UrlSource(mp3Main));
        break;
      case 2:
        mp3Main = dataVoice['audio3'];
        await player.play(UrlSource(mp3Main));
        break;
      case 3:
        mp3Main = dataVoice['audio4'];
        await player.play(UrlSource(mp3Main));
        break;
      default:
        mp3Main = dataVoice['audio5'];
        await player.play(UrlSource(mp3Main));
        break;
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

  void showVoice(BuildContext context, TapDownDetails tapDownDetails,
      Map<String, dynamic> dataVoice) {
    List<PopupMenuEntry<Map<String, dynamic>>> popupMenuEntries =
        voiceList.map((voice) {
      return PopupMenuItem<Map<String, dynamic>>(
        value: voice,
        child: Text(voice['name']),
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
    ).then((value) {
      if (value != null) {
        int selectedId = value['id'];
        handleSelectedVoiceId(selectedId, dataVoice);
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
          GestureDetector(
            onTap: () {
              player.setPlaybackRate(2);
            },
            child: Icon(Icons.add),
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
                            mp3Url1 = "$URL_MP3${item.mp3Url1}";
                            mp3Url2 = "$URL_MP3${item.mp3Url2}";
                            mp3Url3 = "$URL_MP3${item.mp3Url3}";
                            mp3Url4 = "$URL_MP3${item.mp3Url4}";
                            mp3Url5 = "$URL_MP3${item.mp3Url5}";
                            link_share = item.crawlUrl!;
                            link_Copy = item.textContent!;

                            log('vo day bao nhiêu lan');

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
                                          ),
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
    return Row(
      children: [
        Expanded(
          child: Slider(
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
              }),
        ),
        InkWell(
          onTapDown: (TapDownDetails tapDownDetails) async {
            UtilityMethods.speak(flutterTts, "Chọn giọng đọc");
            Map<String, dynamic> data = {
              'audio1': mp3Url1,
              'audio2': mp3Url2,
              'audio3': mp3Url3,
              'audio4': mp3Url4,
              'audio5': mp3Url5,
            };

            showVoice(context, tapDownDetails, data);
          },
          child: Icon(
            Icons.voice_chat,
            color: AppThemePreferences.secondPrimaryColor,
          ),
        )
      ],
    );
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
