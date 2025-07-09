import 'package:cloud_firestore/cloud_firestore.dart';

/// Data‑transfer object (single source of truth) for every vehicle in the app.
///
/// If algún día necesitas campos nuevos, agrégalos aquí
/// y en el widget `VehicleForm`, no en cada página individual.
class VehicleDto {
  /// Patente en mayúsculas sin espacios.
  final String plate;

  /// Modelo o descripción corta (ej. “Ford Focus”).
  final String model;

  /// Color principal (solo texto, ej. “Rojo”).
  final String color;

  /// Marca del vehículo (ej. "Ford").
  final String brand;

  /// UID del usuario que registró el vehículo.
  final String ownerId;

  /// Email de quien lo registró (útil para auditoría rápida).
  final String ownerEmail;

  /// ¿Está activo para ingresar?  `true` por defecto.
  final bool active;

  /// Fecha de creación en servidor.
  final DateTime createdAt;

  /// (Opcional) Fecha de expiración de la invitación.
  final DateTime? expiresOn;

  /// (Opcional) Invitación de un solo uso.
  final bool? oneTime;

  VehicleDto({
    required this.plate,
    required this.model,
    required this.color,
    required this.brand,
    required this.ownerId,
    required this.ownerEmail,
    this.active = true,
    DateTime? createdAt,
    this.expiresOn,
    this.oneTime,
  }) : createdAt = createdAt ?? DateTime.now();

  // ---------- Serialization ---------- //

  factory VehicleDto.fromJson(Map<String, dynamic> json) {
    return VehicleDto(
      plate: (json['plate'] ?? '').toString(),
      model: (json['model'] ?? '').toString(),
      color: (json['color'] ?? '').toString(),
      brand: (json['brand'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? '').toString(),
      ownerEmail: (json['ownerEmail'] ?? '').toString(),
      active: json['active'] is bool ? json['active'] as bool : true,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresOn: (json['expiresOn'] as Timestamp?)?.toDate(),
      oneTime: json['oneTime'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plate': plate.trim().toUpperCase(),
      'model': model.trim(),
      'color': color.trim(),
      'brand': brand.trim(),
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'active': active,
      'createdAt': Timestamp.fromDate(createdAt),
      if (expiresOn != null) 'expiresOn': Timestamp.fromDate(expiresOn!),
      if (oneTime != null) 'oneTime': oneTime,
    };
  }

  /// Alias for fromJson to support repositories using fromMap.
  factory VehicleDto.fromMap(Map<String, dynamic> map) => VehicleDto.fromJson(map);

  /// Alias for toJson to support repositories using toMap.
  Map<String, dynamic> toMap() => toJson();

  // ---------- Utilities ---------- //

  VehicleDto copyWith({
    String? plate,
    String? model,
    String? color,
    String? brand,
    String? ownerId,
    String? ownerEmail,
    bool? active,
    DateTime? createdAt,
    DateTime? expiresOn,
    bool? oneTime,
  }) {
    return VehicleDto(
      plate: plate ?? this.plate,
      model: model ?? this.model,
      color: color ?? this.color,
      brand: brand ?? this.brand,
      ownerId: ownerId ?? this.ownerId,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      expiresOn: expiresOn ?? this.expiresOn,
      oneTime: oneTime ?? this.oneTime,
    );
  }

  @override
  String toString() => 'VehicleDto($plate, active=$active)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleDto &&
          runtimeType == other.runtimeType &&
          plate == other.plate &&
          ownerId == other.ownerId;

  @override
  int get hashCode => plate.hashCode ^ ownerId.hashCode;
}
