import 'package:flutter/material.dart';
import '../../../shared/services/api_client.dart';

class GuardPanel extends StatefulWidget {
  const GuardPanel({super.key});

  @override
  State<GuardPanel> createState() => _GuardPanelState();
}

class _GuardPanelState extends State<GuardPanel> {
  final _plate = TextEditingController();
  final _api = ApiClient();
  String? _status; // null = sin consulta, 'ok', 'nok'
  bool _loading = false;

  Future<void> _check() async {
    setState(() {
      _loading = true;
      _status = null;
    });
    final plate = _plate.text.trim().toUpperCase();
    final data = await _api.getVehicle(plate);
    setState(() {
      _status = data == null ? 'nok' : 'ok';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = _status == 'ok'
        ? Colors.green
        : _status == 'nok'
            ? Colors.red
            : Colors.grey;

    final text = _status == 'ok'
        ? 'AUTORIZADO'
        : _status == 'nok'
            ? 'NO REGISTRADO'
            : '—';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Guardia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Registrar vehículo',
            onPressed: () => Navigator.pushNamed(context, '/add'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _plate,
                  decoration: const InputDecoration(labelText: 'Patente (ej. ABC123)'),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 24),
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _check,
                        child: const Text('Verificar'),
                      ),
                const SizedBox(height: 32),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
