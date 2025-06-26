import 'package:flutter/material.dart';
import 'package:sgav_frontend/widgets/logout_button.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/access_log.dart';
import 'package:sgav_frontend/shared/widgets/logout_button.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/access_log.dart';
import '../../../shared/services/api_client.dart';
import '../../../shared/services/access_log_repository.dart';
import '../../../shared/services/incident_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'qr_scanner_page.dart';
import 'package:flutter/foundation.dart'; // for kDebugMode & debugPrint

enum TrafficLightState { idle, green, red, yellow }

class TrafficLight extends StatelessWidget {
  final TrafficLightState state;
  const TrafficLight({required this.state, super.key});
  @override
  Widget build(BuildContext context) {
    final color = state == TrafficLightState.green
        ? Colors.green
        : state == TrafficLightState.red
            ? Colors.red
            : state == TrafficLightState.yellow
                ? Colors.amber
                : Colors.grey;
    final text = state == TrafficLightState.green
        ? 'AUTORIZADO'
        : state == TrafficLightState.red
            ? 'NO REGISTRADO'
            : state == TrafficLightState.yellow
                ? 'DESACTIVADO'
                : '—';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
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
            Text('Color: ${data['color'] ?? '-'}'),
            Text('Residente: ${data['ownerName'] ?? '-'}'),
            Text('Estado: ${data['active'] == true ? 'Activo' : 'Inactivo'}'),
          ],
        ),
      ),
    );
  }
}
import '../../../shared/services/access_log_repository.dart';
import '../../../shared/services/incident_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'qr_scanner_page.dart';

enum TrafficLightState { idle, green, red, yellow }

class TrafficLight extends StatelessWidget {
  final TrafficLightState state;
  const TrafficLight({required this.state, super.key});
  @override
  Widget build(BuildContext context) {
    final color = state == TrafficLightState.green
        ? Colors.green
        : state == TrafficLightState.red
            ? Colors.red
            : state == TrafficLightState.yellow
                ? Colors.amber
                : Colors.grey;
    final text = state == TrafficLightState.green
        ? 'AUTORIZADO'
        : state == TrafficLightState.red
            ? 'NO REGISTRADO'
            : state == TrafficLightState.yellow
                ? 'PENDIENTE'
                : '—';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
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
            Text('Color: ${data['color'] ?? '-'}'),
            Text('Residente: ${data['ownerName'] ?? '-'}'),
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
              await _incidentRepo.registerIncident(
                plate: plate,
                timestamp: now,
                guardId: FirebaseAuth.instance.currentUser!.uid,
                description: _obsController.text.trim(),
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
              await _incidentRepo.registerIncident(
                plate: plate,
                timestamp: now,
                guardId: FirebaseAuth.instance.currentUser!.uid,
                description: _obsController.text.trim(),
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
    setState(() {
      _loading = true;
      _lightState = TrafficLightState.idle;
    });
    final plate = _plate.text.trim().toUpperCase();
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
                                MaterialPageRoute(builder: (_) => const QRScannerPage()),
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
      ),
    );
  }
  @override
  void dispose() {
    _plate.dispose();
    _obsController.dispose();
    super.dispose();
  }
  @override
  void dispose() {
    _plate.dispose();
    _obsController.dispose();
    super.dispose();
  }
}
