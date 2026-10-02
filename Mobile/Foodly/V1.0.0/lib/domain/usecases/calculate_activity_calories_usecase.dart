import '../../core/constants/activity_constants.dart';
import '../entities/activity_intensity.dart';
import '../entities/activity_type.dart';

/// Use case to estimate calories burned during an activity event.
///
/// Calculation:
/// kcal = MET * weightKg * (durationInMinutes / 60.0)
class CalculateActivityCaloriesUseCase {
  const CalculateActivityCaloriesUseCase();

  double execute({
    required ActivityType type,
    ActivityIntensity? intensity,
    required DateTime startDateTime,
    required DateTime endDateTime,
    required double weightKg,
  }) {
    final int durationMinutes = endDateTime.difference(startDateTime).inMinutes;
    if (durationMinutes <= 0 || weightKg <= 0) {
      return 0.0;
    }

    final String typeStr = type.displayName;
    final String? intensityStr = intensity?.displayName;
    final double met = ActivityConstants.getMet(typeStr, intensity: intensityStr);

    final double hours = durationMinutes / 60.0;
    final double burned = met * weightKg * hours;

    return burned < 0 ? 0.0 : burned;
  }
}
