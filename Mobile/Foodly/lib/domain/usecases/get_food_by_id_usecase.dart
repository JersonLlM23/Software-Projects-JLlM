import '../entities/food.dart';
import '../repositories/food_repository.dart';

class GetFoodByIdUseCase {
  final FoodRepository _repository;

  const GetFoodByIdUseCase(this._repository);

  Future<Food?> execute(String id) {
    return _repository.getFoodById(id);
  }
}
