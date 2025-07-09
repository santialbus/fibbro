import 'package:flutter/material.dart';
import 'package:myapp/screens/state_page.dart';
import 'south_beach_page.dart';
import 'heineken_stage_page.dart';
import 'cutty_shark_page.dart';
import 'repsol_page.dart';
import 'rising_stars_page.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:myapp/widgets/draggable_favorite_button.dart';

class FestivalPage extends StatefulWidget {
  final String festivalId;
  final String festivalName;
  final List<String> stageNames;
  final List<String> dates;

  const FestivalPage({
    super.key,
    required this.festivalId,
    required this.festivalName,
    required this.stageNames,
    required this.dates,
  });

  @override
  State<FestivalPage> createState() => _FestivalPageState();
}

class _FestivalPageState extends State<FestivalPage> {
  int _currentIndex = 0;

  bool get isFib => widget.festivalName.toLowerCase() == 'fib';

  // Páginas fijas para FIB
  static const List<Widget> _fibPages = [
    SouthBeachPage(),
    HeinekenStagePage(),
    CuttySharkPage(),
    RepsolPage(),
    RisingStarsPage(),
  ];

  Widget _buildStagePage() {
    return StagePage(
      key: ValueKey(widget.stageNames[_currentIndex]),
      stageName: widget.stageNames[_currentIndex],
      dates: widget.dates,
      festivalId: widget.festivalId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.festivalName), centerTitle: true),
      body: Stack(
        children: [
          // Mostrar página según si es FIB o no
          isFib ? _fibPages[_currentIndex] : _buildStagePage(),
          DraggableFavoriteButton(
            festivalId: widget.festivalId,
            dates: widget.dates,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        stageNames:
            widget.stageNames.isNotEmpty
                ? widget.stageNames
                : const [
                  'South Beach',
                  'Heineken',
                  'Cutty Shark',
                  'Repsol',
                  'Rising Stars',
                ],
      ),
    );
  }
}
