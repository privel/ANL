import 'package:dolby/providers/music_player_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FullMusicPlayer extends StatefulWidget {
  const FullMusicPlayer({Key? key}) : super(key: key);

  @override
  _FullMusicPlayerState createState() => _FullMusicPlayerState();
}

class _FullMusicPlayerState extends State<FullMusicPlayer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MusicPlayerProvider>(
      builder: (context, player, _) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Обложка трека
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  player.imageUrl, // Обложка из провайдера
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.music_note,
                    size: 100,
                    color: Colors.white54,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Название трека и артист
              Text(
                player.currentSong,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                player.artist,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
              ),
              const SizedBox(height: 20),

              // Контролы воспроизведения
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous,
                        color: Colors.white, size: 40),
                    onPressed: player.seekToPrevious, // Переключение на предыдущий трек
                  ),
                  IconButton(
                    icon: Icon(
                      player.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: Colors.white,
                      size: 60,
                    ),
                    onPressed: player.togglePlayPause, // Воспроизведение/пауза
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next,
                        color: Colors.white, size: 40),
                    onPressed: player.seekToNext, // Переключение на следующий трек
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Ползунок прогресса
              StreamBuilder<Duration>(
                stream: player.audioPlayer.positionStream,
                builder: (context, snapshot) {
                  final currentPosition = snapshot.data ?? Duration.zero;
                  final totalDuration = player.audioPlayer.duration ?? Duration.zero;

                  return Column(
                    children: [
                      Slider(
                        value: currentPosition.inSeconds.toDouble(),
                        max: totalDuration.inSeconds.toDouble(),
                        onChanged: (value) {
                          player.seek(Duration(seconds: value.toInt())); // Перемотка
                        },
                        activeColor: Colors.green ,
                        inactiveColor: Colors.grey,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(currentPosition),
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            _formatDuration(totalDuration),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Преобразуем `Duration` в `mm:ss`
  String _formatDuration(Duration duration) {
    String minutes = duration.inMinutes.toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
