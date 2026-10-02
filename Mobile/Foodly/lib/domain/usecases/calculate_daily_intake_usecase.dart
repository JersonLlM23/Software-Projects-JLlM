import '../repositories/meal_repository.dart';

/// Calculates total energy consumed (kcal) for a given date.
class CalculateDailyIntakeUseCase {
  final MealRepository _mealRepository;

  const CalculateDailyIntakeUseCase(this._mealRepository);

  Future<double> execute(DateTime date) async {
    final meals = await _mealRepository.getMealsByDate(date);
    return meals.fold<double>(0.0, (sum, meal) => sum + meal.totalEnergyKcal);
  }
}
