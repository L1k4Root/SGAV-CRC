import 'package:flutter/material.dart';
import 'package:sgav_frontend/features/vehicles/presentation/vehicles_table.dart';
import 'package:sgav_frontend/shared/widgets/logout_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
// solo para reutilizar la tabla

class ResidentHome extends StatelessWidget {
  const ResidentHome({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis vehículos'),
        actions: const [LogoutButton()],
      ),
      body: VehiclesTablePage(ownerId: uid),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Añadir vehículo',
        child: const Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/add'),
      ),
    );
  }
}
