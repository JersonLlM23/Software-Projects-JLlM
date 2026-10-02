/// Intensities for activities (specifically Walking in v1.0.0).
enum ActivityIntensity {
  slow,
  normal,
  fast;

  String get displayName {
    switch (this) {
      case ActivityIntensity.slow:
        return 'Lento';
      case ActivityIntensity.normal:
        return 'Normal';
      case ActivityIntensity.fast:
        return 'Rápido';
    }
  }

  static ActivityIntensity? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'lento':
      case 'slow':
        return ActivityIntensity.slow;
      case 'rápido':
      case 'rapido':
      case 'fast':
        return ActivityIntensity.fast;
      case 'normal':
      default:
        return ActivityIntensity.normal;
    }
  }
}
