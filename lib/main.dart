import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dolby/ui/screens/home_screen.dart';
import 'package:dolby/ui/widgets/navigator_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Инициализация Firebase
  runApp(const MyApp());
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
      home: const MyHomePage(), // Исправленный вызов главного экрана
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: currentIndex,
        children: pages, // Сохранение состояния экранов
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onTabSelected, // Исправленный обработчик
      ),
    );
  }
}
