import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/access_log.dart';

/// Repositorio para gestionar registros de acceso en Firestore.
class AccessLogRepository {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('access_logs');

  /// Registra un acceso (permitido o denegado) en Firestore.
  Future<void> registerAccess({
    required String plate,
    required DateTime timestamp,
    required bool permitted,
    required String guardId,
    String? description,
  }) {
    final data = {
      'plate': plate,
      'timestamp': Timestamp.fromDate(timestamp),
      'permitted': permitted,
      'guardId': guardId,
      if (description != null && description.isNotEmpty) 'description': description,
    };
    return _col.add(data);
  }

  /// Devuelve un stream con los últimos [limit] registros de acceso, ordenados de más reciente a más antiguo.
  Stream<List<AccessLog>> streamRecentAccesses({int limit = 10}) {
    return _col
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => AccessLog.fromDocument(doc)).toList());
  }
}