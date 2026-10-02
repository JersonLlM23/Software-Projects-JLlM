import '../entities/gender.dart';

/// Use case to calculate Basal Metabolic Rate (BMR) using the Mifflin-St Jeor equation.
///
/// Formulas:
/// - Male: BMR = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5
/// - Female: BMR = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161
class CalculateBMRUseCase {
  const CalculateBMRUseCase();

  double execute({
    required Gender gender,
    required double weightKg,
    required double heightCm,
    required int age,
  }) {
    if (weightKg <= 0 || heightCm <= 0 || age < 0) {
      return 0.0;
    }

    final double base = (10.0 * weightKg) + (6.25 * heightCm) - (5.0 * age);

    if (gender == Gender.male) {
      return base + 5.0;
    } else {
      return base - 161.0;
    }
  }
}
