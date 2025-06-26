/// Conjunto de validadores reutilizables para formularios.
///
/// Se mantienen libres de `BuildContext` para facilitar tests unitarios.
/// Retornan `null` cuando el campo es **válido**; de lo contrario devuelven
/// el mensaje de error que se mostrará en pantalla.
class Validators {
  // ---------------------------------------------------------------------------
  // Patente chilena
  // ---------------------------------------------------------------------------

  /// Valida la patente chilena (nuevo formato AA BB 11 o antiguo AA 11 11).
  ///
  /// - Acepta mayúsculas sin espacios ni guiones.
  /// - Se permite minúsculas (se transforman a mayúsculas dentro del validador).
  static String? plate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa la patente';
    }
    final plate = value.trim().toUpperCase();

    // Formato estándar: 3 letras + 3 dígitos (ej. ABC123)
    final regStandard = RegExp(r'^[A-Z]{3}[0-9]{3}$');

    if (!regStandard.hasMatch(plate)) {
      return 'Formato de patente inválido (ABC123)';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Modelo
  // ---------------------------------------------------------------------------

  static String? model(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa el modelo';
    }
    if (value.trim().length < 2) {
      return 'Modelo demasiado corto';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Color
  // ---------------------------------------------------------------------------

  static String? color(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa el color';
    }
    if (value.trim().length < 3) {
      return 'Color demasiado corto';
    }
    return null;
  }
}