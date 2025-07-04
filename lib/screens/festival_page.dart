import 'package:flutter/material.dart';
import 'favorites_page.dart';
import 'south_beach_page.dart';
import 'heineken_stage_page.dart';
import 'cutty_shark_page.dart';
import 'repsol_page.dart';
import 'rising_stars_page.dart';
import '../widgets/bottom_nav_bar.dart';

class FestivalPage extends StatefulWidget {
  const FestivalPage({super.key});

  @override
  State<FestivalPage> createState() => _FestivalPageState();
}

class _FestivalPageState extends State<FestivalPage> {
  int _index = 0;

  final List<Widget> _pages = const [
    SouthBeachPage(),
    HeinekenStagePage(),
    FavoritesPage(),
    CuttySharkPage(),
    RepsolPage(),
    RisingStarsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
