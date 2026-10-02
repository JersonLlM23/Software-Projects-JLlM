import '../entities/meal.dart';
import '../repositories/meal_repository.dart';

class GetMealsByDateUseCase {
  final MealRepository _repository;

  const GetMealsByDateUseCase(this._repository);

  Future<List<Meal>> execute(DateTime date) {
    return _repository.getMealsByDate(date);
  }
}
