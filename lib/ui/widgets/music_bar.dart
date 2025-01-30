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
          color: Colors.black.withOpacity(0.8), // const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Используем Expanded для ограничения ширины текста
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    songTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // Обрезаем текст, если он длинный
                  ),
                  Text(
                    artist,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // Обрезаем текст, если он длинный
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10), // Отступ между текстом и кнопкой
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
