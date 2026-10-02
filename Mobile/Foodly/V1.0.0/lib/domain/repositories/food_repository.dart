import '../entities/food.dart';

/// Contract for Food dataset persistence and retrieval.
abstract class FoodRepository {
  Future<List<Food>> getFoods();
  Future<Food?> getFoodById(String id);
  Future<void> saveFoods(List<Food> foods);
  Future<void> addFood(Food food);
}
