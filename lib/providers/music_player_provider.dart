// import 'dart:convert';
// import 'dart:math';
// import 'package:dolby/constants/constants.dart';
// import 'package:http/http.dart' as http;

// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';

// class MusicPlayerProvider extends ChangeNotifier {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   bool _isPlaying = false;
//   String _currentSong = "";
//   String _artist = "";
//   String _imageUrl = "";
//   int _currentIndex = 0;

//   final List<Map<String, String>> _queue = []; // Очередь треков

//   AudioPlayer get audioPlayer => _audioPlayer;
//   bool get isPlaying => _isPlaying;
//   String get currentSong => _currentSong;
//   String get artist => _artist;
//   String get imageUrl => _imageUrl;
//   List<Map<String, String>> get queue => _queue;
//   int get currentIndex => _currentIndex;
  

//   /// Устанавливаем и воспроизводим трек
//   Future<void> setTrack(
//       String url, String title, String artist, String imageUrl) async {
//     _currentSong = title;
//     _artist = artist;
//     _imageUrl = imageUrl;
//     notifyListeners();

//     try {
//       await _audioPlayer.setUrl(url);
//       play();
//     } catch (e) {
//       print("Ошибка загрузки трека: $e");
//     }
//   }

//   void addToQueue(String url, String title, String artist, String imageUrl) {
//     _queue.add({
//       "url": url,
//       "title": title,
//       "artist": artist,
//       "imageUrl": imageUrl,
//     });

//     // Если это первый трек в очереди — запускаем сразу
//     if (_queue.length == 1) {
//       _currentIndex = 0;
//       setTrack(url, title, artist, imageUrl);
//     }
//     // Если трек добавляется в очередь, но никакой трек сейчас не играет — включаем его
//     else if (!_isPlaying) {
//       _currentIndex = _queue.length - 1;
//       var nextTrack = _queue[_currentIndex];
//       setTrack(nextTrack["url"]!, nextTrack["title"]!, nextTrack["artist"]!,
//           nextTrack["imageUrl"]!);
//     }

//     notifyListeners();
//   }

//   void addToQueueAndPlay(String url, String title, String artist, String imageUrl) {
//   // Проверяем, есть ли уже такой трек в очереди
//   int existingIndex = _queue.indexWhere((track) => track["url"] == url);

//   if (existingIndex == -1) {
//     // Если трека нет в очереди, добавляем его в очередь
//     _queue.add({
//       "url": url,
//       "title": title,
//       "artist": artist,
//       "imageUrl": imageUrl,
//     });
//     existingIndex = _queue.length - 1; // Новый индекс трека
//   }

//   // Если это не текущий трек, переключаемся на него
//   if (_currentIndex != existingIndex) {
//     _currentIndex = existingIndex;
//     setTrack(url, title, artist, imageUrl);
//   }

//   notifyListeners();
// }

//   // /// Воспроизведение следующего трека
//   // void nextTrack() {
//   //   if (_queue.isNotEmpty && _currentIndex < _queue.length - 1) {
//   //     _currentIndex++;
//   //     var nextTrack = _queue[_currentIndex];
//   //     setTrack(nextTrack["url"]!, nextTrack["title"]!, nextTrack["artist"]!,
//   //         nextTrack["imageUrl"]!);
//   //   }
//   // }
//    /// Play the next track
//   void nextTrack() {
//     if (_queue.isNotEmpty && _currentIndex < _queue.length - 1) {
//       _currentIndex++;
//       var nextTrack = _queue[_currentIndex];
//       setTrack(nextTrack["url"]!, nextTrack["title"]!, nextTrack["artist"]!,
//           nextTrack["imageUrl"]!);
//     } else {
      
//       // If at the end of the queue, play a random track
//       playRandomTrack();
//     }
//   }

//   /// Воспроизведение предыдущего трека
//   void previousTrack() {
//     if (_queue.isNotEmpty && _currentIndex > 0) {
//       _currentIndex--;
//       var prevTrack = _queue[_currentIndex];
//       setTrack(prevTrack["url"]!, prevTrack["title"]!, prevTrack["artist"]!,
//           prevTrack["imageUrl"]!);
//     }
//   }

//   /// Воспроизведение
//   void play() {
//     _audioPlayer.play();
//     _isPlaying = true;
//     notifyListeners();
//   }

