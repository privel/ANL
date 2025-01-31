import 'dart:convert';
import 'dart:math';
import 'package:dolby/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String _currentSong = "";
  String _artist = "";
  String _imageUrl = "";
  String _g_url = "";
  int _currentIndex = 0;
  bool _isFavoriteMode = false;

  final List<Map<String, String>> _queue = [];

  AudioPlayer get audioPlayer => _audioPlayer;
  bool get isPlaying => _isPlaying;
  String get currentSong => _currentSong;
  String get artist => _artist;
  String get imageUrl => _imageUrl;
  String get track_url => _g_url.isNotEmpty ? _g_url : "";
  List<Map<String, String>> get queue => _queue;
  int get currentIndex => _currentIndex;

  MusicPlayerProvider() {
    _audioPlayer.playerStateStream.listen((state) {
      print("Состояние плеера: $state");
      if (state.processingState == ProcessingState.completed) {
        print("Трек завершился, переключаюсь на следующий...");
        nextTrack();
      }
    });
  }

  void clearQueue() {
    _queue.clear();
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    if (index >= 0 && index < _queue.length) {
      _currentIndex = index;
      var track = _queue[index];
      setTrack(
          track["url"]!, track["title"]!, track["artist"]!, track["imageUrl"]!);
    }
  }

  Future<void> setTrack(
      String url, String title, String artist, String imageUrl) async {
    print("Устанавливаю трек: $title");

    _g_url = url;
    _currentSong = title;
    _artist = artist;
    _imageUrl = imageUrl;
    notifyListeners();

    try {
      await _audioPlayer.setUrl(url);
      print("Трек успешно загружен, начинаю воспроизведение");
      play();
    } catch (e) {
      print("Ошибка загрузки трека: $e");
      playRandomTrack();
    }
  }

  /// **Добавить список треков и начать воспроизведение (используется в FavoritesScreen)**
  void setQueueAndPlay(List<Map<String, String>> tracks, int startIndex) {
    _queue.clear();
    _queue.addAll(tracks);
    _currentIndex = startIndex;
    _isFavoriteMode = true; // ✅ Включаем режим избранного

    // Начинаем воспроизведение
    var firstTrack = _queue[_currentIndex];
    setTrack(firstTrack["url"]!, firstTrack["title"]!, firstTrack["artist"]!,
        firstTrack["imageUrl"]!);
  }

  void addToQueue(String url, String title, String artist, String imageUrl) {
    _queue.add({
      "url": url,
      "title": title,
      "artist": artist,
      "imageUrl": imageUrl,
    });

    if (_queue.length == 1) {
      _currentIndex = 0;
      setTrack(url, title, artist, imageUrl);
    } else if (!_isPlaying) {
      _currentIndex = _queue.length - 1;
      var nextTrack = _queue[_currentIndex];
      setTrack(nextTrack["url"]!, nextTrack["title"]!, nextTrack["artist"]!,
          nextTrack["imageUrl"]!);
    }
    notifyListeners();
  }

  // /// **Задать трек и воспроизвести**
  // Future<void> setTrack(String url, String title, String artist, String imageUrl) async {
  //   _g_url = url;
  //   _currentSong = title;
  //   _artist = artist;
  //   _imageUrl = imageUrl;
  //   notifyListeners();

  //   try {
  //     await _audioPlayer.setUrl(url);
  //     play();
  //   } catch (e) {
  //     print("Ошибка загрузки трека: $e");
  //   }
  // }

  /// **Добавить трек в очередь и воспроизвести его**
  void addToQueueAndPlay(
      String url, String title, String artist, String imageUrl) {
    int existingIndex = _queue.indexWhere((track) => track["url"] == url);

    if (existingIndex == -1) {
      // Добавляем новый трек в очередь
      _queue.add({
        "url": url,
        "title": title,
        "artist": artist,
        "imageUrl": imageUrl,
      });
      existingIndex = _queue.length - 1;
    }

    // Переключаемся на этот трек
    _currentIndex = existingIndex;
    setTrack(url, title, artist, imageUrl);
  }

  /// **Переключиться на следующий трек**
  void nextTrack() {
    if (_queue.isNotEmpty && _currentIndex < _queue.length - 1) {
      _currentIndex++;
      var nextTrack = _queue[_currentIndex];
      setTrack(nextTrack["url"]!, nextTrack["title"]!, nextTrack["artist"]!,
          nextTrack["imageUrl"]!);
    } else if (!_isFavoriteMode) {
      print("📀 Очередь закончилась, загружаю случайный трек...");
      playRandomTrack(); // ✅ Загружаем случайный трек только если НЕ играем избранное
    }
  }

  /// **Переключиться на предыдущий трек**
  void previousTrack() {
    if (_queue.isNotEmpty && _currentIndex > 0) {
      _currentIndex--;
      var prevTrack = _queue[_currentIndex];
      setTrack(prevTrack["url"]!, prevTrack["title"]!, prevTrack["artist"]!,
          prevTrack["imageUrl"]!);
    }
  }

  void play() {
    _audioPlayer.play();
    _isPlaying = true;
    print("▶️ Воспроизведение трека: $_currentSong");
    notifyListeners();
  }

  void pause() {
    _audioPlayer.pause();
    _isPlaying = false;
    print("⏸ Пауза");
    notifyListeners();
  }

  void togglePlayPause() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  Future<List<Map<String, String>>> fetchAllTracks() async {
    final response = await http.get(Uri.parse('$APIROOT/api/music/list'));

    print("Статус-код ответа: ${response.statusCode}");
    print("Ответ от сервера: ${response.body}");

    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<Map<String, String>> allTracks = [];

        // Обходим все жанры и добавляем треки в список
        data.forEach((genre, tracks) {
          if (tracks is List) {
            for (var track in tracks) {
              String encodedPath =
                  Uri.encodeComponent("$genre/$track"); // Кодируем путь

              allTracks.add({
                "url":
                    "$APIROOT/api/music/play?path=$encodedPath", // ✅ Новый URL!
                "title": track.replaceAll('.mp3', ''), // Убираем расширение
                "artist": "Unknown",
                "imageUrl":
                    "$APIROOT/images/$genre/${track.replaceAll('.mp3', '-main.png')}"
              });
            }
          }
        });

        return allTracks;
      } catch (e) {
        print("❌ Ошибка обработки JSON: $e");
        throw Exception('Ошибка обработки треков');
      }
    } else {
      print("❌ Ошибка загрузки треков: HTTP ${response.statusCode}");
      throw Exception('Не удалось загрузить треки');
    }
  }

  Future<void> playRandomTrack() async {
    print("Запуск случайного трека...");

    try {
      List<Map<String, String>> allTracks = await fetchAllTracks();

      if (allTracks.isNotEmpty) {
        final random = Random();
        int randomIndex = random.nextInt(allTracks.length);
        var randomTrack = allTracks[randomIndex];

        print("Выбран случайный трек: ${randomTrack["title"]}");

        addToQueueAndPlay(randomTrack["url"]!, randomTrack["title"]!,
            randomTrack["artist"]!, randomTrack["imageUrl"]!);
        // setTrack(randomTrack["url"]!, randomTrack["title"]!,
        //     randomTrack["artist"]!, randomTrack["imageUrl"]!);
      } else {
        print("⚠️ Нет доступных треков!");
      }
    } catch (e) {
      print("Ошибка при загрузке случайного трека: $e");
    }
  }
}
