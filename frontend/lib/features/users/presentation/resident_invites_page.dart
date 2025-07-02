import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'invite_vehicle_form.dart';

class ResidentInvitesPage extends StatefulWidget {
  const ResidentInvitesPage({Key? key}) : super(key: key);

  @override
  State<ResidentInvitesPage> createState() => _ResidentInvitesPageState();
}

class _ResidentInvitesPageState extends State<ResidentInvitesPage> {
  late Future<List<Map<String, dynamic>>> _invitesFuture;

  @override
  void initState() {
    super.initState();
    _invitesFuture = _fetchInvites();
  }

  Future<List<Map<String, dynamic>>> _fetchInvites() async {
    final user = FirebaseAuth.instance.currentUser!;
    final snapshot = await FirebaseFirestore.instance
        .collection('invites')
        .where('active', isEqualTo: true)
        .where('ownerEmail', isEqualTo: user.email)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> _deleteInvite(String id) async {
    await FirebaseFirestore.instance.collection('invites').doc(id).delete();
    setState(() {
      _invitesFuture = _fetchInvites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invitaciones Activas')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _invitesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final invites = snapshot.data ?? [];

          if (invites.isEmpty) {
            return const Center(child: Text('No hay invitaciones activas.'));
          }

          return ListView.builder(
            itemCount: invites.length,
            itemBuilder: (context, index) {
              final invite = invites[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(invite['plate'] ?? 'Sin patente'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Modelo: ${invite['model'] ?? 'N/A'}'),
                      Text('Color: ${invite['color'] ?? 'N/A'}'),
                      Text('Invitado por: ${invite['ownerEmail'] ?? 'N/A'}'),
                      Text('Expira: ${invite['expiresOn'] != null ? DateTime.fromMillisecondsSinceEpoch(invite['expiresOn'].seconds * 1000).toLocal().toString() : 'N/A'}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Eliminar invitación',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Eliminar invitación'),
                              content: const Text('¿Estás seguro de eliminar esta invitación?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await _deleteInvite(invite['id'] as String);
                          }
                        },
                      ),
                      const Icon(Icons.directions_car),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Invitar vehículo',
        child: const Icon(Icons.add),
        onPressed: () {
          final user = FirebaseAuth.instance.currentUser!;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InviteVehicleForm(
                ownerId: user.uid,
                ownerEmail: user.email!,
              ),
            ),
          );
        },
      ),
    );
  }
}