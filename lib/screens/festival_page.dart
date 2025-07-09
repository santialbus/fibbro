import 'package:flutter/material.dart';
import 'package:myapp/screens/favorites_page.dart';
import 'package:myapp/screens/state_page.dart';
import 'south_beach_page.dart';
import 'heineken_stage_page.dart';
import 'cutty_shark_page.dart';
import 'repsol_page.dart';
import 'rising_stars_page.dart';
import '../widgets/bottom_nav_bar.dart';

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
  bool _isFabPressed = false;

  Offset _fabPosition = const Offset(20, 500);
  static const double _fabSize = 72.0;

  bool get isFib => widget.festivalName.toLowerCase() == 'fib';

  // Páginas fijas para FIB
  static const List<Widget> _fibPages = [
    SouthBeachPage(),
    HeinekenStagePage(),
    CuttySharkPage(),
    RepsolPage(),
    RisingStarsPage(),
  ];

  void _onFavoritePressed() async {
    if (_isFabPressed) return;
    setState(() => _isFabPressed = true);

    await Future.delayed(const Duration(milliseconds: 150));

    setState(() => _isFabPressed = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => FavoritesPage(
              festivalId: widget.festivalId,
              dates: widget.dates,
            ),
      ),
    );
  }

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
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: Text(widget.festivalName), centerTitle: true),
      body: Stack(
        children: [
          // Mostrar página según si es FIB o no
          isFib ? _fibPages[_currentIndex] : _buildStagePage(),

          // FAB flotante con drag
          Positioned(
            left: _fabPosition.dx,
            top: _fabPosition.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  double newX = _fabPosition.dx + details.delta.dx;
                  double newY = _fabPosition.dy + details.delta.dy;

                  // Limitar dentro de la pantalla
                  newX = newX.clamp(0.0, screenSize.width - _fabSize);
                  newY = newY.clamp(
                    0.0,
                    screenSize.height - _fabSize - kToolbarHeight,
                  );
                  _fabPosition = Offset(newX, newY);
                });
              },
              onTap: _onFavoritePressed,
              child: AnimatedScale(
                scale: _isFabPressed ? 0.9 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.star,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
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
