import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';

class SystemLogsPage extends StatefulWidget {
  const SystemLogsPage({Key? key}) : super(key: key);

  @override
  _SystemLogsPageState createState() => _SystemLogsPageState();
}

class _SystemLogsPageState extends State<SystemLogsPage> {
  String searchQuery = '';
  String? selectedSeverity;
  final List<String> severityLevels = ['error', 'warning', 'info'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisar Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Buscar evento...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() {
                      searchQuery = v.trim().toLowerCase();
                    }),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String?>(
                  value: selectedSeverity,
                  hint: const Text('Severidad'),
                  items: [null, ...severityLevels].map((level) {
                    return DropdownMenuItem<String?>(
                      value: level,
                      child: Text(level == null ? 'Todos' : level.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() {
                    selectedSeverity = v;
                  }),
                ),
              ],
            ),
          ),
          // Data table
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('system_logs')
                  .orderBy('timestamp', descending: true)
                  .limit(1000)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                // In-memory filtering
                final filtered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final event = (data['event'] ?? '').toString().toLowerCase();
                  final severity = (data['severity'] ?? '').toString().toLowerCase();
                  if (searchQuery.isNotEmpty && !event.contains(searchQuery)) {
                    return false;
                  }
                  if (selectedSeverity != null && severity != selectedSeverity) {
                    return false;
                  }
                  return true;
                }).toList();

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                          maxWidth: constraints.maxWidth,
                        ),
                        child: DataTable2(
                          columnSpacing: 12,
                          minWidth: 800,
                          columns: const [
                            DataColumn2(label: Text('Timestamp'), size: ColumnSize.S),
                            DataColumn(label: Text('Evento')),
                            DataColumn(label: Text('Módulo')),
                            DataColumn(label: Text('Usuario')),
                            DataColumn(label: Text('Severidad')),
                          ],
                          rows: filtered.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final ts = (data['timestamp'] as Timestamp).toDate();
                            final formatted = DateFormat('yyyy-MM-dd HH:mm:ss').format(ts);
                            final sev = (data['severity'] ?? '').toString().toLowerCase();
                            Icon sevIcon;
                            Color sevColor;
                            switch (sev) {
                              case 'error':
                                sevIcon = const Icon(Icons.error, color: Colors.red);
                                sevColor = Colors.red;
                                break;
                              case 'warning':
                                sevIcon = const Icon(Icons.warning, color: Colors.orange);
                                sevColor = Colors.orange;
                                break;
                              default:
                                sevIcon = const Icon(Icons.info, color: Colors.blue);
                                sevColor = Colors.blue;
                            }
                            return DataRow(cells: [
                              DataCell(Text(formatted)),
                              DataCell(Text(data['event']?.toString() ?? '')),
                              DataCell(Text(data['module']?.toString() ?? '')),
                              DataCell(Text(
                                ((data['payload'] as Map<String, dynamic>?)?['email']?.toString() ?? '-'),
                              )),
                              DataCell(Row(
                                children: [
                                  sevIcon,
                                  const SizedBox(width: 4),
                                  Text(sev.toUpperCase(), style: TextStyle(color: sevColor)),
                                ],
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
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
