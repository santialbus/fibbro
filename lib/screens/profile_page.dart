// lib/screens/profile_page.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      setState(() {
        _userData = doc.data();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_userData == null) {
      return const Scaffold(
        body: Center(child: Text('No se encontraron datos del usuario.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/editProfile');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRow(
            'Nombre',
            '${_userData!["firstName"] ?? ''} ${_userData!["lastName"] ?? ''}',
          ),
          _buildRow('Email', _auth.currentUser?.email ?? ''),
          _buildRow('Ciudad', _userData!["city"] ?? ''),
          _buildRow('País', _userData!["country"] ?? ''),
          _buildRow('Fecha de nacimiento', _userData!["birthday"] ?? ''),
          _buildRow('Género', _userData!["gender"] ?? ''),
          _buildRow(
            'Géneros favoritos',
            (_userData!["favoriteGenres"] as List?)?.join(', ') ?? '',
          ),
          _buildRow(
            'Festivales asistidos',
            (_userData!["attendedFestivals"] as List?)?.join(', ') ?? '',
          ),
          _buildRow(
            'Artistas favoritos',
            (_userData!["favoriteArtists"] as List?)?.join(', ') ?? '',
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value.isNotEmpty ? value : '-')),
        ],
      ),
    );
  }
}
