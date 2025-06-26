import 'package:flutter/material.dart';
import 'package:sgav_frontend/shared/widgets/logout_button.dart';
import 'package:sgav_frontend/features/vehicles/presentation/add_vehicle_page.dart';

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
                        ElevatedButton.icon(
                          icon: const Icon(Icons.security),
                          label: const Text('Asignar roles'),
                          onPressed: () => Navigator.pushNamed(context, '/users'), // ajusta la ruta si tienes otra pantalla
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
                        ElevatedButton.icon(
                          icon: const Icon(Icons.history_toggle_off),
                          label: const Text('Historial de accesos por vehículo'),
                          onPressed: null, // Placeholder
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
                          '🏡 Gestión de Accesos',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.history),
                          label: const Text('Ver bitácora'),
                          onPressed: null, // Placeholder
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.download),
                          label: const Text('Exportar registros'),
                          onPressed: null, // Placeholder
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
                          '📊 Reportes e Indicadores',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.bar_chart),
                          label: const Text('Dashboard de KPIs'),
                          onPressed: null, // Placeholder
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
                          onPressed: null, // Placeholder
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.support_agent),
                          label: const Text('Soporte a usuarios'),
                          onPressed: null, // Placeholder
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
