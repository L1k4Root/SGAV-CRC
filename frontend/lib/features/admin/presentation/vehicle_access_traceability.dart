import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final TextEditingController _residentController = TextEditingController();
  String _residentQuery = '';

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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _residentController,
              decoration: const InputDecoration(
                labelText: 'Buscar por residente (email)',
                prefixIcon: Icon(Icons.person_search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() {
                _residentQuery = val.trim().toLowerCase();
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
                          // Apply resident filter (by ownerEmail) if provided
                          if (_residentQuery.isNotEmpty &&
                              !(veh?['ownerEmail']?.toString().toLowerCase().contains(_residentQuery) ?? false)) {
                            return const SizedBox.shrink();
                          }
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
                                Expanded(
                                  child: FutureBuilder<QuerySnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection('users')
                                        .where('email', isEqualTo: veh?['ownerEmail'])
                                        .limit(1)
                                        .get(),
                                    builder: (ctx3, resSnap) {
                                      if (resSnap.connectionState == ConnectionState.waiting) {
                                        return const Text('-');
                                      }
                                      if (!resSnap.hasData || resSnap.data!.docs.isEmpty) {
                                        return const Text('-');
                                      }
                                      final data = resSnap.data!.docs.first.data() as Map<String, dynamic>;
                                      if (data['role'] != 'resident') {
                                        return const Text('-');
                                      }
                                      return Text(data['email'] ?? '-');
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance.collection('users').doc(log.guardId).get(),
                                    builder: (ctx2, userSnap) {
                                      if (userSnap.connectionState == ConnectionState.waiting) {
                                        return const Text('-');
                                      }
                                      if (!userSnap.hasData || !userSnap.data!.exists) {
                                        return const Text('-');
                                      }
                                      final data = userSnap.data!.data() as Map<String, dynamic>;
                                      if (data['role'] != 'guard') {
                                        return const Text('-');
                                      }
                                      final email = data['email'] as String?;
                                      return Text(email ?? '-');
                                    },
                                  ),
                                ),
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

  @override
  void dispose() {
    _searchController.dispose();
    _residentController.dispose();
    super.dispose();
  }
}