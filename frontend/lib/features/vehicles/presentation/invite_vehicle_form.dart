import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/repositories/vehicles_repository.dart';
import '../../../shared/models/vehicles.dto.dart';
import '../../../../widgets/vehicle_form.dart';

/// Formulario para que el residente invite un vehículo temporal o permanente.
class InviteVehicleForm extends StatefulWidget {
  final String ownerId;
  final String ownerEmail;
  const InviteVehicleForm({
    super.key,
    required this.ownerId,
    required this.ownerEmail,
  });

  @override
  State<InviteVehicleForm> createState() => _InviteVehicleFormState();
}

class _InviteVehicleFormState extends State<InviteVehicleForm> {
  bool _loading = false;
  final _repo = VehiclesRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invitar vehículo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: VehicleForm(
          ownerId: widget.ownerId,
          ownerEmail: widget.ownerEmail,
          showOneTime: true,
          showExpires: true,
          isLoading: _loading,
          submitLabel: 'Guardar invitación',
          onSubmit: (VehicleDto dto) async {
            setState(() { _loading = true; });
            await _repo.addVehicle(dto);
            setState(() { _loading = false; });
            if (mounted) Navigator.pop(context);
          },
        ),
      ),
    );
  }
}