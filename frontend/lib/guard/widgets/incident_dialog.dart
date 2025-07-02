import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sgav_frontend/shared/services/incident_repository.dart';

Future<void> showIncidentDialog({
  required BuildContext context,
  required String plate,
  required String? ownerEmail,
  required String? ownerId,
}) async {
  final _obsController = TextEditingController();
  await showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Reportar incidente'),
      content: TextField(
        controller: _obsController,
        decoration: const InputDecoration(hintText: 'Descripción'),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            final repo = IncidentRepository();
            await repo.registerIncident(
              plate: plate,
              timestamp: DateTime.now(),
              guardId: FirebaseAuth.instance.currentUser!.uid,
              description: _obsController.text.trim(),
              ownerEmail: ownerEmail ?? '',
              ownerId: ownerId ?? '',
            );
            Navigator.pop(dialogContext);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Incidente reportado')),
            );
          },
          child: const Text('Reportar'),
        ),
      ],
    ),
  );
  _obsController.dispose();
}
