import 'dart:ui';
import 'package:flutter/material.dart';

class LiquidBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isProfileIncomplete;

  const LiquidBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.isProfileIncomplete = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Padding externo para que flote
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        // Sombra muy suave para dar profundidad sin ensuciar
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Stack(
          children: [
            // CAPA 1: El desenfoque
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  // IMPORTANTE: Un color base para que el filtro no "desaparezca"
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(36),
                  // Borde sutil integrado
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            // CAPA 2: Los Iconos
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home_rounded, 0),
                  _buildNavItem(Icons.favorite_rounded, 1),
                  _buildProfileItem(Icons.person_rounded, 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool selected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 60,
        child: AnimatedScale(
          // Si está seleccionado se agranda un poco, si no, vuelve a su tamaño
          scale: selected ? 1.2 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack, // Efecto rebote suave
          child: Icon(
            icon,
            size: 28,
            color: selected ? Colors.white : Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, int index) {
    bool selected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: selected ? Colors.white : Colors.white.withOpacity(0.5),
            ),
            if (isProfileIncomplete)
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}