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
import 'features/auth/presentation/register_page.dart';
import 'features/admin/presentation/access_log_bitacory.dart';
import 'features/dashboard/presentation/admin_dashboard_page.dart';
import 'features/admin/presentation/system_logs.dart';
import 'features/users/presentation/incidents_page.dart';
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
    '/register': (_) => const RegisterPage(),
    '/access-log': (_) => const AccessLogBitacoryPage(),
    '/dashboards': (_) => const AdminDashboardPage(),
    '/system-logs': (_) => const SystemLogsPage(),
    '/incidents': (_) => const IncidentsPage(),
  },
);

}
}