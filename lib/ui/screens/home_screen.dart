import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

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
        Uri.parse('https://7cd3-2-135-31-28.ngrok-free.app/api/music/list'));

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
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      const SizedBox(height: 30),
                      _buildSectionTitle("🔥 Популярное"),
                      _buildHorizontalList(),
                      _buildSectionTitle("🎧 Рекомендуем"),
                      _buildHorizontalList(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        Positioned.fill(child: _buildSoundWave()),
        Positioned(
          top: 120,
          left: 20,
          right: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildPlayButton(),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
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
                    SizedBox(height: 6),
                    Text(
                      "Персональная подборка треков",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSoundWave() {
    return Positioned(
      bottom: 80,
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

  Widget _buildPlayButton() {
    return ScaleTransition(
      scale: _pulseController,
      child: GestureDetector(
        onTap: () {
          print("🎵 Музыка запущена...");
        },
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: const Icon(Icons.play_arrow_rounded,
              color: Colors.black, size: 50),
        ),
      ),
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

  Widget _buildHorizontalList() {
    return StreamBuilder<List<Track>>(
      stream: _trackStream(), // 🔥 Используем Stream вместо Future
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
              return _buildMusicCard(tracks[index]);
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

  Widget _buildMusicCard(Track track) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // 🔥 Ограничиваем размер
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(track.imageUrl,
                width: double.infinity, height: 120, fit: BoxFit.cover),
          ),
          Expanded(
            // 🔥 Исправляет выход текста за границы
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                track.title,
                maxLines: 2, // 🔥 Ограничиваем до 2 строк
                overflow: TextOverflow.ellipsis, // 🔥 Добавляем "..."
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Track {
  final String title;
  final String imageUrl;

  Track({required this.title, required this.imageUrl});

  factory Track.fromJson(String genre, String filename) {
    return Track(
      title: filename.replaceAll('.mp3', '-main.png'),
      imageUrl:
          "https://7cd3-2-135-31-28.ngrok-free.app/images/${Uri.encodeComponent(genre)}/${Uri.encodeComponent(filename.replaceAll('.mp3', '-main.png'))}",
    );
  }
}
