import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final bool _isLogin = true; // Controla si estamos en login o registro
  String? _errorMessage;

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    try {
      // ⚠️ MODO DEV – LOGIN CON USUARIO HARD-CODED
      // Cambia email y password a tu usuario de prueba
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: 'damostwanted13@gmail.com',
        password: 'unlimited23',
      );

      // Navegar a la pantalla principal
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Iniciar sesión' : 'Registrarse'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email (solo visual)
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email (Modo DEV)'),
              keyboardType: TextInputType.emailAddress,
              enabled: false,
            ),

            const SizedBox(height: 16),

            // Password (solo visual)
            TextField(
              controller: _passwordController,
              decoration:
                  const InputDecoration(labelText: 'Contraseña (Modo DEV)'),
              obscureText: true,
              enabled: false,
            ),

            const SizedBox(height: 20),

            // Mostrar error si hay
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _submit,
              child: const Text('Iniciar sesión (Modo DEV)'),
            ),
          ],
        ),
      ),
    );
  }
}
