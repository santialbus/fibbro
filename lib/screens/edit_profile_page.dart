import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/services/user_service.dart';
import 'package:myapp/utils/app_logger.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _preferPushNotifs = true;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // ignore: unused_field
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _genresController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _attendedFestivalsController =
      TextEditingController();
  final TextEditingController _favouriteArtistsController =
      TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppLogger.page('EditProfilePage');
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return;

    final data = doc.data();
    if (data == null) return;

    setState(() {
      _userData = data;
      _firstNameController.text = data["firstName"] ?? '';
      _lastNameController.text = data["lastName"] ?? '';
      _cityController.text = data["city"] ?? '';
      _countryController.text = data["country"] ?? '';
      _birthdayController.text = data["birthday"] ?? '';
      _genderController.text = data["gender"] ?? '';
      _genresController.text =
          (data["favoriteGenres"] as List?)?.join(', ') ?? '';
      _attendedFestivalsController.text =
          (data["attendedFestivals"] as List?)?.join(', ') ?? '';
      _favouriteArtistsController.text =
          (data["favoriteArtists"] as List?)?.join(', ') ?? '';
      _bioController.text = data["bio"] ?? '';
      _preferPushNotifs = data["preferPushNotifs"] ?? true;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _birthdayController.dispose();
    _genresController.dispose();
    _genderController.dispose();
    _attendedFestivalsController.dispose();
    _favouriteArtistsController.dispose();
    _bioController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildExpansionSection(
                title: 'Información personal',
                children: [
                  _buildTextField('Nombre', _firstNameController),
                  _buildTextField('Apellido', _lastNameController),
                  _buildTextField(
                    'Fecha de nacimiento (YYYY-MM-DD)',
                    _birthdayController,
                  ),
                  _buildTextField(
                    'Género (masculino, femenino, otro)',
                    _genderController,
                  ),
                ],
              ),
              _buildExpansionSection(
                title: 'Ubicación',
                children: [
                  _buildTextField('Ciudad', _cityController),
                  _buildTextField('País', _countryController),
                ],
              ),
              _buildExpansionSection(
                title: 'Preferencias musicales',
                children: [
                  _buildTextField(
                    'Géneros favoritos (coma separados)',
                    _genresController,
                  ),
                  _buildTextField(
                    'Artistas favoritos (coma separados)',
                    _favouriteArtistsController,
                  ),
                ],
              ),
              _buildExpansionSection(
                title: 'Festivales y bio',
                children: [
                  _buildTextField(
                    'Festivales asistidos (coma separados)',
                    _attendedFestivalsController,
                  ),
                  _buildTextField('Descripción', _bioController),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Text('Perfil público'),
                          SizedBox(width: 8),
                          Tooltip(
                            message:
                                'Esta opción no se puede modificar actualmente.',
                            child: Icon(Icons.info_outline, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Switch(value: true, onChanged: null),
                  ],
                ),
              ),
              SwitchListTile(
                title: const Text('Recibir notificaciones'),
                value: _preferPushNotifs,
                onChanged: (value) => setState(() => _preferPushNotifs = value),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                child:
                    _isSaving
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: children,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final city = _cityController.text.trim();
    final country = _countryController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre y apellido son obligatorios')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final dataToUpdate = {
      'firstName': firstName,
      'lastName': lastName,
      'city': city,
      'country': country,
      'birthday': _birthdayController.text.trim(),
      'gender': _genderController.text.trim(),
      'favoriteGenres':
          _genresController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
      'attendedFestivals':
          _attendedFestivalsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
      'favoriteArtists':
          _favouriteArtistsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
      'bio': _bioController.text.trim(),
      'preferPushNotifs': _preferPushNotifs,
    };

    try {
      await UserService().updateUserProfile(user.uid, dataToUpdate);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil guardado correctamente ✅'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar los datos')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
