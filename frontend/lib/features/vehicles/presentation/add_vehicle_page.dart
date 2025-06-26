import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../shared/repositories/vehicles_repository.dart';
import '../../../shared/models/vehicles.dto.dart';
import '../../../../widgets/vehicle_form.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  bool _loading = false;
  String? _msg;
  final _repo = VehiclesRepository();

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
                VehicleForm(
                  ownerId: FirebaseAuth.instance.currentUser!.uid,
                  ownerEmail: FirebaseAuth.instance.currentUser!.email!,
                  isLoading: _loading,
                  submitLabel: 'Guardar',
                  onSubmit: (VehicleDto dto) async {
                    setState(() { _loading = true; _msg = null; });
                    await _repo.addVehicle(dto);
                    setState(() {
                      _loading = false;
                      _msg = 'Vehículo registrado ✔️';
                    });
                    await Future.delayed(const Duration(seconds: 1));
                    if (mounted) Navigator.pop(context);
                  },
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
