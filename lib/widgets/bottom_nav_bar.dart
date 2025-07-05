import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<String> stageNames;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.stageNames,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items:
          stageNames
              .map(
                (stage) => BottomNavigationBarItem(
                  icon: const Icon(Icons.music_note),
                  label: stage,
                ),
              )
              .toList(),
    );
  }
}
