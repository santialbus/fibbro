// lib/screens/main_navigation.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/all_favorites_page.dart';
import 'package:myapp/screens/profile_page.dart';
import 'package:myapp/screens/search_page.dart';
import 'package:myapp/utils/app_logger.dart';
import '../widgets/liquid/liquid_bottom_nav_bar.dart';
import 'home_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool _isProfileIncomplete = false;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    AppLogger.page('MainNavigationPage');
    _checkAndCreateUserProfile();
  }

  // Helper para obtener la pantalla actual y pasarle las funciones necesarias
  Widget _getCurrentScreen() {
    switch (_currentIndex) {
      case 0: return const HomePage();
      case 1: return const AllFavoritesPage();
      case 2: return const ProfilePage();
      case 3:
        return SearchPage(
          searchQuery: _searchQuery,
          onGenreSelected: (genre) {
            setState(() {
              _searchQuery = genre;
              // Al seleccionar un género, nos aseguramos de estar en la pestaña de búsqueda
              _currentIndex = 3;
            });
          },
        );
      default: return const HomePage();
    }
  }

  Future<void> _checkAndCreateUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'uid': user.uid,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'preferences': {'notifications': true},
      });
    } else {
      final data = doc.data();
      final isIncomplete =
          data == null ||
              (data['firstName']?.toString().isEmpty ?? true) ||
              (data['lastName']?.toString().isEmpty ?? true);

      setState(() {
        _isProfileIncomplete = isIncomplete;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fondo con degradado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            // Renderizado de la pantalla actual
            child: _getCurrentScreen(),
          ),

          // BottomNavBar flotante
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LiquidBottomNavBar(
              currentIndex: _currentIndex,
              searchText: _searchQuery, // Pasamos el texto para sincronizar el TextField
              isProfileIncomplete: _isProfileIncomplete,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                  // Si cambiamos a una pestaña que no sea búsqueda, limpiamos el query (opcional)
                  if (index != 3) {
                    _searchQuery = "";
                  }
                });
              },
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                  // Si el usuario escribe, saltamos automáticamente a la SearchPage
                  if (query.isNotEmpty && _currentIndex != 3) {
                    _currentIndex = 3;
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}