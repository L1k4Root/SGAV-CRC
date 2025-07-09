import 'package:cloud_firestore/cloud_firestore.dart';
import '../presentation/vehicles.dto.dart';

/// Repository wrapper around the `vehicles` collection in Firestore.
class VehiclesRepository {
  final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _ref;

  VehiclesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _ref = _firestore.collection('vehicles');
  }

  /// Add a vehicle, returns the document ID.
  Future<String> addVehicle(VehicleDto dto) async {
    final docRef = await _ref.add(dto.toJson());
    return docRef.id;
  }

  /// Delete a vehicle by document ID.
  Future<void> delete(String docId) {
    return _ref.doc(docId).delete();
  }

  /// Watch vehicles, optionally by ownerId.
  Stream<List<VehicleDto>> watchAll({String? ownerId}) {
    Query<Map<String, dynamic>> query =
        _ref.orderBy('createdAt', descending: true);
    if (ownerId != null) {
      query = query.where('ownerId', isEqualTo: ownerId);
    }
    return query.snapshots().map(
        (snap) => snap.docs.map((d) => VehicleDto.fromJson(d.data())).toList());
  }

  /// Toggle active status of a vehicle.
  Future<void> toggleActive(String docId, bool active) {
    return _ref.doc(docId).update({'active': !active, 'pendingOut': false});
  }
}