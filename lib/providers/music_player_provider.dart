import 'package:flutter/material.dart';

class MusicPlayerProvider extends ChangeNotifier {
  bool isPlaying = false;
  String currentSong = "Locked Eyes";
  String artist = "Mystery Friends";

  void togglePlayPause() {
    isPlaying = !isPlaying;
    notifyListeners(); // Обновляет всех подписчиков
  }

  void setSong(String song, String newArtist) {
    currentSong = song;
    artist = newArtist;
    isPlaying = true; // Начинаем воспроизведение при смене трека
    notifyListeners();
  }
}
