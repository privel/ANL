class SongModel {
  final String id;
  final String title;
  final String artist;
  final String url_track;
  final String imageUrl;

  SongModel({required this.id, required this.title, required this.artist, required this.imageUrl, required this.url_track});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'track_url': url_track,
      'image_url': imageUrl,
    };
  }

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      url_track: map['track_url'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
