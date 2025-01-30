import 'package:dolby/providers/music_player_provider.dart';
import 'package:dolby/services/auth_service.dart';
import 'package:dolby/ui/auth/login_screen.dart';
import 'package:dolby/ui/widgets/full_player.dart';
import 'package:dolby/ui/widgets/music_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dolby/ui/screens/home_screen.dart';
import 'package:dolby/ui/widgets/navigator_bar.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Инициализация Firebase
  runApp(
    ChangeNotifierProvider(
      create: (context) => MusicPlayerProvider(),
      child: const MyApp(),
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
      // home: const MyHomePage(), // Исправленный вызов главного экрана
      home: const AuthWrapper(),
    );
  }
}

// 🔥 Определяем, куда перенаправлять пользователя
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body:
                Center(child: CircularProgressIndicator()), // Ожидание загрузки
          );
        } else if (snapshot.hasData) {
          return const MyHomePage(); // Если пользователь вошел, показываем главный экран
        } else {
          return const LoginScreen(); // Если не вошел, отправляем на экран логина
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
    const HomeScreen(), // Главный экран
    const Center(child: Text("Search", style: TextStyle(color: Colors.white))),
    const Center(child: Text("Library", style: TextStyle(color: Colors.white))),
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
        return const FullMusicPlayer(); // Убираем ненужные параметры
      },
    );
  }

  
    @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    body: Column(
      children: [
        Expanded(
          child: IndexedStack(
            index: currentIndex,
            children: pages,
          ),
        ),

        // Музыкальный бар, который появится при воспроизведении музыки
        Consumer<MusicPlayerProvider>(
          builder: (context, player, _) {
            if (player.currentSong.isEmpty) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10), // Отступ над навбаром
              child: MusicPlayerBar(
                songTitle: player.currentSong,
                artist: player.artist,
                isPlaying: player.isPlaying,
                onPlayPause: player.togglePlayPause,
                onOpenFullPlayer: () => _showFullPlayer(context),
              ),
            );
          },
        ),
      ],
    ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF1A1A1A),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
              height: 30,
            ),
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
        onTap: _onTabSelected, // Исправленный обработчик
      ),
    );
  }
}
