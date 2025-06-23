import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> _signOut(BuildContext ctx) async {
    await FirebaseAuth.instance.signOut();
    // Eliminamos cualquier pila de navegación previa
    // y enviamos al login
    if (ctx.mounted) {
      Navigator.pushNamedAndRemoveUntil(ctx, '/', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout, color: Colors.red),
      tooltip: 'Cerrar sesión',
      onPressed: () => _signOut(context),
    );
  }
}
