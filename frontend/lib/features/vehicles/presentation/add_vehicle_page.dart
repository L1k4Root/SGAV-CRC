import 'package:flutter/material.dart';
import '../../../shared/services/api_client.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _plate = TextEditingController();
  final _model = TextEditingController();
  final _color = TextEditingController();
  final _api = ApiClient();
  bool _loading = false;
  String? _msg;

  Future<void> _save() async {
    setState(() {
      _loading = true;
      _msg = null;
    });
    await _api.addVehicle({
      'plate': _plate.text.trim().toUpperCase(),
      'model': _model.text.trim(),
      'color': _color.text.trim(),
    });
    setState(() {
      _loading = false;
      _msg = 'Vehículo registrado ✔️';
    });
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar vehículo')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _plate, decoration: const InputDecoration(labelText: 'Patente')),
                const SizedBox(height: 12),
                TextField(controller: _model, decoration: const InputDecoration(labelText: 'Modelo')),
                const SizedBox(height: 12),
                TextField(controller: _color, decoration: const InputDecoration(labelText: 'Color')),
                const SizedBox(height: 24),
                _loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar'),
                        onPressed: _save,
                      ),
                if (_msg != null) ...[
                  const SizedBox(height: 16),
                  Text(_msg!, style: const TextStyle(color: Colors.green)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
