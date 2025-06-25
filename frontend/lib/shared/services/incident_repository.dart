import 'package:cloud_firestore/cloud_firestore.dart';

/// Repositorio para gestionar incidentes reportados por guardias.
class IncidentRepository {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('incidents');

  /// Registra un incidente en Firestore.
  Future<void> registerIncident({
    required String plate,
    required DateTime timestamp,
    required String guardId,
    required String description,
  }) {
    final data = {
      'plate': plate,
      'timestamp': Timestamp.fromDate(timestamp),
      'guardId': guardId,
      'description': description,
    };
    return _col.add(data);
  }

  /// Devuelve un stream con los incidentes reportados.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamIncidents({int limit = 50}) {
    return _col.orderBy('timestamp', descending: true).limit(limit).snapshots();
  }
}