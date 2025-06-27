import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class IncidentsPage extends StatelessWidget {
  const IncidentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Debes iniciar sesión.')),
      );
    }

    final uid = user.uid;
    final email = user.email;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis incidentes')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('incidents')
            .where('ownerId', isEqualTo: uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
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
          // Aseguramos orden local si Firestore devuelve sin orderBy
          docs.sort((a, b) {
            final t1 = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            final t2 = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
            return t2.compareTo(t1);
          });
          return _buildList(docs);
        },
      ),
    );
  }

  Widget _buildList(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
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
          subtitle: Text(data['description'] ?? 'Sin descripción'),
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