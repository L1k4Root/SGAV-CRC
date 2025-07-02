import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../shared/utils/loggin_service.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _signIn() async {
    final email = _email.text.trim();
    final pass  = _pass.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _showError('Completa ambos campos.');
      return;
    }

    setState(() => _loading = true);
    final res = await AuthService.signIn(email, pass);

    if (!mounted) return;
    setState(() => _loading = false);

    if (res.blocked) {
      _showError('Usuario bloqueado. Contacta al administrador.');
      return;
    }
    if (res.error != null) {
      _showError(res.error!);
      return;
    }

    switch (res.role) {
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
                              onPressed: () => Navigator.pushNamed(context, '/register'),
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

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }
}

// === Domain-layer auth wrapper (to mover a auth_service.dart cuando separemos capas) ===
enum AuthStatus { success, blocked, error }

class AuthResponse {
  AuthResponse({this.role, this.error, this.blocked = false});
  final String? role;
  final String? error;
  final bool blocked;

  bool get isSuccess => error == null && !blocked;
}

class AuthService {
  static Future<AuthResponse> signIn(String email, String pass) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      final uid = FirebaseAuth.instance.currentUser!.uid;
      await LoggingService.info(
        module: 'auth',
        event: 'login_success',
        uid: uid,
        payload: {'email': email},
      );

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data() ?? {};
      final role = data['role'] as String? ?? 'resident';
      final blocked = data['block'] as bool? ?? false;

      if (blocked) {
        await LoggingService.warning(
          module: 'auth',
          event: 'login_blocked',
          uid: uid,
          payload: {'email': email},
        );
        return AuthResponse(blocked: true);
      }

      return AuthResponse(role: role);
    } on FirebaseAuthException catch (e) {
      await LoggingService.warning(
        module: 'auth',
        event: 'login_failed',
        payload: {'code': e.code, 'email': email},
      );
      return AuthResponse(error: e.message ?? 'Error desconocido');
    }
  }
}
