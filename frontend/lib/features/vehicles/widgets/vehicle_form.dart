

import 'package:flutter/material.dart';
import '../../../shared/models/vehicles.dto.dart';
import '../../../shared/utils/validators.dart';

/// Callback with the completed [VehicleDto] when the form is submitted.
typedef VehicleFormCallback = void Function(VehicleDto dto);

/// Reusable vehicle form for both registering and inviting vehicles.
class VehicleForm extends StatefulWidget {
  /// UID of the user registering the vehicle.
  final String ownerId;

  /// Email of the user registering the vehicle.
  final String ownerEmail;

  /// Initial values if editing an existing vehicle.
  final VehicleDto? initial;

  /// Whether to show the "single-use" toggle.
  final bool showOneTime;

  /// Whether to show the expiration date picker.
  final bool showExpires;

  /// Label for the submit button.
  final String submitLabel;

  /// Whether to display a loading indicator instead of the submit button.
  final bool isLoading;

  /// Called with the constructed [VehicleDto] on submit.
  final VehicleFormCallback onSubmit;

  const VehicleForm({
    Key? key,
    required this.ownerId,
    required this.ownerEmail,
    required this.onSubmit,
    this.initial,
    this.showOneTime = false,
    this.showExpires = false,
    this.submitLabel = 'Guardar',
    this.isLoading = false,
  }) : super(key: key);

  @override
  _VehicleFormState createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _plateController;
  late final TextEditingController _modelController;
  late final TextEditingController _colorController;
  bool _oneTime = true;
  DateTime? _expiresOn;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _plateController = TextEditingController(text: initial?.plate ?? '');
    _modelController = TextEditingController(text: initial?.model ?? '');
    _colorController = TextEditingController(text: initial?.color ?? '');
    _oneTime = initial?.oneTime ?? true;
    _expiresOn = initial?.expiresOn;
  }

  @override
  void dispose() {
    _plateController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiresDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiresOn ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() => _expiresOn = picked);
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    final dto = VehicleDto(
      plate: _plateController.text.trim().toUpperCase(),
      model: _modelController.text.trim(),
      color: _colorController.text.trim(),
      ownerId: widget.ownerId,
      ownerEmail: widget.ownerEmail,
      oneTime: widget.showOneTime ? _oneTime : null,
      expiresOn: widget.showExpires ? _expiresOn : null,
    );
    widget.onSubmit(dto);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _plateController,
            decoration: const InputDecoration(labelText: 'Patente *'),
            maxLength: 6,
            textCapitalization: TextCapitalization.characters,
            validator: Validators.plate,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _modelController,
            decoration: const InputDecoration(labelText: 'Modelo'),
            validator: Validators.model,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _colorController,
            decoration: const InputDecoration(labelText: 'Color'),
            validator: Validators.color,
          ),
          if (widget.showOneTime) ...[
            const SizedBox(height: 16),
            SwitchListTile(
              value: _oneTime,
              title: const Text('Una sola entrada'),
              subtitle: const Text('Desactívalo para definir fecha de expiración'),
              onChanged: (v) => setState(() {
                _oneTime = v;
                if (_oneTime) _expiresOn = null;
              }),
            ),
          ],
          if (widget.showExpires && !_oneTime) ...[
            ListTile(
              title: Text(
                _expiresOn == null
                  ? 'Seleccionar fecha de expiración'
                  : 'Expira: ${_expiresOn!.day}/${_expiresOn!.month}/${_expiresOn!.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickExpiresDate,
            ),
          ],
          const SizedBox(height: 24),
          widget.isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _handleSubmit,
                  child: Text(widget.submitLabel),
                ),
        ],
      ),
    );
  }
}