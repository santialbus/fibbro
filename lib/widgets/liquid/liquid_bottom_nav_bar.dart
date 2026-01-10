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
        double totalWidth = constraints.maxWidth - 40;
        bool isProfile = widget.currentIndex == 2; // Lógica para Perfil

        // Mantenemos tus alturas originales que se veían bien
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
                  width: isProfile ? totalWidth : (_isSearching ? 60.0 : totalWidth - 72 - 12),
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
                              mainAxisAlignment: isProfile ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.spaceAround,
                              children: [
                                // USAMOS EXPANDED PARA QUE NO HAYA OVERFLOW HORIZONTAL
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

                // Espaciador que desaparece si estás en Perfil o Buscando
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: (isProfile || _isSearching) ? 0 : 12,
                ),
                if (_isSearching) const SizedBox(width: 12),

                // 2. PIEZA DERECHA (BUSCADOR) - Se oculta en Perfil
                if (!isProfile)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                    width: _isSearching ? totalWidth - 60 - 12 : 72,
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

  // --- ITEM NAVEGACIÓN CON BURBUJA (ZOOM AL TOCAR) ---
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
          clipBehavior: Clip.none, // IMPORTANTE: Permite que la burbuja sobresalga de la barra
          children: [
            // LA BURBUJA (EL EFECTO LUPA)
            AnimatedScale(
              // Si presionas, crece un 35% para crear ese efecto de "lupa"
              scale: isPressing ? 1.35 : (isSelected ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack, // Efecto rebote de Apple
              child: Container(
                width: 75, // Más ancha que el área normal para que se note la burbuja
                height: 55,
                decoration: BoxDecoration(
                  // Brillo intenso en presión
                  color: Colors.white.withOpacity(isPressing ? 0.25 : 0.15),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (isPressing)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                  ],
                ),
              ),
            ),

            // EL CONTENIDO (Icono y Texto)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: isPressing ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    icon,
                    color: (isSelected || isPressing) ? Colors.white : Colors.white.withOpacity(0.5),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: (isSelected || isPressing) ? Colors.white : Colors.white.withOpacity(0.5),
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- BUSCADOR RESTAURADO (VALORES DE image_849ae3.png) ---
  Widget _buildSearchInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 60, // Altura exacta del modo búsqueda
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.search_rounded, color: Colors.white70, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.none),
              decoration: const InputDecoration(
                hintText: "Search festivals...",
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.only(top: 2),
              ),
              onChanged: widget.onSearchChanged,
            ),
          ),
          const SizedBox(width: 8),
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchPage(
                searchQuery: "", // Inicialmente vacío
                onGenreSelected: (genre) {
                  print("Seleccionado: $genre");
                  // Aquí manejas la lógica cuando toquen un género
                },
              ),
            ),
          );
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

  // --- DECORACIÓN GLASS ---
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