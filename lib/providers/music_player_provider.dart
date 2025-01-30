import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String _currentSong = "";
  String _artist = "";
  String _imageUrl = ""; // Добавляем обложку трека

  AudioPlayer get audioPlayer => _audioPlayer;
  bool get isPlaying => _isPlaying;
  String get currentSong => _currentSong;
  String get artist => _artist;
  String get imageUrl => _imageUrl;

  /// Устанавливаем текущий трек
  void setTrack(String url, String title, String artist, String imageUrl) async {
    _currentSong = title;
    _artist = artist;
    _imageUrl = imageUrl; // Сохраняем обложку
    notifyListeners();

    try {
      await _audioPlayer.setUrl(url);
      play();
    } catch (e) {
      print("Ошибка загрузки трека: $e");
    }
  }

  /// Воспроизведение
  void play() {
    _audioPlayer.play();
    _isPlaying = true;
    notifyListeners();
  }

  /// Пауза
  void pause() {
    _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  /// Переключение между Play/Pause
  void togglePlayPause() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  /// Перемотка на указанное время
  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  /// Переключение на следующий трек (пока заглушка)
  void seekToNext() {
    print("Следующий трек");
  }

  /// Переключение на предыдущий трек (пока заглушка)
  void seekToPrevious() {
    print("Предыдущий трек");
  }
}
