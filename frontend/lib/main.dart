import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sgav_frontend/features/admin/presentation/admin_home.dart';
import 'package:sgav_frontend/features/admin/presentation/users_table.dart';
import 'package:sgav_frontend/features/users/presentation/resident_home.dart';
import 'package:sgav_frontend/features/users/presentation/resident_invites_page.dart';
import 'package:sgav_frontend/features/vehicles/presentation/vehicles_table.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/login_page.dart';
import 'guard/presentation/guard_panel.dart';
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
    // Authenticacion
    '/':                        (_) => const LoginPage(),
    '/register':                (_) => const RegisterPage(),

    // Admin Features
    '/admin':                   (_) => const AdminHome(),
    '/users':                   (_) => const UsersTablePage(),
    '/add-user':                (_) => const AddUserPage(),
    '/vehicles-admin':          (_) => const VehiclesTablePage(ownerId: 'admin'),
    '/dashboards':              (_) => const AdminDashboardPage(),
    '/vehicle-access-traceability': (_) => const VehicleAccessTraceabilityPage(),
    '/access-log':              (_) => const AccessLogBitacoryPage(),
    '/system-logs':             (_) => const SystemLogsPage(),

    // Vehicle Management
    '/add':                     (_) => const AddVehiclePage(),

    // Resident Features
    '/resident':                (_) => const ResidentHome(),
    '/resident/invites':        (_) => const ResidentInvitesPage(),
    '/incidents':               (_) => const IncidentsPage(),

    // Guard Panel
    '/guard':                   (_) => const GuardPanel(),
  },
);

}
}