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
  String _searchQuery = ""; // Añade esto arriba

  late final List<Widget> _screens = [
    const HomePage(),
    const AllFavoritesPage(),
    const ProfilePage(),
    SearchPage(
      searchQuery: _searchQuery,
      onGenreSelected: (genre) {
        setState(() {
          _searchQuery = genre;
          // Si tu LiquidBottomNavBar tiene un controlador interno,
          // deberías actualizarlo aquí también
        });
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    AppLogger.page('MainNavigationPage');
    _checkAndCreateUserProfile();
  }

  void _onTabTapped(int index) async {
    // Si estamos en la pestaña de perfil
    setState(() => _currentIndex = index);

    // Solo si es la pestaña perfil, recarga el estado del perfil incompleto
    if (index == 2) {
      await _checkAndCreateUserProfile();
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueGrey.shade900, Colors.blueGrey.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            // Usamos la lista local 'screens'
            child: _screens[_currentIndex],
          ),

          // BottomNavBar flotante (SIEMPRE visible porque está en el Stack)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: LiquidBottomNavBar(
              currentIndex: _currentIndex,
              isProfileIncomplete: _isProfileIncomplete,
              onTap: (index) => setState(() => _currentIndex = index),
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                  // Si el usuario empieza a escribir, lo llevamos a la pestaña de búsqueda
                  if (query.isNotEmpty) {
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

  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.person),
                if (_isProfileIncomplete)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: _isProfileIncomplete ? 'Perfil (!)' : 'Perfil',
          ),
        ],
      ),
    );
  }*/
}
