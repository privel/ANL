import 'package:dolby/constants/constants.dart';
import 'package:dolby/providers/music_player_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class SpotifySearchScreen extends StatefulWidget {
  @override
  _SpotifySearchScreenState createState() => _SpotifySearchScreenState();
}

class _SpotifySearchScreenState extends State<SpotifySearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Stream<List<Track>>? _searchResultsStream;
  late AnimationController _animationController;

  final List<String> popularSearches = [
    "Blinding Lights",
    "Peaches",
    "Levitating",
    "Stay",
    "Bad Guy",
    "Goosebumps",
  ];

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Stream<List<Track>> _searchTracks(String query) async* {
    if (query.isEmpty) {
      yield [];
      return;
    }

    final response = await http.get(
      Uri.parse('$APIROOT/api/music/list'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<Track> tracks = [];

      data.forEach((genre, files) {
        for (String filename in files) {
          if (filename.toLowerCase().contains(query.toLowerCase())) {
            tracks.add(Track.fromJson(genre, filename));
          }
        }
      });

      yield tracks;
    } else {
      yield [];
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchResultsStream = _searchTracks(query);
      _animationController.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Поиск', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                hintText: 'Искать музыку...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Track>>(
              stream: _searchResultsStream,
              builder: (context, snapshot) {
                if (_searchController.text.isEmpty) {
                  return _buildPopularSearches();
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingSkeleton();
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Ошибка загрузки',
                        style: TextStyle(color: Colors.white)),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Ничего не найдено',
                        style: TextStyle(color: Colors.white)),
                  );
                }

                List<Track> tracks = snapshot.data!;

                return ListView.builder(
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    return _buildTrackTile(tracks[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSearches() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Популярные запросы",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: popularSearches.map((search) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = search;
                  _onSearchChanged(search);
                },
                child: Chip(
                  backgroundColor: Colors.grey[800],
                  label: Text(search, style: TextStyle(color: Colors.white)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackTile(Track track) {
  return FadeTransition(
    opacity: _animationController,
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          track.imageUrl,
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
        track.title,
        style: const TextStyle(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track.genre,
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: const Icon(Icons.play_arrow, color: Colors.white),
      onTap: () {
        final player = Provider.of<MusicPlayerProvider>(context, listen: false);

        final audioUrl =
            "$APIROOT/api/music/play?path=${Uri.encodeComponent(track.genre)}/${Uri.encodeComponent(track.title)}.mp3";

        // Вызов метода для установки и воспроизведения трека
        player.setTrack(audioUrl, track.title, track.genre, track.imageUrl);
      },
    ),
  );
}


  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class Track {
  final String title;
  final String imageUrl;
  final String genre;

  Track({required this.title, required this.imageUrl, required this.genre});

  factory Track.fromJson(String genre, String filename) {
    return Track(
      title: filename.replaceAll('.mp3', ''),
      genre: genre,
      imageUrl:
          "$APIROOT/images/${Uri.encodeComponent(genre)}/${Uri.encodeComponent(filename.replaceAll('.mp3', '-main.png'))}",
    );
  }
}
