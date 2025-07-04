import 'package:flutter/material.dart';
import 'package:myapp/screens/favorites_page.dart';
import 'south_beach_page.dart';
import 'heineken_stage_page.dart';
import 'cutty_shark_page.dart';
import 'repsol_page.dart';
import 'rising_stars_page.dart';
import '../widgets/bottom_nav_bar.dart';

class FestivalPage extends StatefulWidget {
  final String festivalId;
  final String festivalName;

  const FestivalPage({
    super.key,
    required this.festivalId,
    required this.festivalName,
  });

  @override
  State<FestivalPage> createState() => _FestivalPageState();
}

class _FestivalPageState extends State<FestivalPage> {
  int _index = 0;
  bool _pressed = false;

  final List<Widget> _pages = const [
    SouthBeachPage(),
    HeinekenStagePage(),
    CuttySharkPage(),
    RepsolPage(),
    RisingStarsPage(),
  ];

  void _onFavoritePressed() async {
    if (_pressed) return; // prevenir doble tap rápido
    setState(() => _pressed = true);
    await Future.delayed(const Duration(milliseconds: 150));
    setState(() => _pressed = false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FavoritesPage(festivalId: widget.festivalId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.festivalName), centerTitle: true),
      body: Stack(
        children: [
          _pages[_index],
          Positioned(
            bottom: 5,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedScale(
                scale: _pressed ? 0.9 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(100),
                    onTap: _onFavoritePressed,
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
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
