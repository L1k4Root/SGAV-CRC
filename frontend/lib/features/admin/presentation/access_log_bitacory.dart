import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Página de bitácora global de accesos.
/// Se diferencia del historial por vehículo: aquí mostramos TODOS los accesos
/// (o intentos) y luego se podrá filtrar por rango de fechas, guardia, placa, etc.
class AccessLogBitacoryPage extends StatefulWidget {
  const AccessLogBitacoryPage({super.key});
  @override
  _AccessLogBitacoryPageState createState() => _AccessLogBitacoryPageState();
}

class _AccessLogBitacoryPageState extends State<AccessLogBitacoryPage> {
  final TextEditingController _plateController = TextEditingController();
  String _statusFilter = 'all'; // 'all', 'permitted', 'denied'

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bitácora de Accesos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _plateController,
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por patente',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _statusFilter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Todos')),
                    DropdownMenuItem(value: 'permitted', child: Text('Permitidos')),
                    DropdownMenuItem(value: 'denied', child: Text('Denegados')),
                  ],
                  onChanged: (v) => setState(() {
                    _statusFilter = v!;
                  }),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('access_logs')
                  .orderBy('timestamp', descending: true)
                  .get(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snap.hasData || snap.data!.docs.isEmpty) {
                  return const Center(child: Text('Sin registros de accesos'));
                }
                final docs = snap.data!.docs;
                // Filter docs by plate and status
                final filteredDocs = docs.where((doc) {
                  final data = doc.data()! as Map<String, dynamic>;
                  final plate = (data['plate'] as String?)?.toLowerCase() ?? '';
                  if (_plateController.text.isNotEmpty &&
                      !plate.contains(_plateController.text.trim().toLowerCase())) {
                    return false;
                  }
                  final permitted = data['permitted'] == true;
                  if (_statusFilter == 'permitted' && !permitted) return false;
                  if (_statusFilter == 'denied' && permitted) return false;
                  return true;
                }).toList();
                // Extract unique guard IDs
                final guardIds = filteredDocs.map((d) => d['guardId'] as String).toSet();
                return FutureBuilder<List<DocumentSnapshot>>(
                  future: Future.wait(
                    guardIds.map((id) =>
                        FirebaseFirestore.instance.collection('users').doc(id).get()),
                  ),
                  builder: (ctx, userSnap) {
                    if (userSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    // Map guard ID to email (only for users with role 'guard')
                    final guardEmails = <String, String>{};
                    for (var userDoc in userSnap.data ?? []) {
                      final data = userDoc.data() as Map<String, dynamic>? ?? {};
                      if (data['role'] == 'guard') {
                        guardEmails[userDoc.id] = data['email'] as String? ?? userDoc.id;
                      }
                    }
                    // Group logs by guardId
                    final grouped = <String, List<QueryDocumentSnapshot>>{};
                    for (var doc in filteredDocs) {
                      final gid = doc['guardId'] as String;
                      grouped.putIfAbsent(gid, () => []).add(doc);
                    }
                    // Build list of ExpansionTiles
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: grouped.entries
                          .where((entry) => guardEmails.containsKey(entry.key))
                          .map((entry) {
                        final gid = entry.key;
                        final email = guardEmails[gid] ?? gid;
                        final logs = entry.value;
                        return ExpansionTile(
                          title: Text(email),
                          children: logs.map((doc) {
                            final data = doc.data()! as Map<String, dynamic>;
                            final ts = (data['timestamp'] as Timestamp?)?.toDate();
                            final dateStr = ts != null
                                ? DateFormat('yyyy-MM-dd HH:mm').format(ts)
                                : '-';
                            return Card(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: ListTile(
                                title: Text(data['plate'] ?? '-'),
                                subtitle: Text(dateStr),
                                trailing: Icon(
                                  data['permitted'] == true ? Icons.check_circle : Icons.cancel,
                                  color: data['permitted'] == true ? Colors.green : Colors.red,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}