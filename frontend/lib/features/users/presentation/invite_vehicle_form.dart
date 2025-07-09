import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../vehicles/repositories/vehicles_repository.dart';
import '../../vehicles/presentation/vehicles.dto.dart';
import '../../vehicles/widgets/vehicle_form.dart';
import '../../vehicles/services/vehicle_service.dart';

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
  final _service = VehicleService();

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

            try {
              await _service.addInvite(dto);
              setState(() { _loading = false; });
              if (mounted) Navigator.pop(context);
            } catch (e) {
              setState(() { _loading = false; });
              if (mounted) {
                if (kDebugMode) {
                  debugPrint('ERROR ▸ ${e.toString()}');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                  );
                }
              }
            }
          },
        ),
      ),
    );
  }
}