//   /// Пауза
//   void pause() {
//     _audioPlayer.pause();
//     _isPlaying = false;
//     notifyListeners();
//   }

//   /// Переключение Play/Pause
//   void togglePlayPause() {
//     if (_isPlaying) {
//       pause();
//     } else {
//       play();
//     }
//   }

//   /// Перемотка на указанное время
//   void seek(Duration position) {
//     _audioPlayer.seek(position);
//   }

//   /// Fetch the list of all available tracks
// Future<List<Map<String, String>>> fetchAllTracks() async {
//   final response = await http.get(
//       Uri.parse('$APIROOT/api/music/list'));

//   if (response.statusCode == 200) {
//     List<dynamic> data = jsonDecode(response.body);
//     return data.map<Map<String, String>>((track) {
//       return {
//         "url": track["url"] as String,
//         "title": track["title"] as String,
//         "artist": track["artist"] as String,
//         "imageUrl": track["imageUrl"] as String,
//       };
//     }).toList();
//   } else {
//     throw Exception('Failed to load tracks');
//   }
// }


//    /// Play a random track from the list
//   Future<void> playRandomTrack() async {
//     try {
//       List<Map<String, String>> allTracks = await fetchAllTracks();
//       if (allTracks.isNotEmpty) {
//         final random = Random();
//         int randomIndex = random.nextInt(allTracks.length);
//         var randomTrack = allTracks[randomIndex];
//         setTrack(randomTrack["url"]!, randomTrack["title"]!,
//             randomTrack["artist"]!, randomTrack["imageUrl"]!);
//       }
//     } catch (e) {
//       print("Error fetching or playing random track: $e");
//     }
//   }
// }import 'dart:convert';
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
  int _currentIndex = 0;

  final List<Map<String, String>> _queue = [];

  AudioPlayer get audioPlayer => _audioPlayer;
  bool get isPlaying => _isPlaying;
  String get currentSong => _currentSong;
  String get artist => _artist;
  String get imageUrl => _imageUrl;
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

  Future<void> setTrack(
      String url, String title, String artist, String imageUrl) async {
    print("Устанавливаю трек: $title");

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

  void addToQueueAndPlay(
      String url, String title, String artist, String imageUrl) {
    int existingIndex = _queue.indexWhere((track) => track["url"] == url);

    if (existingIndex == -1) {
      _queue.add({
        "url": url,
        "title": title,
        "artist": artist,
        "imageUrl": imageUrl,
      });
      existingIndex = _queue.length - 1;
    }

    if (_currentIndex != existingIndex) {
      _currentIndex = existingIndex;
      setTrack(url, title, artist, imageUrl);
    }

    notifyListeners();
  }

  void nextTrack() {
    print("Нажали кнопку 'Следующий трек'");

    if (_queue.isNotEmpty && _currentIndex < _queue.length - 1) {
      _currentIndex++;
      var nextTrack = _queue[_currentIndex];
      print("Переключаюсь на следующий трек: ${nextTrack["title"]}");
      setTrack(nextTrack["url"]!, nextTrack["title"]!, nextTrack["artist"]!,
          nextTrack["imageUrl"]!);
    } else {
      print(
          "Очередь пуста или достигнут конец списка, запускаю случайный трек");
      playRandomTrack();
    }
  }

  void previousTrack() {
    if (_queue.isNotEmpty && _currentIndex > 0) {
      _currentIndex--;
      var prevTrack = _queue[_currentIndex];
      print("Переключаюсь на предыдущий трек: ${prevTrack["title"]}");
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
            String encodedPath = Uri.encodeComponent("$genre/$track"); // Кодируем путь

            allTracks.add({
              "url": "$APIROOT/api/music/play?path=$encodedPath", // ✅ Новый URL!
              "title": track.replaceAll('.mp3', ''), // Убираем расширение
              "artist": "Unknown",
              "imageUrl": "$APIROOT/images/$genre/${track.replaceAll('.mp3','-main.png')}"
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

        setTrack(randomTrack["url"]!, randomTrack["title"]!,
            randomTrack["artist"]!, randomTrack["imageUrl"]!);
      } else {
        print("⚠️ Нет доступных треков!");
      }
    } catch (e) {
      print("Ошибка при загрузке случайного трека: $e");
    }
  }
}
