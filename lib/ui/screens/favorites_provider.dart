import 'package:flutter/material.dart';

class FavoritesProvider with ChangeNotifier {
  final List<Map<String, String>> _favoriteTracks = [];

  List<Map<String, String>> get favoriteTracks => _favoriteTracks;

  void toggleFavorite(Map<String, String> track) {
    if (_favoriteTracks.contains(track)) {
      _favoriteTracks.remove(track);
    } else {
      _favoriteTracks.add(track);
    }
    notifyListeners();
  }
}
