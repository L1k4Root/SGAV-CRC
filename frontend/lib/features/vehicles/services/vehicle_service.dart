import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../repositories/vehicles_repository.dart';
import '../repositories/invite_repository.dart';
import '../presentation/vehicles.dto.dart';

class VehicleService {
  final VehiclesRepository _vehiclesRepo;
  final InviteRepository _inviteRepo;

  VehicleService({
    VehiclesRepository? vehiclesRepo,
    InviteRepository? inviteRepo,
  })  : _vehiclesRepo = vehiclesRepo ?? VehiclesRepository(),
        _inviteRepo = inviteRepo ?? InviteRepository();

  Future<bool> existsPermanent(String plate) async {
    final normalized = plate.trim().toUpperCase();
    final allVehicles = await _vehiclesRepo.watchAll().first;
    return allVehicles.any((v) => v.plate == normalized);
  }

  Future<List<VehicleDto>> getActiveInvites(String plate) async {
    return await _inviteRepo.getActiveInvites(plate);
  }

  Future<void> addPermanent(VehicleDto dto) async {
    if (await existsPermanent(dto.plate)) {
      throw Exception('La patente permanente ya existe');
    }
    await _vehiclesRepo.addVehicle(dto);
  }

  Future<void> addInvite(VehicleDto dto) async {
    final invites = await _inviteRepo.getActiveInvites(dto.plate);
    if (invites.any((inv) => inv.ownerId == dto.ownerId)) {
      throw Exception('Ya existe una invitación activa para esta patente');
    }
    await _inviteRepo.addInvite(dto);
  }
}
