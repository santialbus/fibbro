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
    return Padding(
      // El padding que hace que todo el conjunto flote
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 32),
      child: Row(
        children: [
          // 1. LA BARRA PRINCIPAL (Cuerpo alargado)
          Expanded(
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36),
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
                    // Capa de cristal desenfocado
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(36),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    // Iconos de la barra
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
            ),
          ),

          const SizedBox(width: 12), // Espacio entre barra y buscador

          // 2. EL BOTÓN DE BÚSQUEDA (Círculo independiente)
          _buildSearchButton(),
        ],
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

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    // Verificamos si la pestaña actual es la de búsqueda (índice 3)
    bool isSelected = currentIndex == 3;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
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
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: GestureDetector(
                onTap: () => onTap(3), // Al pulsar, activamos el índice 3
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Si está seleccionado, brilla un poco más
                    color: isSelected
                        ? Colors.white.withOpacity(0.25)
                        : Colors.white.withOpacity(0.12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white.withOpacity(0.5)
                          : Colors.white.withOpacity(0.25),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}