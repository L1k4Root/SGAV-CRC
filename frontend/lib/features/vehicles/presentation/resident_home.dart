import 'package:flutter/material.dart';
import 'package:sgav_frontend/features/vehicles/presentation/vehicles_table.dart';
import 'guard_panel.dart';          // solo para reutilizar la tabla
import 'add_vehicle_page.dart';

class ResidentHome extends StatelessWidget {
  const ResidentHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis vehículos')),
      body: const VehiclesTablePage(),          // tabla que ya hiciste
      floatingActionButton: FloatingActionButton(
        tooltip: 'Añadir vehículo',
        child: const Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/add'),
      ),
    );
  }
}
