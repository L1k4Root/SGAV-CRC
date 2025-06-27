import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sgav_frontend/shared/utils/loggin_service.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  Future<void> _signOut(BuildContext ctx) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    // Registramos el evento antes de cerrar sesión
    await LoggingService.info(
      module: 'auth',
      event: 'logout',
      uid: uid,
    );
    await FirebaseAuth.instance.signOut();
    // Limpiamos navegación y enviamos al login
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
