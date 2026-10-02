import '../entities/meal.dart';
import '../repositories/meal_repository.dart';

class AddMealUseCase {
  final MealRepository _repository;

  const AddMealUseCase(this._repository);

  Future<void> execute(Meal meal) {
    return _repository.addMeal(meal);
  }
}
