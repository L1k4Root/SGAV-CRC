import 'package:flutter/material.dart';
import 'package:sgav_frontend/shared/widgets/logout_button.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel administrador'),
        actions: const [LogoutButton()],
        
        ),

      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.people),
              label: const Text('Usuarios'),
              onPressed: () => Navigator.pushNamed(context, '/users'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.directions_car),
              label: const Text('Vehículos'),
              onPressed: () {
                Navigator.pushNamed(context, '/vehicles-admin');
              },
            ),
          ],
        ),
      ),
    );
  }
}
