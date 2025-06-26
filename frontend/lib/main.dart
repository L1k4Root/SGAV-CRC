import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sgav_frontend/features/admin/presentation/admin_home.dart';
import 'package:sgav_frontend/features/admin/presentation/users_table.dart';
import 'package:sgav_frontend/features/admin/presentation/admin_home.dart';
import 'package:sgav_frontend/features/admin/presentation/users_table.dart';
import 'package:sgav_frontend/features/vehicles/presentation/resident_home.dart';
import 'package:sgav_frontend/features/vehicles/presentation/vehicles_table.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/vehicles/presentation/guard_panel.dart';
import 'features/vehicles/presentation/add_vehicle_page.dart';
import 'features/admin/presentation/add_user.dart';
import 'features/admin/presentation/vehicle_access_traceability.dart';
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
  debugShowCheckedModeBanner: false,
  initialRoute: '/',
  routes: {
    '/':        (_) => const LoginPage(),
    '/guard':   (_) => const GuardPanel(),
    '/resident':(_) => const ResidentHome(), 
    '/add':     (_) => const AddVehiclePage(),
    '/add-user': (_) => const AddUserPage(),
    '/vehicles-admin': (_) => const VehiclesTablePage(ownerId: ''), 
    '/vehicle-access-traceability': (_) => const VehicleAccessTraceabilityPage(),
    '/admin':     (_) => const AdminHome(),   
    '/users':     (_) => const UsersTablePage(),  

  },
);

}
}