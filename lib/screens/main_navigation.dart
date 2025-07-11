// lib/screens/main_navigation.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/all_favorites_page.dart';
import 'package:myapp/screens/profile_page.dart';
import 'home_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool _isProfileIncomplete = false;

  final List<Widget> _screens = [
    const HomePage(),
    const AllFavoritesPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
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
  }
}
