import 'package:dolby/models/song_model.dart';
import 'package:flutter/material.dart';

import 'favorite_button.dart';

class MusicPlayerBar extends StatelessWidget {
  final SongModel song;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onOpenFullPlayer;

  const MusicPlayerBar({
    Key? key,
    required this.song,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    song.artist,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10), // Отступ между текстом и кнопками

            FavoriteButton(song: song),

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
