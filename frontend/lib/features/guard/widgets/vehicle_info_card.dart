import 'package:flutter/material.dart';

class VehicleInfoCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const VehicleInfoCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Modelo: ${data['model'] ?? '-'}'),
            const SizedBox(height: 4),
            Text('Color: ${data['color'] ?? '-'}'),
            const SizedBox(height: 4),
            Text('Residente: ${data['ownerEmail'] ?? '-'}'),
            const SizedBox(height: 4),
            Text(
                'Estado: ${data['active'] == true ? 'Activo' : 'Inactivo'}'),
          ],
        ),
      ),
    );
  }
}
