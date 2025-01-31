import 'package:dolby/models/song_model.dart';
import 'package:dolby/services/favorite_service.dart';
import 'package:flutter/material.dart';

class FavoriteButton extends StatefulWidget {
  final SongModel song;

  const FavoriteButton({Key? key, required this.song}) : super(key: key);

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool isFavorite = false;
  final FavoriteService _favoriteService = FavoriteService();

  @override
  void initState() {
    super.initState();
    _updateFavoriteStatus(); // Проверяем, есть ли трек в избранном
  }

  /// **Обновляем состояние, если сменился трек**
  @override
  void didUpdateWidget(covariant FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.song.id != widget.song.id) {
      _updateFavoriteStatus();
    }
  }

  /// **Проверяем, есть ли текущий трек в избранном**
  Future<void> _updateFavoriteStatus() async {
    bool fav = await _favoriteService.isFavorite(widget.song.id);
    if (mounted) {
      setState(() {
        isFavorite = fav;
      });
    }
  }

  /// **Добавляем или удаляем трек из избранного**
  Future<void> _toggleFavorite() async {
    if (isFavorite) {
      await _favoriteService.removeFromFavorites(widget.song.id);
    } else {
      final songData = widget.song.toMap();

      // Проверяем, что все данные корректны перед добавлением в избранное
      songData['title'] ??= "Без названия";
      songData['artist'] ??= "Неизвестный исполнитель";
      songData['image_url'] ??= "";

      await _favoriteService.addToFavorites(widget.song.id, songData);
    }
    _updateFavoriteStatus(); // Обновляем UI
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : Colors.white,
      ),
      onPressed: _toggleFavorite,
    );
  }
}
