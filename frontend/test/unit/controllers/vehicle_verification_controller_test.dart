import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sgav_frontend/guard/controllers/vehicle_verification_controller.dart';
import 'package:sgav_frontend/guard/widgets/traffic_light.dart';
import 'package:sgav_frontend/shared/services/api_client.dart';

/// Simple Fake for ApiClient so we can control getVehicle() output.
class FakeApiClient implements ApiClient {
  /// Provide the value you want getVehicle to return.
  Map<String, dynamic>? nextResponse;

  @override
  Future<Map<String, dynamic>?> getVehicle(String plate) async => nextResponse;
}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('VehicleVerificationController', () {
    late MockFirebaseFirestore mockFs;
    late FakeApiClient fakeApi;
    late VehicleVerificationController controller;
    late MockCollectionReference mockCollection;
    late MockQuery mockQuery;
    late MockQuerySnapshot mockSnapshot;
    late MockQueryDocumentSnapshot mockDocSnap;

    setUp(() {
      mockFs = MockFirebaseFirestore();
      fakeApi = FakeApiClient();
      controller = VehicleVerificationController(
        firestore: mockFs,
        apiClient: fakeApi,
      );
      mockCollection = MockCollectionReference();
      mockQuery = MockQuery();
      mockSnapshot = MockQuerySnapshot();
      mockDocSnap = MockQueryDocumentSnapshot();

      // Removed the generic where stubs as per instructions
    });

    test('returns GREEN when there is an active, unexpired invite', () async {
      when(() => mockFs.collection('invites')).thenReturn(mockCollection);
      when(() => mockCollection.where('plate', isEqualTo: 'XYZ123')).thenReturn(mockQuery);
      when(() => mockQuery.where('active', isEqualTo: true)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async {
        when(() => mockSnapshot.docs).thenReturn([mockDocSnap]);
        when(() => mockDocSnap.data()).thenReturn({
          'plate': 'XYZ123',
          'active': true,
          'expiresOn': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
          'model': 'Model A',
          'color': 'Rojo',
          'ownerEmail': 'user@site.com',
          'ownerId': 'uid123',
        });
        return mockSnapshot;
      });

      final result = await controller.verifyPlate('XYZ123');

      expect(result.state, TrafficLightState.green);
      expect(result.data?['ownerEmail'], 'user@site.com');
    });

    test('returns RED when no invite and no vehicle found', () async {
      when(() => mockFs.collection('invites')).thenReturn(mockCollection);
      when(() => mockCollection.where('plate', isEqualTo: 'ABC000')).thenReturn(mockQuery);
      when(() => mockQuery.where('active', isEqualTo: true)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async {
        when(() => mockSnapshot.docs).thenReturn(<MockQueryDocumentSnapshot>[]);
        return mockSnapshot;
      });

      fakeApi.nextResponse = null; // Api returns no vehicle

      final result = await controller.verifyPlate('ABC000');

      expect(result.state, TrafficLightState.red);
      expect(result.data, isNull);
    });
  });
}