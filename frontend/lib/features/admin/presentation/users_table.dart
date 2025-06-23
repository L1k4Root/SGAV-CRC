import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersTablePage extends StatelessWidget {
  const UsersTablePage({super.key});

  @override
  Widget build(BuildContext context) {
    final col = FirebaseFirestore.instance.collection('users');

    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      body: StreamBuilder<QuerySnapshot>(
        stream: col.snapshots(),
        builder: (ctx, snap) {
          if (snap.hasError)       return const Center(child: Text('Error'));
          if (!snap.hasData)        return const Center(child: CircularProgressIndicator());

          final docs = snap.data!.docs;
          return SingleChildScrollView(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Rol')),
                DataColumn(label: Text('Acción')),
              ],
              rows: docs.map((d) {
                final data = d.data()! as Map<String, dynamic>;
                final email = data['email'] as String? ?? '—';
                final role  = data['role']  as String? ?? 'resident';

                return DataRow(cells: [
                  DataCell(Text(email)),
                  DataCell(Text(role)),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      tooltip: 'Cambiar rol',
                      onPressed: () => _showRoleDialog(context, d.id, role),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  void _showRoleDialog(BuildContext ctx, String uid, String current) {
    final roles = ['resident', 'guard', 'admin'];
    String selected = current;

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Cambiar rol'),
        content: DropdownButton<String>(
          value: selected,
          items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
          onChanged: (v) => selected = v!,
        ),
        actions: [
          TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.pop(ctx)),
          ElevatedButton(
            child: const Text('Guardar'),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(uid).update({'role': selected});
              // opcional: mostrar snackbar
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text('Rol actualizado a "$selected"')),
              );
              // ignore: use_build_context_synchronously
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}
