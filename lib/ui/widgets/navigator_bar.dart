import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class CustomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: Colors.transparent, // Убираем индикатор
        overlayColor: MaterialStateProperty.all(
            Colors.transparent), // Отключаем эффект выделения
      ),
      child: NavigationBar(
        backgroundColor: const Color(0xFF1a1a1a),
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
          widget.onTap(index);
        },
        selectedIndex: selectedIndex,
        destinations: List.generate(3, (index) {
          final icons = [
            [UniconsLine.camera, Icons.home_outlined, 'Home'],
            [Icons.notifications, Icons.notifications_outlined, 'Search'],
            [Icons.messenger, Icons.messenger_outline, 'Your Library'],
          ];

          bool isSelected = selectedIndex == index;

          return NavigationDestination(
            selectedIcon: AnimatedScale(
              scale: isSelected ? 1.2 : 1.0, // Анимация увеличения
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut, // Плавность анимации
              child: Icon(
                icons[index][0] as IconData,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
            icon: Icon(
              icons[index][1] as IconData,
              color: Colors.grey, // Все неактивные иконки серые
            ),
            label: icons[index][2] as String,
          );
        }),
        labelBehavior: NavigationDestinationLabelBehavior
            .alwaysShow, // Всегда показывать текст
      ),
    );
  }
}
