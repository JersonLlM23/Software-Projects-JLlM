import '../entities/food.dart';

/// Use case to compute energy in kcal for a given quantity of food based on its serving reference.
///
/// Formula:
/// calculatedEnergyKcal = (quantity / food.servingAmount) * food.energyKcal
class CalculateFoodCaloriesUseCase {
  const CalculateFoodCaloriesUseCase();

  double execute({
    required Food food,
    required double quantity,
  }) {
    if (quantity <= 0 || food.servingAmount <= 0) {
      return 0.0;
    }

    if (food.energyKcal <= 0) {
      return 0.0;
    }

    final double result = (quantity / food.servingAmount) * food.energyKcal;
    return result;
  }
}
