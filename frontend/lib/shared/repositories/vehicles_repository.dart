

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicles.dto.dart';

/// Repository wrapper around the `vehicles` collection in Firestore.
///
/// ## Why a repository?
/// * Centraliza todas las llamadas a Firestore (o la fuente de datos que sea) en
///   un solo lugar.
/// * Facilita test unitarios mockeando `FirebaseFirestore`.
/// * Evita duplicación de queries a lo largo de la app.
class VehiclesRepository {
  /// Firestore instance (injected para facilitar pruebas).
  final FirebaseFirestore _firestore;

  /// Colección principal.
  late final CollectionReference<Map<String, dynamic>> _ref;

  VehiclesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _ref = _firestore.collection('vehicles');
  }

  // ---------------------------------------------------------------------------
  // CRUD
  // ---------------------------------------------------------------------------

  /// Agrega un vehículo a la colección.
  ///
  /// Retorna el `documentId` generado por Firestore para posibles referencias.
  Future<String> addVehicle(VehicleDto dto) async {
    final docRef = await _ref.add(dto.toJson());
    return docRef.id;
  }

  /// Obtiene el primer vehículo que coincida con la patente (case‑insensitive).
  ///
  /// Devuelve `null` si no existe.
  Future<VehicleDto?> getByPlate(String plate) async {
    final qSnap = await _ref
        .where('plate', isEqualTo: plate.trim().toUpperCase())
        .limit(1)
        .get();

    if (qSnap.docs.isEmpty) return null;
    return VehicleDto.fromJson(qSnap.docs.first.data());
  }

  /// Actualiza (merge) los campos de un vehículo por `documentId`.
  Future<void> updateVehicle(String docId, VehicleDto dto) {
    return _ref.doc(docId).set(dto.toJson(), SetOptions(merge: true));
  }

  // ---------------------------------------------------------------------------
  // Helpers / Utilidades
  // ---------------------------------------------------------------------------

  /// Stream de todos los vehículos (o filtrado por `ownerId`).
  Stream<List<VehicleDto>> watchAll({String? ownerId}) {
    Query<Map<String, dynamic>> query = _ref.orderBy('createdAt', descending: true);
    if (ownerId != null) {
      query = query.where('ownerId', isEqualTo: ownerId);
    }
    return query.snapshots().map(
          (s) => s.docs.map((d) => VehicleDto.fromJson(d.data())).toList(),
        );
  }

  /// Marca un vehículo como inactivo.
  Future<void> deactivate(String docId) {
    return _ref.doc(docId).update({'active': false});
  }

  /// Borra un documento (poco habitual, pero útil para administración).
  Future<void> delete(String docId) {
    return _ref.doc(docId).delete();
  }
}