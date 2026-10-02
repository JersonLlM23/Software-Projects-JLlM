/// Constants and metabolic equivalents (METs) for Activities.
/// Energy expenditure formula: kcal = MET * weightKg * (durationInMinutes / 60.0)
class ActivityConstants {
  ActivityConstants._();

  // Activity Names
  static const String walking = 'Caminar';
  static const String sleeping = 'Dormir';
  static const String studying = 'Estudiar';

  // Walking Intensities
  static const String intensitySlow = 'Lento';
  static const String intensityNormal = 'Normal';
  static const String intensityFast = 'Rápido';

  // MET values (Metabolic Equivalent of Task)
  // Walking:
  // Lento (~3.2 km/h): MET 2.8
  // Normal (~4.8 km/h): MET 3.5
  // Rápido (~6.4 km/h): MET 4.5
  static const double metWalkingSlow = 2.8;
  static const double metWalkingNormal = 3.5;
  static const double metWalkingFast = 4.5;

  // Sleeping: MET ~ 0.95
  static const double metSleeping = 0.95;

  // Studying: MET ~ 1.3
  static const double metStudying = 1.3;

  /// Returns the corresponding MET value for a given activity and intensity.
  static double getMet(String activityType, {String? intensity}) {
    switch (activityType) {
      case walking:
        switch (intensity) {
          case intensitySlow:
            return metWalkingSlow;
          case intensityFast:
            return metWalkingFast;
          case intensityNormal:
          default:
            return metWalkingNormal;
        }
      case sleeping:
        return metSleeping;
      case studying:
        return metStudying;
      default:
        return 1.0;
    }
  }
}
