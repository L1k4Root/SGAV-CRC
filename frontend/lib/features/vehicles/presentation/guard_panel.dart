import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for kDebugMode & debugPrint
import 'package:sgav_frontend/shared/widgets/logout_button.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../features/users/presentation/incidents_page.dart';

import '../../../shared/models/access_log.dart';
import '../../../shared/services/api_client.dart';
import '../../../shared/services/access_log_repository.dart';
import '../../../shared/services/incident_repository.dart';
import 'qr_scanner_page.dart';

// -----------------------------------------------------------------------------
// Modelos visuales de apoyo
// -----------------------------------------------------------------------------

/// Semáforo de acceso.
enum TrafficLightState { idle, green, red, yellow }

class TrafficLight extends StatelessWidget {
  final TrafficLightState state;
  const TrafficLight({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      TrafficLightState.green  => Colors.green,
      TrafficLightState.red    => Colors.red,
      TrafficLightState.yellow => Colors.amber,
      _                        => Colors.grey,
    };
    final text = switch (state) {
      TrafficLightState.green  => 'AUTORIZADO',
      TrafficLightState.red    => 'NO REGISTRADO',
      TrafficLightState.yellow => 'EXPIRADO',
      _                        => '—',
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 4),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

/// Tarjeta con los datos del vehículo autorizado.
class VehicleInfoCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const VehicleInfoCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Modelo: ${data['model'] ?? '-'}'),
            Text('Color : ${data['color'] ?? '-'}'),
            Text('Residente: ${data['ownerEmail'] ?? '-'}'),
            Text('Estado: ${data['active'] == true ? 'Activo' : 'Inactivo'}'),
          ],
        ),
      ),
    );
  }
}



class GuardPanel extends StatefulWidget {
  const GuardPanel({super.key});

  @override
  State<GuardPanel> createState() => _GuardPanelState();
}

class _GuardPanelState extends State<GuardPanel> {
  final _plate = TextEditingController();
  final _api = ApiClient();
  final _accessLogRepo = AccessLogRepository();
  final _incidentRepo = IncidentRepository();
  final TextEditingController _obsController = TextEditingController();
  TrafficLightState _lightState = TrafficLightState.idle;
  Map<String, dynamic>? _vehicleInfo;
  bool _loading = false;
  Future<void> _showIncidentDialog() async {
    _obsController.clear();
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reportar incidente'),
        content: TextField(
          controller: _obsController,
          decoration: const InputDecoration(hintText: 'Descripción'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final plate = _plate.text.trim().toUpperCase();
              final now = DateTime.now();
              // Determine ownerId: use provided or lookup from vehicles collection
              String ownerEmail = _vehicleInfo?['ownerEmail'] ?? '';
              String ownerId = _vehicleInfo?['ownerId'] ?? '';
              if (ownerId.isEmpty && ownerEmail.isNotEmpty) {
                final vehicleQuery = await FirebaseFirestore.instance
                    .collection('vehicles')
                    .where('ownerEmail', isEqualTo: ownerEmail)
                    .limit(1)
                    .get();
                if (vehicleQuery.docs.isNotEmpty) {
                  final data = vehicleQuery.docs.first.data();
                  ownerId = data['ownerId'] as String? ?? '';
                }
              }
              await _incidentRepo.registerIncident(
                plate: plate,
                timestamp: now,
                guardId: FirebaseAuth.instance.currentUser!.uid,
                description: _obsController.text.trim(),
                ownerEmail: ownerEmail,
                ownerId: ownerId,
              );
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Incidente reportado')),
              );
            },
            child: const Text('Reportar'),
          ),
        ],
      ),
    );
  }

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

    // Verificar invitaciones válidas
    final now = DateTime.now();
    final inviteSnapAll = await FirebaseFirestore.instance
        .collection('invites')
        .where('plate', isEqualTo: plate)
        .where('active', isEqualTo: true)
        .get();
    if (inviteSnapAll.docs.isNotEmpty) {
      final invite = inviteSnapAll.docs.first.data();
      final expiresOn = (invite['expiresOn'] as Timestamp?)?.toDate();
      bool isExpired = expiresOn != null && expiresOn.isBefore(now);
      setState(() {
        _vehicleInfo = {
          'model': invite['model'] ?? '',
          'color': invite['color'] ?? '',
          'ownerEmail': invite['ownerEmail'] ?? '',
          'active': !isExpired,
        };
        _lightState = isExpired
            ? TrafficLightState.yellow  // Expirado
            : TrafficLightState.green;  // Autorizado por invitación
        _loading = false;
      });
      return;
    }

    final data = await _api.getVehicle(plate);
    if (kDebugMode) {
      debugPrint('DEBUG ▸ Fetched data for $plate → $data');
    }
    setState(() {
      _vehicleInfo = data;
      if (data == null) {
        _lightState = TrafficLightState.red;          // No registrado
      } else if (data['active'] != true) {
        _lightState = TrafficLightState.yellow;       // Desactivado
      } else {
        _lightState = TrafficLightState.green;        // Autorizado
      }
      _loading = false;
    });
      if (kDebugMode) {
      debugPrint('DEBUG ▸ Decision for $plate → $_lightState');
    }
    if (data != null && data['active'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acceso desactivado')),
      );
    }
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
                        onPressed: _showIncidentDialog,
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
    ));
  }
  @override
  void dispose() {
    _plate.dispose();
    _obsController.dispose();
    super.dispose();
  }
}