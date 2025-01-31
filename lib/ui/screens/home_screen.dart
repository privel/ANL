import 'package:dolby/constants/constants.dart';
import 'package:dolby/providers/music_player_provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late Future<List<Track>> _tracks;

  @override
  void initState() {
    super.initState();
    _tracks = fetchTracks();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.94,
      upperBound: 1.06,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// **Запрос API для получения списка треков**
  Future<List<Track>> fetchTracks() async {
    final response = await http.get(
        Uri.parse('$APIROOT/api/music/list'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<Track> tracks = [];

      data.forEach((genre, files) {
        for (String filename in files) {
          tracks.add(Track.fromJson(genre, filename));
        }
      });

      return tracks;
    } else {
      throw Exception('Ошибка загрузки треков');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildGradientBackground(),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  expandedHeight: 450,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildWaveSection(),
                  ),
                ),
                _buildPopularAndRecommended(),
                SliverToBoxAdapter(
                  child: _buildCategories(), // ✅ Теперь безопасно
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularAndRecommended() {
    return FutureBuilder<List<Track>>(
      future: fetchTracks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Ошибка: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Нет доступных треков',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == 0) return null;
              if (index == 1) return _buildHorizontalList();
              if (index == 2) return _buildSectionTitle("🎧 Рекомендуем");
              return _buildHorizontalList();
            },
            childCount: 4,
          ),
        );
      },
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.0, -0.6),
          radius: 1.5,
          colors: [
            Color(0xFFFF6B6B),
            Color(0xFFFF8C42),
            Color(0xFF1A1A1A),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveSection() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Фон или волна
        Positioned(
          top: 150,
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildSoundWave(),
        ),

        // Основной заголовок с кнопкой Play
        Positioned(
          top: 200,
          left: 60,
          right: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildPlayButton(context),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Моя волна",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    // SizedBox(height: 6),
                    // Text(
                    //   "Персональная подборка треков",
                    //   style: TextStyle(
                    //     color: Colors.white70,
                    //     fontSize: 18,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Кнопка профиля (раньше у неё не было корректного позиционирования)
        Positioned(
          top: 20, // Чётко указываем расположение
          left: 20, // Отступ слева для лучшего UI
          child: IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(
              Icons.person,
              size: 24,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSoundWave() {
    return Positioned(
      bottom: 150,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              14,
              (index) => _buildWaveBar(index, index.isEven ? 10 : 5),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWaveBar(int index, double width) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        double heightFactor =
            1 + 0.5 * sin(_waveController.value * 2 * pi + index * 0.5);
        return Container(
          height: (40 + index % 5 * 6) * heightFactor,
          width: width,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }

Widget _buildPlayButton(BuildContext context) {
  return Consumer<MusicPlayerProvider>(
    builder: (context, player, child) {
      return ScaleTransition(
        scale: _pulseController,
        child: GestureDetector(
          onTap: () async {
            if (player.isPlaying) {
              player.pause();
            } else {
              if (player.currentSong.isEmpty) {
                await player.playRandomTrack();
              } else {
                player.play();
              }
            }
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.6),
                  blurRadius: 35,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.black,
              size: 50,
            ),
          ),
        ),
      );
    },
  );
}



  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return FutureBuilder<List<Track>>(
      future: fetchTracks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 100, // 📌 Избегаем скачков в UI
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Ошибка: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Нет доступных треков',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          );
        }

        // ✅ Группируем треки по категориям
        Map<String, List<Track>> categoryTracks = {};
        for (var track in snapshot.data!) {
          categoryTracks.putIfAbsent(track.genre, () => []).add(track);
        }

        // Если категорий нет, просто возвращаем пустой контейнер
        if (categoryTracks.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: categoryTracks.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("🎵 ${entry.key.toUpperCase()}"),
                _buildCategoryList(entry.value),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCategoryList(List<Track> tracks) {
    return SizedBox(
      height: 180, // Фиксируем высоту
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tracks.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          return _buildMusicCard(tracks[index],context);
        },
      ),
    );
  }

  Widget _buildHorizontalList() {
    return StreamBuilder<List<Track>>(
      stream: _trackStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Ошибка: ${snapshot.error}',
                style: TextStyle(color: Colors.white)),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('Нет треков', style: TextStyle(color: Colors.white)),
          );
        }

        List<Track> tracks = snapshot.data!;

        return SizedBox(
          height: 200, // 🔥 Даем больше места для текста
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tracks.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              return _buildMusicCard(tracks[index],context);
            },
          ),
        );
      },
    );
  }

  Stream<List<Track>> _trackStream() async* {
    while (true) {
      yield await fetchTracks(); // 🔥 Запрашиваем треки и обновляем поток
      await Future.delayed(Duration(seconds: 10)); // 🔄 Обновляем раз в 10 сек.
    }
  }

 Widget _buildMusicCard(Track track, BuildContext context) {
  return GestureDetector(
    onTap: () {
      final player = Provider.of<MusicPlayerProvider>(context, listen: false);
      final audioUrl = "$APIROOT/api/music/play?path=${Uri.encodeComponent(track.genre)}/${Uri.encodeComponent(track.title)}.mp3";

      // Добавляем трек и сразу воспроизводим его
      player.addToQueueAndPlay(audioUrl, track.title, "Unknown Artist", track.imageUrl);
    },
    child: Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              track.imageUrl,
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                track.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}

class Track {
  final String title;
  final String imageUrl;
  final String genre; // 📌 Добавляем жанр

  Track({required this.title, required this.imageUrl, required this.genre});

  factory Track.fromJson(String genre, String filename) {
    return Track(
      title: filename.replaceAll('.mp3', ''),
      imageUrl:
          "$APIROOT/images/${Uri.encodeComponent(genre)}/${Uri.encodeComponent(filename.replaceAll('.mp3', '-main.png'))}",
      genre: genre, // 📌 Сохраняем жанр
    );
  }
}
