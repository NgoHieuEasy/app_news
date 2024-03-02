import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';

class UtilityMethods {
  static Future<void> speak(FlutterTts flutterTts, String word) async {
    await flutterTts
        .setLanguage('vi-VN'); // Thiết lập ngôn ngữ thành Tiếng Việt
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);

    flutterTts.setCompletionHandler(() {});

    flutterTts.setCancelHandler(() {});

    flutterTts.setProgressHandler((text, start, end, word) {});

    await flutterTts.speak(word);
  }

  static String formatTimeClock(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  static String formatUnixTime(int unixTime) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixTime * 1000);
    return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
  }

  static String truncateDescription(String description) {
    const int maxLength = 50;
    if (description.length <= maxLength) {
      return description;
    } else {
      String truncated = description.substring(0, maxLength);
      int lastSpaceIndex = truncated.lastIndexOf(' ');
      if (lastSpaceIndex != -1) {
        return truncated.substring(0, lastSpaceIndex) + '...';
      } else {
        return truncated + '...';
      }
    }
  }
}
