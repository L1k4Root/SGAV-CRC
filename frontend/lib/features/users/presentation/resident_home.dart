import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../vehicles/presentation/vehicles_table.dart';
import 'package:sgav_frontend/shared/widgets/logout_button.dart';
import 'resident_invites_page.dart';

/// Home del residente: lista sus vehículos e invita nuevos.
class ResidentHome extends StatelessWidget {
  const ResidentHome({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis vehículos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.report),
            tooltip: 'Reportar incidente',
            onPressed: () {
              Navigator.pushNamed(context, '/incidents');
            },
          ),
          IconButton(
            icon: const Icon(Icons.mail),
            tooltip: 'Ver invitaciones',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ResidentInvitesPage()),
              );
            },
          ),
          const LogoutButton(),
        ],
      ),
      body: VehiclesTablePage(ownerId: uid),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Añadir vehículo',
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/add');
        },
      ),
    );
  }
}
