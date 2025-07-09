import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../presentation/vehicles.dto.dart';

class InviteRepository {
  final CollectionReference _col =
      FirebaseFirestore.instance.collection('invites');

  Future<List<VehicleDto>> getActiveInvites(String plate) async {
    final now = DateTime.now();
    final snapshot = await _col
        .where('plate', isEqualTo: plate)
        .where('active', isEqualTo: true)
        .where('expiresOn', isGreaterThan: Timestamp.fromDate(now))
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return VehicleDto.fromMap(data);
    }).toList();
  }

  Future<void> addInvite(VehicleDto dto) async {
    if (kDebugMode) {
      debugPrint('🟢 ADDING INVITE ▸ ${dto.toMap()}');
    }
    await _col.add(dto.toMap());
  }

  Future<void> deactivateInvite(String id) async {
    await _col.doc(id).update({'active': false});
  }
}
