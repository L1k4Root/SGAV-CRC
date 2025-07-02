import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sgav_frontend/shared/services/api_client.dart';
import '../widgets/traffic_light.dart';

import '../widgets/traffic_light.dart';

/// Controller to verify a plate and return its traffic light state and data.
class VehicleVerificationController {
  static Future<VerificationResult> verifyPlate(String plate) async {
    final now = DateTime.now();
    final firestore = FirebaseFirestore.instance;

    // Check invites
    final inviteSnap = await firestore
        .collection('invites')
        .where('plate', isEqualTo: plate)
        .where('active', isEqualTo: true)
        .get();
    if (inviteSnap.docs.isNotEmpty) {
      final invite = inviteSnap.docs.first.data();
      final expiresOn = (invite['expiresOn'] as Timestamp?)?.toDate();
      final isExpired = expiresOn != null && expiresOn.isBefore(now);

      return VerificationResult(
        state: isExpired ? TrafficLightState.yellow : TrafficLightState.green,
        data: {
          'model': invite['model'] ?? '',
          'color': invite['color'] ?? '',
          'ownerEmail': invite['ownerEmail'] ?? '',
          'ownerId': invite['ownerId'] ?? '',
          'active': !isExpired,
        },
      );
    }

    // Check vehicles
    final data = await ApiClient().getVehicle(plate);
    final state = data == null
        ? TrafficLightState.red
        : (data['active'] == true ? TrafficLightState.green : TrafficLightState.yellow);

    return VerificationResult(state: state, data: data);
  }
}

/// Wrapper for verification result
class VerificationResult {
  VerificationResult({required this.state, this.data});
  final TrafficLightState state;
  final Map<String, dynamic>? data;
}
