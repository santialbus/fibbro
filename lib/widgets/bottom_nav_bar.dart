import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed, // para más de 3 items
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.music_note),
          label: 'South Beach',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.music_note),
          label: 'Heineken',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.music_note),
          label: 'Cutty Shark',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'Repsol'),
        BottomNavigationBarItem(
          icon: Icon(Icons.music_note),
          label: 'Rising Stars',
        ),
      ],
    );
  }
}
