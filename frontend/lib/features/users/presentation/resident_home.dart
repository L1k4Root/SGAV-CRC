import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../vehicles/presentation/vehicles_table.dart';
import 'package:sgav_frontend/shared/widgets/logout_button.dart';

const _residentInvitesRoute = '/resident/invites';

/// Home del residente: lista sus vehículos e invita nuevos.
class ResidentHome extends StatelessWidget {
  const ResidentHome({super.key});

  void _onReportIncident(BuildContext context) {
    Navigator.pushNamed(context, '/incidents');
  }

  void _onViewInvites(BuildContext context) {
    Navigator.pushNamed(context, _residentInvitesRoute);
  }

  void _onAddVehicle(BuildContext context) {
    Navigator.pushNamed(context, '/add');
  }

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
            onPressed: () => _onReportIncident(context),
          ),
          IconButton(
            icon: const Icon(Icons.mail),
            tooltip: 'Ver invitaciones',
            onPressed: () => _onViewInvites(context),
          ),
          const LogoutButton(),
        ],
      ),
      body: VehiclesTablePage(ownerId: uid),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Añadir vehículo',
        child: const Icon(Icons.add),
        onPressed: () => _onAddVehicle(context),
      ),
    );
  }
}
