import 'package:flutter/material.dart';
import 'package:myapp/screens/favorites_page.dart';
import 'package:myapp/widgets/state_page.dart';
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
  int _index = 0;
  bool _pressed = false;
  late final List<Widget> _pages;

  // Posición inicial del FAB
  Offset fabPosition = const Offset(20, 500); // ajusta según pantalla y diseño

  @override
  void initState() {
    super.initState();

    print('Festival ID: ${widget.festivalId}');
    print('Festival Name: ${widget.festivalName}');
    print('Stages: ${widget.stageNames}');
    print('Dates: ${widget.dates}');

    if (widget.festivalName.toLowerCase() == 'fib') {
      _pages = const [
        SouthBeachPage(),
        HeinekenStagePage(),
        CuttySharkPage(),
        RepsolPage(),
        RisingStarsPage(),
      ];
    } else {
      _pages =
          widget.stageNames
              .map(
                (name) => StagePage(
                  stageName: name,
                  dates: widget.dates,
                  festivalId: widget.festivalId,
                ),
              )
              .toList();
    }
  }

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
    // Para limitar el movimiento dentro de la pantalla:
    final screenSize = MediaQuery.of(context).size;
    final fabSize = 72.0; // tamaño del FAB para el cálculo del límite

    return Scaffold(
      appBar: AppBar(title: Text(widget.festivalName), centerTitle: true),
      body: Stack(
        children: [
          _pages[_index],
          // FAB draggable
          Positioned(
            left: fabPosition.dx,
            top: fabPosition.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  double newX = fabPosition.dx + details.delta.dx;
                  double newY = fabPosition.dy + details.delta.dy;

                  // Limitar para que no salga de pantalla
                  newX = newX.clamp(0.0, screenSize.width - fabSize);
                  newY = newY.clamp(
                    0.0,
                    screenSize.height - fabSize - kToolbarHeight,
                  ); // resta AppBar altura

                  fabPosition = Offset(newX, newY);
                });
              },
              onTap: _onFavoritePressed,
              child: AnimatedScale(
                scale: _pressed ? 0.9 : 1.0,
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
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        stageNames:
            widget.stageNames.isNotEmpty
                ? widget.stageNames
                : [
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
