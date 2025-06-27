

import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio centralizado para registrar eventos del sistema.
/// 
/// Llama `LoggingService.info|warning|error` desde cualquier
/// punto crítico de la app para dejar trazabilidad en la
/// colección **system_logs** de Firestore.
///
/// Ejemplo:
/// ```dart
/// await LoggingService.info(
///   module: 'auth',
///   event: 'login_success',
///   uid: user.uid,
/// );
/// ```
class LoggingService {
  LoggingService._(); // Previene instanciación

  static final CollectionReference _logs =
      FirebaseFirestore.instance.collection('system_logs');

  static Future<void> _log({
    required String module,
    required String event,
    required String severity,
    String? uid,
    Map<String, dynamic>? payload,
  }) {
    return _logs.add({
      'module': module,
      'event': event,
      'severity': severity,
      'uid': uid,
      'timestamp': FieldValue.serverTimestamp(),
      'payload': payload ?? {},
    });
  }

  /// Registro de severidad INFO
  static Future<void> info({
    required String module,
    required String event,
    String? uid,
    Map<String, dynamic>? payload,
  }) => _log(
        module: module,
        event: event,
        severity: 'info',
        uid: uid,
        payload: payload,
      );

  /// Registro de severidad WARNING
  static Future<void> warning({
    required String module,
    required String event,
    String? uid,
    Map<String, dynamic>? payload,
  }) => _log(
        module: module,
        event: event,
        severity: 'warning',
        uid: uid,
        payload: payload,
      );

  /// Registro de severidad ERROR
  static Future<void> error({
    required String module,
    required String event,
    String? uid,
    Map<String, dynamic>? payload,
  }) => _log(
        module: module,
        event: event,
        severity: 'error',
        uid: uid,
        payload: payload,
      );
}