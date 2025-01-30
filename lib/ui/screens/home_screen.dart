import 'package:flutter/material.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

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

  /// **Градиентный фон в стиле Яндекс Музыки**
  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.0, -0.6),
          radius: 1.5,
          colors: [
            Color(0xFFFF6B6B), // Красно-оранжевый
            Color(0xFFFF8C42), // Оранжево-жёлтый
            Color(0xFF1A1A1A), // Тёмный фон
          ],
        ),
      ),
    );
  }

  /// **Блок "Моя волна" с новой адаптивностью**
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
                // Исправлено, чтобы текст не выходил за пределы
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

  /// **Новая звуковая волна**
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

  /// **Отдельная полоса звуковой волны**
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

  /// **Обновленная кнопка Play**
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
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.6),
                blurRadius: 35,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.black,
            size: 50,
          ),
        ),
      ),
    );
  }

  /// **Заголовки секций**
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

  /// **Горизонтальный список карточек треков**
  Widget _buildHorizontalList() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          return _buildMusicCard();
        },
      ),
    );
  }

  /// **Карточка с песней**
  Widget _buildMusicCard() {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.asset(
              "assets/music_placeholder.png",
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Название трека",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Исполнитель",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
