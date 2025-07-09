import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sgav_frontend/features/vehicles/services/vehicle_service.dart';
import 'package:sgav_frontend/features/vehicles/presentation/vehicles.dto.dart';

/// Listas estandarizadas de colores y marcas ― mantener simples y fáciles de
/// ampliar si fuese necesario.
const List<String> kVehicleColors = [
  'Negro',
  'Blanco',
  'Plateado',
  'Gris',
  'Rojo',
  'Azul',
  'Verde',
  'Amarillo',
  'Naranja',
  'Otro',
];

const List<String> kVehicleBrands = [
  'Toyota',
  'Ford',
  'Chevrolet',
  'Honda',
  'Nissan',
  'BMW',
  'Mercedes‑Benz',
  'Volkswagen',
  'Audi',
  'Hyundai',
  'Kia',
  'Mazda',
  'Subaru',
  'Tesla',
  'Renault',
  'Peugeot',
  'Citroën',
  'Fiat',
  'Jeep',
  'Volvo',
  'Otro',
];

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({Key? key}) : super(key: key);

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();

  String _plate = '';
  String _model = '';
  String _color = kVehicleColors.first;
  String _brand = '';

  String _capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser!;
    final vehicle = VehicleDto(
      plate: _plate,
      brand: _capitalize(_brand),
      model: _capitalize(_model),
      color: _capitalize(_color),
      ownerId: user.uid,
      ownerEmail: user.email ?? '',
    );

    try {
      final service = VehicleService();
      await service.addPermanent(vehicle);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Éxito'),
          content: const Text('Vehículo guardado correctamente.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text('No se pudo guardar: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar vehículo')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Patente
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Patente'),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (v) => _plate = v.trim().toUpperCase(),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Ingrese la patente'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Marca (autocomplete)
                  Autocomplete<String>(
                    optionsBuilder: (t) {
                      if (t.text.isEmpty) return const Iterable.empty();
                      return kVehicleBrands.where((b) =>
                          b.toLowerCase().contains(t.text.toLowerCase()));
                    },
                    onSelected: (sel) => setState(() => _brand = sel),
                    fieldViewBuilder:
                        (ctx, ctl, focusNode, onFieldSubmitted) {
                      ctl.text = _brand;
                      return TextFormField(
                        controller: ctl,
                        focusNode: focusNode,
                        decoration:
                            const InputDecoration(labelText: 'Marca'),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Seleccione una marca'
                            : null,
                        onChanged: (v) => _brand = v.trim(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Modelo
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Modelo'),
                    textCapitalization: TextCapitalization.words,
                    onChanged: (v) => _model = v.trim(),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Ingrese el modelo'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Color
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Color'),
                    value: _color,
                    items: kVehicleColors
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _color = v);
                    },
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar'),
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
