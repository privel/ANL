import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: DolbyPreloader(),
        ),
      ),
    );
  }
}

class DolbyPreloader extends StatefulWidget {
  @override
  _DolbyPreloaderState createState() => _DolbyPreloaderState();
}

class _DolbyPreloaderState extends State<DolbyPreloader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Инициализация контроллера анимации
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Анимация для постепенного появления
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Анимация для масштаба (эффект увеличения)
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    // Анимация для плавного движения (эффект скольжения)
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, -0.1),
      end: Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Запуск анимации
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Логотип с анимацией появления, увеличения и скольжения
        SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                  'assets/icons/icon8-png/icons8-dolby-digital-144.png',
                  width: 120,
                  height: 120),
            ),
          ),
        ),
        SizedBox(height: 20),
        // Текст "Dolby" с анимацией появления
        FadeTransition(
          opacity: _opacityAnimation,
          child: Text(
            'Dolby',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0, // Пространство между буквами
            ),
          ),
        ),
      ],
    );
  }
}
