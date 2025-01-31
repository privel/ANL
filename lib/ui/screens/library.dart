import 'package:dolby/constants/constants.dart';
import 'package:dolby/providers/music_player_provider.dart';
import 'package:dolby/services/favorite_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatelessWidget {
  final FavoriteService _favoriteService = FavoriteService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Избранное', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _favoriteService.getFavoriteTracksStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("❌ Ошибка при загрузке данных: ${snapshot.error}");
            return Center(
              child: Text(
                "Ошибка загрузки: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print("⚠️ Нет избранных песен");
            return _buildEmptyState();
          }

          final favoriteTracks = snapshot.data!;
          print("✅ Загружено ${favoriteTracks.length} треков");

          return ListView.builder(
            itemCount: favoriteTracks.length,
            itemBuilder: (context, index) {
              final track = favoriteTracks[index];
              return _buildTrackTile(
                  track, _favoriteService, context, favoriteTracks);
            },
          );
        },
      ),
    );
  }

  /// **Виджет для пустого экрана**
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.favorite_border, color: Colors.white24, size: 80),
          SizedBox(height: 10),
          Text(
            'Здесь будут ваши любимые треки',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackTile(Map<String, dynamic> track, FavoriteService service,
      BuildContext context, List<Map<String, dynamic>> favoriteTracks) {
    print(track);
    return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            track['image_url'],
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 50,
              height: 50,
              color: Colors.grey[800],
              child: const Icon(Icons.music_note, color: Colors.white),
            ),
          ),
        ),
        title: Text(
          track['title'] ?? "Без названия",
          style: const TextStyle(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          track['artist'] ?? "Неизвестный исполнитель",
          style: TextStyle(color: Colors.grey.shade400),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () {
            if (track.containsKey('id') && track['id'] != null) {
              service.removeFromFavorites(track['id']!);
            } else {
              print("❌ Ошибка: у трека нет ID");
            }
          },
        ),

        /// **Добавляем запуск музыки при нажатии**
        onTap: () {
          final player =
              Provider.of<MusicPlayerProvider>(context, listen: false);

          // Формируем список треков для очереди с явным приведением типов
          List<Map<String, String>> queue = favoriteTracks
              .map((track) => {
                    "url": (track['track_url'] ?? "") as String,
                    "title": (track['title'] ?? "Без названия") as String,
                    "artist": (track['artist'] ?? "Неизвестный исполнитель")
                        as String,
                    "imageUrl": (track['image_url'] ?? "") as String,
                  })
              .toList();

          // Определяем индекс выбранного трека
          int currentIndex = favoriteTracks.indexOf(track);

          // Устанавливаем очередь и воспроизводим
          player.setQueueAndPlay(queue, currentIndex);
        });
  }
}
