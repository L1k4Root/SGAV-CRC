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
}