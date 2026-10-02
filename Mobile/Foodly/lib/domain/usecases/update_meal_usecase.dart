import '../entities/meal.dart';
import '../repositories/meal_repository.dart';

class UpdateMealUseCase {
  final MealRepository _repository;

  const UpdateMealUseCase(this._repository);

  Future<void> execute(Meal meal) {
    return _repository.updateMeal(meal);
  }
}
