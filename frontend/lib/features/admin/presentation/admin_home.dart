import 'package:flutter/material.dart';
import 'package:sgav_frontend/shared/widgets/logout_button.dart';
import 'package:sgav_frontend/features/vehicles/presentation/add_vehicle_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:html' as html; // only used on web
Future<void> _exportLogsAsPdf(BuildContext context) async {
  final query = await FirebaseFirestore.instance
      .collection('access_logs')
      .orderBy('timestamp', descending: true)
      .limit(500) // safety cap
      .get();

  if (query.docs.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No hay registros para exportar')),
    );
    return;
  }

  final pdf = pw.Document();
  pdf.addPage(
    pw.MultiPage(
      build: (ctx) => [
        pw.Header(level: 0, child: pw.Text('Bitácora de accesos')),
        pw.Table.fromTextArray(
          headers: ['Fecha', 'Patente', 'Guardia', 'Estado'],
          data: query.docs.map((d) {
            final m = d.data();
            final ts = (m['timestamp'] as Timestamp?)?.toDate();
            final date = ts != null
                ? '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')} '
                  '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}'
                : '-';
            return [
              date,
              m['plate'] ?? '-',
              m['guardId'] ?? '-',
              m['permitted'] == true ? 'SI' : 'NO',
            ];
          }).toList(),
          cellAlignment: pw.Alignment.centerLeft,
        ),
      ],
    ),
  );

  final bytes = await pdf.save();

  if (kIsWeb) {
    final b64 = base64Encode(bytes);
    final url = 'data:application/pdf;base64,$b64';
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'bitacora_accesos.pdf')
      ..click();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF descargado')),
    );
    return;
  }

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/bitacora_accesos.pdf');
  await file.writeAsBytes(bytes);

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF generado: ${file.path}')),
    );
    await OpenFile.open(file.path);
  }
}

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel administrador'),
        actions: const [LogoutButton()],
        
        ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🧠 Gestión de Usuarios',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar/Desactivar usuarios'),
                          onPressed: () => Navigator.pushNamed(context, '/users'),
                        ),
                        const SizedBox(height: 6),
                        // Deprecated: role assignment now handled in 'Editar/Desactivar usuarios'
                        // ElevatedButton.icon(
                        //   icon: const Icon(Icons.security),
                        //   label: const Text('Asignar roles'),
                        //   onPressed: () => Navigator.pushNamed(context, '/users'), // ajusta la ruta si tienes otra pantalla
                        // ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.person_add),
                          label: const Text('Añadir nuevo usuario'),
                          onPressed: () => Navigator.pushNamed(context, '/add-user'),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🚗 Gestión de Vehículos',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.list),
                          label: const Text('Ver todos los vehículos'),
                          onPressed: () => Navigator.pushNamed(context, '/vehicles-admin'),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar vehículo'),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddVehiclePage()),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📈 Dashboards y Reportes',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.dashboard),
                          label: const Text('Dashboards'),
                          onPressed: () => Navigator.pushNamed(context, '/dashboards'),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.history_toggle_off),
                          label: const Text('Historial de accesos por vehículo'),
                          onPressed: () => Navigator.pushNamed(context, '/vehicle-access-traceability'),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.history),
                          label: const Text('Ver bitácora'),
                          onPressed: () => Navigator.pushNamed(context, '/access-log'),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.download),
                          label: const Text('Exportar registros'),
                          onPressed: () => _exportLogsAsPdf(context),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🔒 Seguridad y Soporte',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.lock),
                          label: const Text('Revisar logs'),
                          onPressed: () => Navigator.pushNamed(context, '/system-logs'),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.support_agent),
                          label: const Text('Soporte a usuarios'),
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/incidents',
                            arguments: {'isAdmin': true},
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
