import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'dart:developer';

class TTSHelper {
  static final FlutterTts flutterTts = FlutterTts();

  static Future<String?> saveTextToSpeech(String text) async {
    try {
      // Tạo thư mục để lưu trữ tệp âm thanh
      Directory appDocDir = await getApplicationDocumentsDirectory();

      // Tạo định dạng ngày giờ
      var now = DateTime.now();
      var formattedDate = DateFormat('yyyyMMdd_HHmmss').format(now);

      // Tạo tên tệp dựa trên ngày giờ hiện tại
      String filePath = '${appDocDir.path}/speech_$formattedDate.mp3';

      log('file path:' + filePath);

      // Bắt đầu tạo giọng nói từ văn bản và ghi âm thành tệp
      await flutterTts.setVolume(1.0); // Đặt âm lượng
      await flutterTts.setSpeechRate(0.5); // Đặt tốc độ
      await flutterTts.setPitch(1.0); // Đặt âm sắc
      await flutterTts.setLanguage('en-US'); // Đặt ngôn ngữ

      // Phát giọng nói từ văn bản và ghi âm vào tệp
      await flutterTts.speak(text); // Phát giọng nói từ văn bản

      // Di chuyển tệp âm thanh vào vị trí mong muốn
      File audioFile = File(filePath);
      if (await audioFile.exists()) {
        await audioFile.rename(filePath);
        return audioFile.path;
      } else {
        throw FileSystemException('Tệp âm thanh không tồn tại');
      }
    } catch (e) {
      print('Error saving text to speech: $e');
      return null;
    }
  }
}
