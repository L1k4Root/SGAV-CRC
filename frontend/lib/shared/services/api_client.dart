import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiClient {
  final _base = const String.fromEnvironment('API_URL',
      defaultValue: 'http://localhost:3000'); // Usar --dart-define en prod

  Future<Map<String, dynamic>?> getVehicle(String plate) async {
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    final res = await http.get(
      Uri.parse('$_base/vehicles?plate=$plate'),
      headers: {'Authorization': 'Bearer $idToken'},
    );
    if (res.statusCode != 200 || res.body == 'null') return null;
    return json.decode(res.body);
  }

  Future<void> addVehicle(Map<String, dynamic> data) async {
    final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
    await http.post(
      Uri.parse('$_base/vehicles'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );
  }
    Future<void> updateVehicle(String plate, Map<String, dynamic> data) async {
        final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
        await http.put(
        Uri.parse('$_base/vehicles?plate=$plate'),
        headers: {
            'Authorization': 'Bearer $idToken',
            'Content-Type': 'application/json',
        },
        body: json.encode(data),
        );
    }
    
    Future<void> deleteVehicle(String plate) async {
        final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
        await http.delete(
        Uri.parse('$_base/vehicles?plate=$plate'),
        headers: {'Authorization': 'Bearer $idToken'},
        );
    }
}