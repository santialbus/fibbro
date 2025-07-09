// lib/widgets/draggable_favorite_button.dart
import 'package:flutter/material.dart';
import 'package:myapp/screens/favorites_page.dart';

class DraggableFavoriteButton extends StatefulWidget {
  final String festivalId;
  final List<String> dates;

  const DraggableFavoriteButton({
    super.key,
    required this.festivalId,
    required this.dates,
  });

  @override
  State<DraggableFavoriteButton> createState() => _DraggableFavoriteButtonState();
}

class _DraggableFavoriteButtonState extends State<DraggableFavoriteButton> {
  Offset fabPosition = const Offset(20, 500);
  bool _pressed = false;

  void _onFavoritePressed() async {
    if (_pressed) return;
    setState(() => _pressed = true);
    await Future.delayed(const Duration(milliseconds: 150));
    setState(() => _pressed = false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FavoritesPage(
          festivalId: widget.festivalId,
          dates: widget.dates,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final fabSize = 72.0;

    return Positioned(
      left: fabPosition.dx,
      top: fabPosition.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            double newX = fabPosition.dx + details.delta.dx;
            double newY = fabPosition.dy + details.delta.dy;
            newX = newX.clamp(0.0, screenSize.width - fabSize);
            newY = newY.clamp(0.0, screenSize.height - fabSize - kToolbarHeight);
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
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
                boxShadow: [
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
    );
  }
}
