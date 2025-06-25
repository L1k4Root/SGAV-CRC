import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para un registro de acceso.
class AccessLog {
  /// ID del documento en Firestore.
  final String id;

  /// Patente del vehículo.
  final String plate;

  /// Marca de tiempo del registro.
  final DateTime timestamp;

  /// Indica si el acceso fue permitido (true) o denegado (false).
  final bool permitted;

  /// ID del guardia que registró el evento.
  final String guardId;

  /// Descripción opcional (ej. motivo del incidente).
  final String? description;

  AccessLog({
    required this.id,
    required this.plate,
    required this.timestamp,
    required this.permitted,
    required this.guardId,
    this.description,
  });

  /// Crea una instancia de AccessLog a partir de un documento de Firestore.
  factory AccessLog.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AccessLog(
      id: doc.id,
      plate: data['plate'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      permitted: data['permitted'] as bool? ?? false,
      guardId: data['guardId'] as String? ?? '',
      description: data['description'] as String?,
    );
  }

  /// Convierte la instancia a un mapa compatible con Firestore.
  Map<String, dynamic> toMap() {
    return {
      'plate': plate,
      'timestamp': Timestamp.fromDate(timestamp),
      'permitted': permitted,
      'guardId': guardId,
      if (description != null) 'description': description,
    };
  }
}