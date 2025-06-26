


import 'package:flutter/material.dart';
import '../../../shared/services/api_client.dart';
import '../../../shared/services/access_log_repository.dart';
import '../../../shared/models/access_log.dart';

class VehicleAccessTraceabilityPage extends StatelessWidget {
  const VehicleAccessTraceabilityPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trazabilidad de Accesos por Vehículo'),
      ),
      body: StreamBuilder<List<AccessLog>>(
        stream: AccessLogRepository().streamRecentAccesses(limit: 100),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final logs = snapshot.data ?? [];
          if (logs.isEmpty) {
            return const Center(child: Text('No hay registros de trazabilidad.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: logs.map((log) {
              return FutureBuilder<Map<String, dynamic>?>(
                future: ApiClient().getVehicle(log.plate),
                builder: (ctx, vehSnap) {
                  final veh = vehSnap.data;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(child: Text(log.plate)),
                        Expanded(child: Text(veh?['model'] ?? '-')),
                        Expanded(child: Text(veh?['color'] ?? '-')),
                        Expanded(child: Text(veh?['ownerEmail'] ?? '-')),
                        Expanded(child: Text(log.guardId)), // TODO: reemplazar con nombre del guardia
                        Expanded(child: Text(log.permitted ? 'Ingresó' : 'Denegó')),
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}