import 'package:dolby/providers/music_player_provider.dart';
import 'package:dolby/ui/screens/favorites_provider.dart';
import 'package:dolby/services/auth_service.dart';
import 'package:dolby/ui/auth/login_screen.dart';
import 'package:dolby/ui/widgets/full_player.dart';
import 'package:dolby/ui/widgets/music_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dolby/ui/screens/home_screen.dart';
import 'package:dolby/ui/screens/search.dart';
import 'package:dolby/ui/screens/library.dart';
import 'package:dolby/ui/widgets/navigator_bar.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => MusicPlayerProvider(),
      child: ChangeNotifierProvider(
        create: (context) => FavoritesProvider(), // Добавляем FavoritesProvider
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dolby',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Preloader(),
    );
  }
}

class Preloader extends StatefulWidget {
  const Preloader({super.key});

  @override
  _PreloaderState createState() => _PreloaderState();
}

class _PreloaderState extends State<Preloader> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthWrapper()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Здесь ваш логотип (например, из assets)
            Image.asset('assets/icons/icon8-png/icons8-dolby-digital-144.png',
                height: 150), // Замените на свой логотип
            const SizedBox(height: 20),
            // Анимированный прелоадер
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return MyHomePage();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;
  bool isPlaying = false;
  String currentSong = "Locked Eyes";
  String artist = "Mystery Friends";
  AuthService auth = AuthService();

  final List<Widget> pages = [
    HomeScreen(),
    SpotifySearchScreen(),
    FavoritesScreen(), // Теперь отображается экран избранного
  ];

  void _onTabSelected(int index) {
    if (currentIndex != index) {
      setState(() {
        currentIndex = index;
      });
    }
  }

  void _togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void _showFullPlayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FullMusicPlayer(
          songTitle: currentSong,
          artist: artist,
          isPlaying: isPlaying,
          onPlayPause: (bool newState) {
            setState(() {
              isPlaying = newState;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: pages,
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 10,
            child: Consumer<MusicPlayerProvider>(builder: (context, player, _) {
              return MusicPlayerBar(
                songTitle: player.currentSong,
                artist: player.artist,
                isPlaying: player.isPlaying,
                onPlayPause: player.togglePlayPause,
                onOpenFullPlayer: () => _showFullPlayer(context),
              );
            }),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1A1A1A),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 30),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.brown,
                radius: 15,
                child: Icon(
                  Icons.person,
                  color: Colors.black,
                ),
              ),
              title: Text(
                "${FirebaseAuth.instance.currentUser?.email}",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {},
            ),
            const Divider(
              thickness: 1,
              color: Colors.white24,
            ),
            ListTile(
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                auth.logout();
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
