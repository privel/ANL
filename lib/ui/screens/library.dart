import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dolby/ui/screens/favorites_provider.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Избранное', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          final favoriteTracks = favoritesProvider.favoriteTracks;

          if (favoriteTracks.isEmpty) {
            return _buildEmptyState();
          }

          return AnimatedList(
            key: GlobalKey<AnimatedListState>(),
            initialItemCount: favoriteTracks.length,
            itemBuilder: (context, index, animation) {
              final track = favoriteTracks[index];
              return _buildTrackTile(
                  track, favoritesProvider, animation, index);
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

  /// **Создает элемент списка**
  Widget _buildTrackTile(Map<String, String> track, FavoritesProvider provider,
      Animation<double> animation, int index) {
    return SizeTransition(
      sizeFactor: animation,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            track['imageUrl']!,
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
          track['title']!,
          style: const TextStyle(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () {
            provider.toggleFavorite(track);
          },
        ),
      ),
    );
  }
}
