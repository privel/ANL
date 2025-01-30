import 'package:flutter/material.dart';

class MusicPlayerBar extends StatelessWidget {
  final String songTitle;
  final String artist;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onOpenFullPlayer;

  const MusicPlayerBar({
    Key? key,
    required this.songTitle,
    required this.artist,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onOpenFullPlayer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpenFullPlayer,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  songTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  artist,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
              ],
            ),
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                color: Colors.white,
                size: 32,
              ),
              onPressed: onPlayPause,
            ),
          ],
        ),
      ),
    );
  }
}
