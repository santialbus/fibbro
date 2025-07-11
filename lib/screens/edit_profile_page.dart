import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/services/user_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _preferPushNotifs = true;

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
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('Nombre', _firstNameController),
              _buildTextField('Apellido', _lastNameController),
              _buildTextField('Ciudad', _cityController),
              _buildTextField('País', _countryController),
              _buildTextField(
                'Fecha de nacimiento (YYYY-MM-DD)',
                _birthdayController,
              ),
              _buildTextField(
                'Género (masculino, femenino, otro)',
                _genderController,
              ),
              _buildTextField(
                'Géneros favoritos (coma separados)',
                _genresController,
              ),
              _buildTextField(
                'Festivales asistidos (coma separados)',
                _attendedFestivalsController,
              ),
              _buildTextField(
                'Artistas favoritos (coma separados)',
                _favouriteArtistsController,
              ),
              _buildTextField('Descripción', _bioController),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Text('Perfil público'),
                          const SizedBox(width: 8),
                          Tooltip(
                            message:
                                'Esta opción no se puede modificar actualmente.',
                            child: const Icon(
                              Icons.info_outline,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: true,
                      onChanged: null, // Deshabilitado
                    ),
                  ],
                ),
              ),
              SwitchListTile(
                title: const Text('Recibir notificaciones'),
                value: _preferPushNotifs,
                onChanged: (value) {
                  setState(() {
                    _preferPushNotifs = value;
                  });
                },
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
      'preferences': {'notifications': _preferPushNotifs},
    };

    try {
      await UserService().updateUserProfile(user.uid, dataToUpdate);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error al guardar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar los datos')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
