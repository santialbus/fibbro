import 'dart:ui';
import 'package:flutter/material.dart';

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
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double totalWidth = constraints.maxWidth - 40;

        // Configuramos dos alturas: una para la barra normal y otra para el modo búsqueda
        double normalHeight = 72.0;
        double searchHeight = 60.0; // Altura más pequeña para el "modo Apple"

        double currentHeight = _isSearching ? searchHeight : normalHeight;

        return Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 32),
          child: AnimatedContainer( // Este envuelve a todo el Row para animar la altura del conjunto
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            height: currentHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              // Asegura que las piezas estén alineadas
              children: [
                // 1. PIEZA IZQUIERDA (HOME)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  width: _isSearching ? 60.0 : totalWidth - 72 - 12, // Ajustamos a la nueva altura
                  height: _isSearching ? 60.0 : 72.0,
                  decoration: _glassDecoration(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: Stack(
                      children: [
                        _glassEffect(),
                        Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _isSearching
                                ? GestureDetector(
                              key: const ValueKey("home_small"),
                              onTap: () {
                                // Acción 1: Volver a la pestaña Home (index 0)
                                widget.onTap(0);
                                // Acción 2: Cerrar el buscador para volver al estado normal
                                setState(() => _isSearching = false);
                                _controller.clear();
                                widget.onSearchChanged('');
                              },
                              behavior: HitTestBehavior.opaque,
                              child: const SizedBox(
                                width: 60,
                                height: 60,
                                child: Icon(Icons.home_rounded, color: Colors.white, size: 24),
                              ),
                            )
                                : Row(
                              key: const ValueKey("full_nav"),
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildNavItem(Icons.home_rounded, 0),
                                _buildNavItem(Icons.favorite_rounded, 1),
                                _buildProfileItem(Icons.person_rounded, 2),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // 2. PIEZA DERECHA (BUSCADOR)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  width: _isSearching ? totalWidth - searchHeight - 12 : 72,
                  height: currentHeight,
                  // Se ajusta dinámicamente
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

  // --- COMPONENTES AUXILIARES ---

  Widget _buildSearchIcon() {
    return Center(
      child: IconButton(
        icon: const Icon(Icons.search_rounded, color: Colors.white, size: 28),
        onPressed: () => setState(() => _isSearching = true),
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      // Aseguramos que el contenido ocupe todo el alto para poder centrar
      height: 72,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Centrado vertical de iconos y texto
        children: [
          // 1. Icono Lupa
          const Icon(Icons.search_rounded, color: Colors.white70, size: 22),

          const SizedBox(width: 8),

          // 2. Campo de Texto flexible
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              textAlignVertical: TextAlignVertical.center, // Crucial para el centrado vertical
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                decoration: TextDecoration.none, // Evita líneas raras debajo
              ),
              decoration: const InputDecoration(
                hintText: "Search festivals...",
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                isCollapsed: true, // Elimina todo el padding interno por defecto de Flutter
                contentPadding: EdgeInsets.only(top: 2), // Ajuste fino manual si es necesario
              ),
              onChanged: widget.onSearchChanged,
            ),
          ),

          const SizedBox(width: 8),

          // 3. Botón de Cerrar (Usamos GestureDetector para evitar el padding del IconButton)
          GestureDetector(
            onTap: () {
              setState(() => _isSearching = false);
              _controller.clear();
              widget.onSearchChanged('');
            },
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4.0), // Padding mínimo para facilitar el toque
              child: Icon(Icons.close_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _glassDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(36),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget _glassEffect() {
    return BackdropFilter(
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

  Widget _buildNavItem(IconData icon, int index) {
    bool selected = widget.currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (_isSearching) setState(() => _isSearching = false);
        widget.onTap(index);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 60,
        child: AnimatedScale(
          scale: selected ? 1.2 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Icon(icon, size: 28, color: selected ? Colors.white : Colors.white.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, int index) {
    bool selected = widget.currentIndex == index;
    return GestureDetector(
      onTap: () => widget.onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 28, color: selected ? Colors.white : Colors.white.withOpacity(0.5)),
            if (widget.isProfileIncomplete)
              Positioned(
                top: 15,
                right: 15,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.orangeAccent, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}