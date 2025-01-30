import 'package:dolby/providers/music_player_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FullMusicPlayer extends StatefulWidget {
  final String songTitle;
  final String artist;
  final bool isPlaying;
  final Function(bool) onPlayPause; // Передаем управление в MyHomePage

  const FullMusicPlayer({
    Key? key,
    required this.songTitle,
    required this.artist,
    required this.isPlaying,
    required this.onPlayPause,
  }) : super(key: key);

  @override
  _FullMusicPlayerState createState() => _FullMusicPlayerState();
}

class _FullMusicPlayerState extends State<FullMusicPlayer> {
  late bool isPlaying;

  @override
  void initState() {
    super.initState();
    isPlaying = widget.isPlaying;
  }

  void _togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
    });
    widget.onPlayPause(isPlaying); // Обновляем состояние в MyHomePage
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicPlayerProvider>(builder: (context, player, _) {
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
            Text(
              player.currentSong,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              player.artist,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
            ),
            const SizedBox(height: 20),
            Icon(
              Icons.music_note,
              size: 100,
              color: Colors.white54,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous,
                      color: Colors.white, size: 40),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    player.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: Colors.white,
                    size: 60,
                  ),
                  onPressed: player
                      .togglePlayPause, // Управляем состоянием через Provider
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next,
                      color: Colors.white, size: 40),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            Slider(
              value: 0.5,
              onChanged: (value) {},
              activeColor: Colors.white,
              inactiveColor: Colors.grey,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("1:23", style: TextStyle(color: Colors.white)),
                Text("3:45", style: TextStyle(color: Colors.white)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }
}
