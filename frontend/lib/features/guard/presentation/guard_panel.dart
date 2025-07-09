import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for kDebugMode & debugPrint
import 'package:sgav_frontend/shared/widgets/logout_button.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sgav_frontend/features/guard/controllers/vehicle_verification_controller.dart';
import 'package:sgav_frontend/features/guard/widgets/traffic_light.dart';
import 'package:sgav_frontend/features/guard/widgets/vehicle_info_card.dart';
import 'package:sgav_frontend/features/guard/widgets/incident_dialog.dart';
import '../../../shared/models/access_log.dart';
import '../../../shared/services/access_log_repository.dart';
import '../../../shared/services/incident_repository.dart';
import '../../../shared/services/api_client.dart';
import 'qr_scanner_page.dart';

class GuardPanel extends StatefulWidget {
  const GuardPanel({super.key});

  @override
  State<GuardPanel> createState() => _GuardPanelState();
}

class _GuardPanelState extends State<GuardPanel> {
  final _plate = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ApiClient _apiClient = ApiClient();
  final _accessLogRepo = AccessLogRepository();
  final _incidentRepo = IncidentRepository();
  TrafficLightState _lightState = TrafficLightState.idle;
  Map<String, dynamic>? _vehicleInfo;
  bool _loading = false;

  Future<void> _check() async {
    final plateInput = _plate.text.trim();
    if (plateInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa una patente primero')),
      );
      return;
    }
    setState(() {
      _loading = true;
      _lightState = TrafficLightState.idle;
    });
    final plate = plateInput.toUpperCase();
    final controller = VehicleVerificationController(
      firestore: _firestore,
      apiClient: _apiClient,
    );
    final result = await controller.verifyPlate(plate);

    setState(() {
      _vehicleInfo = result.data;
      _lightState = result.state;
      _loading = false;
    });
  }

  Future<void> _logAccess(bool permitted) async {
    final plate = _plate.text.trim().toUpperCase();
    final now = DateTime.now();
    await _accessLogRepo.registerAccess(
      plate: plate,
      timestamp: now,
      permitted: permitted,
      guardId: FirebaseAuth.instance.currentUser!.uid,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          permitted ? 'Acceso permitido a $plate' : 'Acceso denegado a $plate',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Guardia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Registrar vehículo',
            onPressed: () => Navigator.pushNamed(context, '/add'),
          ),
          const LogoutButton(),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextField(
                    controller: _plate,
                    decoration: const InputDecoration(labelText: 'Patente (ej. ABC123)'),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 24),
                  _loading
                      ? const CircularProgressIndicator()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: _check,
                              child: const Text('Verificar'),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.directions_car),
                              label: const Text('Escanear patente'),
                              onPressed: () async {
                                final scannedPlate = await Navigator.push<String?>(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PlateScannerPage()),
                                );
                                if (scannedPlate != null) {
                                  _plate.text = scannedPlate;
                                  _check();
                                }
                              },
                            ),
                          ],
                        ),
                  const SizedBox(height: 32),
                  _loading
                      ? const CircularProgressIndicator()
                      : TrafficLight(state: _lightState),
                  if (_lightState == TrafficLightState.green && _vehicleInfo != null) ...[
                    VehicleInfoCard(data: _vehicleInfo!),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text('Permitir acceso'),
                          onPressed: () => _logAccess(true),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.close),
                          label: const Text('Denegar acceso'),
                          onPressed: () => _logAccess(false),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.report_problem),
                          label: const Text('Reportar incidente'),
                          onPressed: () => showIncidentDialog(
                            context: context,
                            plate: _plate.text.trim().toUpperCase(),
                            ownerEmail: _vehicleInfo?['ownerEmail'],
                            ownerId: _vehicleInfo?['ownerId'],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Últimos accesos', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(
                      height: 200,
                      child: StreamBuilder<List<AccessLog>>(
                        stream: _accessLogRepo.streamRecentAccesses(limit: 10),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final logs = snapshot.data ?? [];
                          if (logs.isEmpty) {
                            return const Center(child: Text('No hay registros recientes.'));
                          }
                          return ListView.separated(
                            itemCount: logs.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final log = logs[index];
                              return ListTile(
                                leading: Icon(
                                  log.permitted ? Icons.check_circle : Icons.cancel,
                                  color: log.permitted ? Colors.green : Colors.red,
                                ),
                                title: Text(log.plate),
                                subtitle: Text(DateFormat('HH:mm dd/MM').format(log.timestamp)),
                                trailing: log.description != null ? const Icon(Icons.report_problem) : null,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _plate.dispose();
    super.dispose();
  }
}