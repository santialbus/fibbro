import 'dart:ui';
import 'package:flutter/material.dart';
import '../../screens/search_page.dart';

class LiquidBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isProfileIncomplete;
  final Function(String) onSearchChanged;

  const LiquidBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.isProfileIncomplete = false,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  State<LiquidBottomNavBar> createState() => _LiquidBottomNavBarState();
}

class _LiquidBottomNavBarState extends State<LiquidBottomNavBar> {
  bool _isSearching = false;
  int? _pressingIndex;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 40 de margen (20 izquierda + 20 derecha)
        double totalWidth = constraints.maxWidth - 40;

        // Definimos el ancho de la pieza de búsqueda para poder restarlo con precisión
        const double searchIconWidth = 72.0;
        const double spacing = 12.0;

        double normalHeight = 72.0;
        double searchHeight = 60.0;
        double currentHeight = _isSearching ? searchHeight : normalHeight;

        return Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 32),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            height: currentHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. PIEZA IZQUIERDA (NAVEGACIÓN)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutBack,
                  // Si estamos buscando, se encoge a un círculo (60).
                  // Si NO estamos buscando, ocupa el ancho total MENOS el espacio del buscador.
                  width: _isSearching ? 60.0 : (totalWidth - searchIconWidth - spacing),
                  height: _isSearching ? 60.0 : 72.0,
                  decoration: _glassDecoration(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: Stack(
                      children: [
                        _glassEffect(),
                        Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _isSearching
                                ? _buildHomeSmall()
                                : Row(
                              key: const ValueKey("full_nav"),
                              // Cambiado a spaceEvenly para evitar que los iconos se peguen a los bordes
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildTabItem(Icons.home_rounded, "Inicio", 0),
                                _buildTabItem(Icons.favorite_rounded, "Favoritos", 1),
                                _buildTabItem(Icons.person_rounded, "Perfil", 2),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: spacing),

                // 2. PIEZA DERECHA (BUSCADOR) - SIEMPRE RENDERIZADA
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  // Si buscamos, se expande. Si no, se queda en 72.
                  width: _isSearching ? (totalWidth - 60.0 - spacing) : searchIconWidth,
                  height: currentHeight,
                  decoration: _glassDecoration(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: Stack(
                      children: [
                        _glassEffect(),
                        _isSearching ? _buildSearchInput() : _buildSearchIcon(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- MÉTODOS DE APOYO (Mantienen tu lógica de diseño) ---

  Widget _buildTabItem(IconData icon, String label, int index) {
    bool isSelected = widget.currentIndex == index;
    bool isPressing = _pressingIndex == index;

    return Listener(
      onPointerDown: (_) => setState(() => _pressingIndex = index),
      onPointerUp: (_) => setState(() => _pressingIndex = null),
      onPointerCancel: (_) => setState(() => _pressingIndex = null),
      child: GestureDetector(
        onTap: () {
          if (_isSearching) setState(() => _isSearching = false);
          widget.onTap(index);
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            AnimatedScale(
              scale: isPressing ? 1.35 : (isSelected ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Container(
                width: 75,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(isPressing ? 0.25 : 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: (isSelected || isPressing) ? Colors.white : Colors.white.withOpacity(0.5),
                  size: 26,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: (isSelected || isPressing) ? Colors.white : Colors.white.withOpacity(0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 60,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.search_rounded, color: Colors.white70, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                hintText: "Search festivals...",
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
              onChanged: widget.onSearchChanged,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() => _isSearching = false);
              _controller.clear();
              widget.onSearchChanged('');
            },
            child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchIcon() {
    return Center(
      child: IconButton(
        icon: const Icon(Icons.search_rounded, color: Colors.white, size: 28),
        onPressed: () {
          // 1. Activamos el modo visual de búsqueda (el campo de texto)
          setState(() => _isSearching = true);

          // 2. IMPORTANTE: Avisamos al MainNavigation para que cambie a la pestaña 2 (SearchPage)
          // Asumiendo que en tu MainNavigation la lista es: [Home, Favoritos, Search, Perfil]
          // Si Search es la tercera posición, el índice es 2.
          widget.onTap(3);
        },
      ),
    );
  }

  Widget _buildHomeSmall() {
    return GestureDetector(
      onTap: () {
        widget.onTap(0);
        setState(() => _isSearching = false);
        _controller.clear();
        widget.onSearchChanged('');
      },
      child: const Center(child: Icon(Icons.home_rounded, color: Colors.white, size: 24)),
    );
  }

  BoxDecoration _glassDecoration() => BoxDecoration(
    borderRadius: BorderRadius.circular(36),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))],
  );

  Widget _glassEffect() => BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
      ),
    ),
  );
}