import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _signIn() async {
  setState(() => _loading = true);
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _email.text.trim(),
      password: _pass.text.trim(),
    );

    // 1. Traer rol desde Firestore
    final uid  = FirebaseAuth.instance.currentUser!.uid;
    final doc  = await FirebaseFirestore.instance
        .collection('users').doc(uid).get();
    final role = doc.data()?['role'] as String? ?? 'resident';

    if (!mounted) return;

    // 2. Redirigir según rol
    switch (role) {
      case 'guard':
        Navigator.pushReplacementNamed(context, '/guard');
        break;
      case 'admin':
        Navigator.pushReplacementNamed(context, '/admin');
        break;
      case 'resident':
      default:
        Navigator.pushReplacementNamed(context, '/resident');
    }
  } on FirebaseAuthException catch (e) {
    setState(() => _error = e.message);
  } finally {
    setState(() => _loading = false);
  }
}


// Register
  Future<void> _register() async {
  setState(() => _loading = true);
  try {
    // 1. Crea el usuario en Firebase Auth
    final cred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: _email.text.trim(), password: _pass.text.trim());

    // 2. Guarda su rol en Firestore (por defecto 'resident', o 'admin' si el correo es admin@sgav.com)
    final email = cred.user!.email;
    final role = email == 'admin@sgav.com' ? 'admin' : 'resident';
    await FirebaseFirestore.instance
        .collection('users')
        .doc(cred.user!.uid)
        .set({
          'email': email,
          'role': role,
        });

    if (!mounted) return;
    // 3. Redirige a la vista del residente
    Navigator.pushReplacementNamed(context, '/resident');
  } on FirebaseAuthException catch (e) {
    setState(() => _error = e.message);
  } finally {
    setState(() => _loading = false);
  }
}

// Botones rápidos de autologin (solo en modo debug)
Widget _quickLoginButtons() {
  if (!kDebugMode) return const SizedBox.shrink();
  return Column(
    children: [
      ElevatedButton(
        onPressed: () {
          _email.text = 'admin@sgav.dev';
          _pass.text  = 'SGAV1234';
        },
        child: const Text('Autocompletar Admin'),
      ),
      ElevatedButton(
        onPressed: () {
          _email.text = 'resident@sgav.dev';
          _pass.text  = 'Qwerty123';
        },
        child: const Text('Autocompletar Residente 1'),
      ),
      ElevatedButton(
        onPressed: () {
          _email.text = 'resident2@sgav.dev';
          _pass.text  = 'Qwerty123';
        },
        child: const Text('Autocompletar Residente 2'),
      ),
      ElevatedButton(
        onPressed: () {
          _email.text = 'guard@sgav.dev';
          _pass.text  = 'Qwerty123';
        },
        child: const Text('Autocompletar Guardia 1'),
      ),
      
    ],
  );
}
// Botones rápidos de autologin (solo en modo debug)
Widget _quickLoginButtons() {
  if (!kDebugMode) return const SizedBox.shrink();
  return Column(
    children: [
      ElevatedButton(
        onPressed: () {
          _email.text = 'admin@sgav.dev';
          _pass.text  = 'SGAV1234';
        },
        child: const Text('Autocompletar Admin'),
      ),
      ElevatedButton(
        onPressed: () {
          _email.text = 'resident@sgav.dev';
          _pass.text  = 'Qwerty123';
        },
        child: const Text('Autocompletar Residente 1'),
      ),
      ElevatedButton(
        onPressed: () {
          _email.text = 'resident2@sgav.dev';
          _pass.text  = 'Qwerty123';
        },
        child: const Text('Autocompletar Residente 2'),
      ),
      ElevatedButton(
        onPressed: () {
          _email.text = 'guard@sgav.dev';
          _pass.text  = 'Qwerty123';
        },
        child: const Text('Autocompletar Guardia 1'),
      ),
      ElevatedButton(
        onPressed: () {
          _email.text = 'guard2@sgav.dev';
          _pass.text  = 'Qwerty123';
        },
        child: const Text('Autocompletar Guardia 2'),
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 350),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('SGAV-CRC', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Correo'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _pass,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  _quickLoginButtons(),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 24),
                  _loading
                      ? const CircularProgressIndicator()
                      : Column(
                          children: [
                            ElevatedButton(
                              onPressed: _signIn,
                              child: const Text('Ingresar'),
                            ),
                            TextButton(
                              onPressed: _register,
                              child: const Text('Crear cuenta'),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
