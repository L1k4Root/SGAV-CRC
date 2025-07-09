import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class IncidentsPage extends StatefulWidget {
  const IncidentsPage({super.key});

  @override
  State<IncidentsPage> createState() => _IncidentsPageState();
}

class _IncidentsPageState extends State<IncidentsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final bool isAdmin = args?['isAdmin'] ?? false;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Debes iniciar sesión.')),
      );
    }

    final uid = user.uid;
    final email = user.email;

    // Always load all incidents ordered by timestamp, then filter locally for residents
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('incidents')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis incidentes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.report_problem),
            tooltip: 'Reportar incidente',
            onPressed: () {
              final plateController = TextEditingController();
              final descriptionController = TextEditingController();
              String? errorText;
              showDialog(
                context: context,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: const Text('Reportar incidente'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: plateController,
                              decoration: InputDecoration(
                                labelText: 'Patente',
                                errorText: errorText,
                              ),
                              textCapitalization: TextCapitalization.characters,
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Descripción',
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () async {
                              final plate = plateController.text.trim().toUpperCase();
                              final snapshot = await FirebaseFirestore.instance
                                  .collection('vehicles')
                                  .where('plate', isEqualTo: plate)
                                  .get();
                              if (snapshot.docs.isEmpty) {
                                setState(() {
                                  errorText = 'Patente no existe';
                                });
                                return;
                              }
                              await FirebaseFirestore.instance
                                  .collection('incidents')
                                  .add({
                                'plate': plate,
                                'description': descriptionController.text.trim(),
                                'timestamp': FieldValue.serverTimestamp(),
                                'ownerId': uid,
                                'ownerEmail': email,
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Incidente registrado')),
                              );
                            },
                            child: const Text('Enviar'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
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
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error cargando incidentes.\n'
                        'Es posible que necesites crear un índice compuesto en Firestore:\n'
                        'Collection: incidents\n'
                        'Fields: ownerId (ASCENDING), timestamp (DESCENDING)',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                var docs = snapshot.data?.docs ?? [];
                // Filtrar por patente si hay texto de búsqueda
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    final plate = (doc.data()['plate'] as String?)?.toUpperCase() ?? '';
                    return plate.contains(_searchQuery);
                  }).toList();
                }
                // Filter locally for resident users
                if (!isAdmin) {
                  docs = docs.where((doc) {
                    final data = doc.data();
                    final ownerId = data['ownerId'];
                    return ownerId != null && ownerId is String && ownerId == uid;
                  }).toList();
                }
                // Aseguramos orden local si Firestore devuelve sin orderBy
                docs.sort((a, b) {
                  final t1 = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
                  final t2 = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
                  return t2.compareTo(t1);
                });
                return _buildList(docs, isAdmin);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, bool isAdmin) {
    if (docs.isEmpty) {
      return const Center(child: Text('No tienes incidentes registrados.'));
    }
    return ListView.separated(
      itemCount: docs.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final data = docs[index].data();
        final ts = (data['timestamp'] as Timestamp?)?.toDate();
        return ListTile(
          leading: const Icon(Icons.report_problem, color: Colors.orange),
          title: Text(data['plate'] ?? '—'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data['description'] ?? 'Sin descripción'),
              if (isAdmin) ...[
                Builder(
                  builder: (context) {
                    final ownerId = data['ownerId'] as String? ?? '';
                    final ownerEmail = data['ownerEmail'] as String? ?? '';
                    if (ownerId.isNotEmpty) {
                      return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        future: FirebaseFirestore.instance.collection('users').doc(ownerId).get(),
                        builder: (context, userSnap) {
                          final email = userSnap.data?.data()?['email'] ?? ownerEmail;
                          return Text(
                            'Usuario: $email',
                            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                          );
                        },
                      );
                    } else if (ownerEmail.isNotEmpty) {
                      return Text(
                        'Usuario: $ownerEmail',
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (ts != null)
                Text(
                  DateFormat('dd/MM HH:mm').format(ts),
                  style: const TextStyle(fontSize: 12),
                ),
              IconButton(
                tooltip: 'Marcar resuelto',
                icon: const Icon(Icons.confirmation_number_outlined),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Marcar como resuelto'),
                      content: const Text('¿Eliminar este incidente?'),
                      actions: [
                        TextButton(
                          child: const Text('Cancelar'),
                          onPressed: () => Navigator.pop(ctx, false),
                        ),
                        TextButton(
                          child: const Text('Eliminar'),
                          onPressed: () => Navigator.pop(ctx, true),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await _deleteIncident(context, docs[index].id);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteIncident(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('incidents').doc(docId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incidente marcado como resuelto')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}