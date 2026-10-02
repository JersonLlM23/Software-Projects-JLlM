import '../entities/food.dart';
import '../repositories/food_repository.dart';

class GetFoodsUseCase {
  final FoodRepository _repository;

  const GetFoodsUseCase(this._repository);

  Future<List<Food>> execute() {
    return _repository.getFoods();
  }
}
