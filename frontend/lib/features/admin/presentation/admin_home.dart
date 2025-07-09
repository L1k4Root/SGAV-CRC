import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sgav_frontend/shared/widgets/logout_button.dart';
import 'package:sgav_frontend/shared/services/export_service.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  // --- Helpers to reduce widget nesting and improve readability ---
  /// Generic section card
  Widget _sectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Builds the four home‑sections as a list; keeps build() compact
  List<Widget> _buildSections(BuildContext context) => [
        // 🧠 Gestión de Usuarios
        _sectionCard('🧠 Gestión de Usuarios', [
          ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text('Editar/Desactivar usuarios'),
            onPressed: () => Navigator.pushNamed(context, '/users'),
          ),
          const SizedBox(height: 6),
          ElevatedButton.icon(
            icon: const Icon(Icons.person_add),
            label: const Text('Añadir nuevo usuario'),
            onPressed: () => Navigator.pushNamed(context, '/add-user'),
          ),
        ]),

        // 🚗 Gestión de Vehículos
        _sectionCard('🚗 Gestión de Vehículos', [
          ElevatedButton.icon(
            icon: const Icon(Icons.list),
            label: const Text('Ver todos los vehículos'),
            onPressed: () => Navigator.pushNamed(context, '/vehicles-admin'),
          ),
          const SizedBox(height: 6),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Agregar vehículo'),
            onPressed: () => Navigator.pushNamed(context, '/add'),
          ),
        ]),

        // 📈 Dashboards y Reportes
        _sectionCard('📈 Dashboards y Reportes', [
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
            onPressed: () => ExportService.exportLogsAsPdf(context),
          ),
        ]),

        // 🔒 Seguridad y Soporte
        _sectionCard('🔒 Seguridad y Soporte', [
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
        ]),
      ];

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
              children: _buildSections(context),
            ),
          ),
        ),
      ),
    );
  }
}
