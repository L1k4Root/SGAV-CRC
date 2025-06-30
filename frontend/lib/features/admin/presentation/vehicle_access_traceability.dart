import 'package:flutter/material.dart';
import '../../../shared/services/api_client.dart';
import '../../../shared/services/access_log_repository.dart';
import '../../../shared/models/access_log.dart';

class VehicleAccessTraceabilityPage extends StatefulWidget {
  const VehicleAccessTraceabilityPage({Key? key}) : super(key: key);

  @override
  State<VehicleAccessTraceabilityPage> createState() => _VehicleAccessTraceabilityPageState();
}

class _VehicleAccessTraceabilityPageState extends State<VehicleAccessTraceabilityPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trazabilidad de Accesos por Vehículo'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar por patente',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() {
                _searchQuery = val.trim().toUpperCase();
              }),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AccessLog>>(
              stream: AccessLogRepository().streamRecentAccesses(limit: 100),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final logs = snapshot.data ?? [];
                // Filtrar por patente si hay texto de búsqueda
                final filteredLogs = _searchQuery.isEmpty
                    ? logs
                    : logs.where((log) => log.plate.contains(_searchQuery)).toList();
                if (filteredLogs.isEmpty) {
                  return const Center(child: Text('No hay registros de trazabilidad.'));
                }
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: const [
                        Expanded(child: Text('Patente', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text('Modelo', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text('Color', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text('Residente', style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text('Guardia', style: TextStyle(fontWeight: FontWeight.bold))),
                        SizedBox(
                          width: 60,
                          child: Center(
                            child: Text(
                              'Estado',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    ...filteredLogs.map((log) {
                      return FutureBuilder<Map<String, dynamic>?>(
                        future: ApiClient().getVehicle(log.plate),
                        builder: (ctx, vehSnap) {
                          final veh = vehSnap.data;
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: log.permitted
                                  ? Colors.green.withOpacity(0.08)
                                  : Colors.red.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Expanded(child: Text(log.plate)),
                                Expanded(child: Text(veh?['model'] ?? '-')),
                                Expanded(child: Text(veh?['color'] ?? '-')),
                                Expanded(child: Text(veh?['ownerEmail'] ?? '-')),
                                Expanded(child: Text(log.guardId)), // TODO: reemplazar con nombre del guardia
                                SizedBox(
                                  width: 60,
                                  child: Center(
                                    child: Icon(
                                      log.permitted ? Icons.check_circle : Icons.cancel,
                                      color: log.permitted ? Colors.green : Colors.red,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}