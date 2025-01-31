import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Получаем ID текущего пользователя
  String? get _userId => _auth.currentUser?.uid;

  /// ✅ Добавить песню в избранное
  Future<void> addToFavorites(String songId, Map<String, dynamic> songData) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(songId)
        .set(songData);
  }

  /// ❌ Удалить песню из избранного
  Future<void> removeFromFavorites(String songId) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(songId)
        .delete();
  }

  /// 🔍 Проверить, находится ли песня в избранном
  Future<bool> isFavorite(String songId) async {
    if (_userId == null) return false;
    var doc = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(songId)
        .get();
    return doc.exists;
  }
Stream<List<Map<String, dynamic>>> getFavoriteTracksStream() {
  if (_userId == null) {
    print("❌ Пользователь не авторизован");
    return const Stream.empty();
  }

  return _firestore
      .collection('users')
      .doc(_userId)
      .collection('favorites')
      .snapshots()
      .map((snapshot) {
    print("🔥 Получены данные из Firestore: ${snapshot.docs.length} записей");

    return snapshot.docs.map((doc) {
      final data = doc.data(); // Получаем данные документа
      print("🎵 Трек: ${data['title']} - ${data['artist']}");

      return {
        'id': data.containsKey('id') ? data['id'] : doc.id,
        'title': data.containsKey('title') ? data['title'] : 'Без названия',
        'artist': data.containsKey('artist') ? data['artist'] : 'Неизвестный исполнитель',
        'image_url': data.containsKey('image_url') ? data['image_url'] : '',
        'track_url': data.containsKey('track_url') ? data['track_url'] : '',
      };
    }).toList();
  });
}


}
