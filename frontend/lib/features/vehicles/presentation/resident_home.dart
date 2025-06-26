import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../repositories/vehicles_repository.dart';
import '../../../shared/models/vehicles.dto.dart';
import 'invite_vehicle_form.dart';
import 'vehicles_table.dart';
import 'package:sgav_frontend/widgets/logout_button.dart';

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
              Navigator.pushNamed(context, '/report-incident');
            },
          ),
          const LogoutButton(),
        ],
      ),
      body: VehiclesTablePage(ownerId: uid),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Invitar vehículo',
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InviteVehicleForm(
                ownerId: uid,
                ownerEmail: FirebaseAuth.instance.currentUser!.email!,
              ),
            ),
          );
        },
      ),
    );
  }
}
