import '../repositories/meal_repository.dart';

class DeleteMealUseCase {
  final MealRepository _repository;

  const DeleteMealUseCase(this._repository);

  Future<void> execute(String id) {
    return _repository.deleteMeal(id);
  }
}
