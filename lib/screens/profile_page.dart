import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/edit_profile_page.dart';
import 'package:myapp/utils/app_logger.dart';

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
    AppLogger.page('ProfilePage');
    _loadUserData();
  }

  void _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text('¿Seguro que quieres cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      // Aquí redirige al login o donde corresponda
      Navigator.of(context).pushReplacementNamed('/login');
    }
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

  String _getPartyLevel(int count) {
    if (count >= 10) return 'Leyenda 🏆';
    if (count >= 5) return 'Fiestero Medio 🎉';
    if (count > 0) return 'Principiante 🕺';
    return 'Sin historial 🙃';
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
            onPressed: () async {
              final result = await Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder:
                      (context, animation, secondaryAnimation) =>
                          const EditProfilePage(),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              );

              if (result == true) {
                await _loadUserData();
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(
                    'assets/images/user_placeholder.png',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${_userData!["firstName"] ?? ''} ${_userData!["lastName"] ?? ''}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _auth.currentUser?.email ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Divider(height: 32),
                _buildField(Icons.location_city, 'Ciudad', _userData!["city"]),
                _buildField(Icons.public, 'País', _userData!["country"]),
                _buildField(
                  Icons.cake,
                  'Fecha de nacimiento',
                  _userData!["birthday"],
                ),
                _buildField(Icons.person, 'Género', _userData!["gender"]),
                _buildField(
                  Icons.music_note,
                  'Géneros favoritos',
                  (_userData!["favoriteGenres"] as List?)?.join(', ') ?? '',
                ),
                _buildField(
                  Icons.festival,
                  'Festivales asistidos',
                  (_userData!["attendedFestivals"] as List?)?.join(', ') ?? '',
                ),
                _buildField(
                  Icons.star,
                  'Artistas favoritos',
                  (_userData!["favoriteArtists"] as List?)?.join(', ') ?? '',
                ),
                _buildField(
                  Icons.info_outline,
                  'Descripción',
                  _userData!["bio"] ?? '',
                ),
                _buildField(
                  Icons.visibility,
                  'Perfil público',
                  (_userData!["isPublicProfile"] == true) ? 'Sí' : 'No',
                ),
                _buildField(
                  Icons.notifications,
                  'Notificaciones Push',
                  (_userData!["preferences"]?["notifications"] == true)
                      ? 'Sí'
                      : 'No',
                ),
                _buildFieldWithNote(
                  Icons.public,
                  'Perfil público',
                  (_userData!["isPublicProfile"] == true) ? 'Sí' : 'No',
                  'Esta opción no se puede modificar por ahora',
                ),
                _buildField(
                  Icons.celebration,
                  'Nivel Fiestero 🥳',
                  _getPartyLevel(
                    (_userData?['attendedFestivals'] as List?)?.length ?? 0,
                  ),
                ),
                _buildField(
                  Icons.calendar_today,
                  'Cuenta creada',
                  (_userData!["createdAt"] as Timestamp?)
                          ?.toDate()
                          .toLocal()
                          .toString()
                          .split(' ')
                          .first ??
                      '-',
                ),
                _buildField(
                  Icons.login,
                  'Último acceso',
                  _auth.currentUser?.metadata.lastSignInTime
                          ?.toLocal()
                          .toString()
                          .split(' ')
                          .first ??
                      '-',
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  value != null && value.isNotEmpty ? value : '-',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldWithNote(
    IconData icon,
    String label,
    String? value,
    String? note,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (note != null) ...[
                      const SizedBox(width: 4),
                      Tooltip(
                        message: note,
                        child: const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  value != null && value.isNotEmpty ? value : '-',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
