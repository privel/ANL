import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(3, (index) {
                final icons = [
                  [UniconsLine.estate, 'Home'],
                  [UniconsLine.search, 'Search'],
                  [UniconsLine.music, 'Library'],
                ];

                bool isSelected = currentIndex == index;

                return GestureDetector(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icons[index][0] as IconData,
                        color: isSelected ? Colors.white : Colors.grey.shade500,
                        size: isSelected ? 24 : 22,
                      ),
                      Text(
                        icons[index][1] as String,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSelected ? 12 : 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
