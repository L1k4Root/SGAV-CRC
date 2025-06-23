import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/vehicles/presentation/guard_panel.dart';
import 'features/vehicles/presentation/add_vehicle_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SGAVApp());
}

class SGAVApp extends StatelessWidget {
  const SGAVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SGAV-CRC',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginPage(),
        '/guard': (_) => const GuardPanel(),
        '/add': (_) => const AddVehiclePage(),
      },
    );
  }
}
